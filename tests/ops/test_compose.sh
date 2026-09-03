#!/usr/bin/env bash
TEST_NAME=test_compose
# shellcheck source=helpers.sh
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/helpers.sh"

COMPOSE="$REPO_ROOT/compose.yaml"

parsed="$(python3 - "$COMPOSE" <<'PY'
import re, sys
path = sys.argv[1]
lines = open(path).read().splitlines()
services = []
current = None
ports = {}
binds = {}
in_services = False
in_ports = False
in_bind = False
for line in lines:
    if line.startswith("services:"):
        in_services = True
        current = None
        continue
    if in_services and line and not line[0].isspace() and not line.startswith("#"):
        in_services = False
    if not in_services:
        continue
    m = re.match(r"^  ([A-Za-z0-9_-]+):\s*$", line)
    if m:
        current = m.group(1)
        services.append(current)
        ports.setdefault(current, [])
        binds.setdefault(current, [])
        in_ports = in_bind = False
        continue
    if current is None:
        continue
    stripped = line.strip()
    if re.match(r"^    [A-Za-z0-9_-]+:", line):
        in_ports = stripped.startswith("ports:")
        in_bind = False
    if in_ports and ("published:" in stripped or re.search(r":(80|443)\b", stripped)):
        ports[current].append(stripped)
    if "type: bind" in stripped:
        in_bind = True
    if in_bind and stripped.startswith("source:"):
        binds[current].append(stripped.split(":", 1)[1].strip())
print("count=%d" % len(services))
print("names=%s" % ",".join(sorted(services)))
print("caddy_ports=%d" % len(ports.get("caddy", [])))
print("app_ports=%d" % len(ports.get("app", [])))
print("postgres_ports=%d" % len(ports.get("postgres", [])))
print("postgres_binds=%s" % ";".join(binds.get("postgres", [])))
print("has_80=%s" % any("80" in p for p in ports.get("caddy", [])))
print("has_443=%s" % any("443" in p for p in ports.get("caddy", [])))
PY
)"

count="" names="" caddy_ports="" app_ports="" postgres_ports="" postgres_binds="" has_80="" has_443=""
while IFS='=' read -r k v; do
  case "$k" in
    count) count="$v" ;;
    names) names="$v" ;;
    caddy_ports) caddy_ports="$v" ;;
    app_ports) app_ports="$v" ;;
    postgres_ports) postgres_ports="$v" ;;
    postgres_binds) postgres_binds="$v" ;;
    has_80) has_80="$v" ;;
    has_443) has_443="$v" ;;
  esac
done <<EOF
$parsed
EOF

[ "$count" = "3" ] && pass "exactly three services" || fail "expected 3 services, got $count ($names)"
[ "$names" = "app,caddy,postgres" ] && pass "service names app,caddy,postgres" || fail "names=$names"
[ "$app_ports" = "0" ] && pass "app publishes no host ports" || fail "app ports=$app_ports"
[ "$postgres_ports" = "0" ] && pass "postgres publishes no host ports" || fail "postgres ports=$postgres_ports"
[ "$has_80" = "True" ] && pass "caddy publishes 80" || fail "caddy missing 80 ($parsed)"
[ "$has_443" = "True" ] && pass "caddy publishes 443" || fail "caddy missing 443"
printf '%s' "$postgres_binds" | grep -q 'POSTGRES_DATA_DIR' && pass "postgres data is a bind mount from POSTGRES_DATA_DIR" || fail "postgres binds=$postgres_binds"

grep -q 'image: postgres:18' "$COMPOSE" && pass "postgres major pin postgres:18" || fail "postgres image not pinned to 18"
grep -q 'image: caddy:2' "$COMPOSE" && pass "caddy major pin caddy:2" || fail "caddy image not pinned to 2"
if grep -q '@sha256:' "$COMPOSE"; then
  fail "compose pretends to pin an unverified digest"
else
  pass "no unverified image digest"
fi

if grep -Eq 'POSTGRES_PASSWORD:[[:space:]]*['\''"][^$]' "$COMPOSE"; then
  fail "hard-coded postgres password"
else
  pass "postgres password is interpolated, not hard-coded"
fi
if grep -Eq 'DATABASE_URL:[[:space:]]*['\''"]postgres' "$COMPOSE"; then
  fail "hard-coded DATABASE_URL"
else
  pass "DATABASE_URL is interpolated, not hard-coded"
fi

grep -q 'healthcheck:' "$COMPOSE" && pass "healthchecks present" || fail "no healthchecks"
grep -q 'restart: unless-stopped' "$COMPOSE" && pass "restart policy present" || fail "no restart policy"
grep -q 'max-size:' "$COMPOSE" && pass "log size limits present" || fail "no log size limits"
grep -q 'condition: service_healthy' "$COMPOSE" && pass "dependency readiness via service_healthy" || fail "no service_healthy depends_on"
grep -q 'app:3000' "$REPO_ROOT/Caddyfile" && pass "Caddyfile proxies app:3000" || fail "Caddyfile missing app:3000"
grep -q '/healthz' "$COMPOSE" && pass "app health path /healthz" || fail "missing /healthz"

if grep -qE '^volumes:' "$COMPOSE"; then
  fail "top-level named volumes present (postgres must be a bind mount)"
else
  pass "no top-level named volumes"
fi

if have_cmd docker; then
  export DOMAIN=wallet.example.com
  export ACME_EMAIL=operator@example.com
  export POSTGRES_USER=forests
  export POSTGRES_PASSWORD=test-placeholder-not-a-secret
  export POSTGRES_DB=forests_wallet
  export DATABASE_URL=postgres://forests:test-placeholder-not-a-secret@postgres:5432/forests_wallet
  export POSTGRES_DATA_DIR=/tmp/fw-ops-test-pgdata
  export CADDY_DATA_DIR=/tmp/fw-ops-test-caddy
  export CADDY_CONFIG_DIR=/tmp/fw-ops-test-caddy-config
  export APP_IMAGE_TAG=test
  cfg="$(mktemp)"
  if docker compose -f "$COMPOSE" --project-directory "$REPO_ROOT" config --format json >"$cfg" 2>/tmp/fw-compose-config.err; then
    pass "docker compose config"
    if python3 - "$cfg" <<'PY'
import json, sys
data = json.load(open(sys.argv[1]))
svcs = sorted(data.get("services", {}).keys())
assert svcs == ["app", "caddy", "postgres"], svcs
caddy = data["services"]["caddy"]
app = data["services"]["app"]
pg = data["services"]["postgres"]
assert "ports" in caddy and caddy["ports"], "caddy has no ports"
pubs = set()
for p in caddy["ports"]:
    pubs.add(str(p.get("published")))
assert "80" in pubs and "443" in pubs, pubs
assert not app.get("ports"), app.get("ports")
assert not pg.get("ports"), pg.get("ports")
vols = pg.get("volumes") or []
assert vols, "postgres has no volumes"
v0 = vols[0]
assert v0.get("type") == "bind", v0
src = v0.get("source") or ""
assert "fw-ops-test-pgdata" in src or "POSTGRES_DATA_DIR" in src, src
PY
    then
      pass "rendered compose: 3 services, only caddy 80/443, postgres bind"
    else
      fail "rendered compose json checks"
    fi
  else
    fail "docker compose config failed ($(tr '\n' ' ' </tmp/fw-compose-config.err))"
  fi
  rm -f "$cfg"
else
  skip "docker compose config (docker not available)"
fi

finish
