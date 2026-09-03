#!/usr/bin/env bash
TEST_NAME=test_caddy
# shellcheck source=helpers.sh
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/helpers.sh"

CADDYFILE="$REPO_ROOT/Caddyfile"

grep -q '{$DOMAIN}' "$CADDYFILE" && pass "Caddyfile uses DOMAIN env" || fail "missing {\$DOMAIN}"
grep -q 'reverse_proxy app:3000' "$CADDYFILE" && pass "reverse_proxy app:3000" || fail "missing reverse_proxy"
grep -q 'max_size' "$CADDYFILE" && pass "body size limit" || fail "missing body limit"
grep -q 'Authorization delete' "$CADDYFILE" && pass "Authorization not logged" || fail "missing Authorization log filter"
if grep -qE '^[[:space:]]*(metrics|debug)[[:space:]]|^[[:space:]]*handle /metrics|/metrics[[:space:]]|/debug[[:space:]]' "$CADDYFILE"; then
  fail "Caddyfile exposes metrics or debug"
else
  pass "no metrics/debug leak routes"
fi
if grep -q 'admin 0.0.0.0' "$CADDYFILE"; then
  fail "admin API bound on all interfaces"
else
  pass "admin API not on 0.0.0.0"
fi

validate_caddy() {
  DOMAIN=wallet.example.com ACME_EMAIL=operator@example.com \
    caddy validate --config "$CADDYFILE" --adapter caddyfile
}

if have_cmd caddy; then
  if validate_caddy >/tmp/fw-caddy-validate.out 2>&1; then
    pass "caddy validate (local binary)"
  else
    fail "caddy validate failed ($(tr '\n' ' ' </tmp/fw-caddy-validate.out))"
  fi
elif have_cmd docker; then
  if docker run --rm \
    -e DOMAIN=wallet.example.com \
    -e ACME_EMAIL=operator@example.com \
    -v "$CADDYFILE:/etc/caddy/Caddyfile:ro" \
    caddy:2 \
    caddy validate --config /etc/caddy/Caddyfile --adapter caddyfile \
    >/tmp/fw-caddy-validate.out 2>&1; then
    pass "caddy validate (docker caddy:2)"
  else
    fail "caddy validate via docker failed ($(tr '\n' ' ' </tmp/fw-caddy-validate.out))"
  fi
else
  skip "caddy validate (neither caddy nor docker available)"
fi

finish
