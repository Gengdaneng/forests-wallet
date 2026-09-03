#!/usr/bin/env bash
TEST_NAME=test_roles
# shellcheck source=helpers.sh
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/helpers.sh"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

ok="$TMP/roles.env"
make_secret_env "$ok" <<EOF
POSTGRES_ADMIN_USER=forests_admin
POSTGRES_ADMIN_PASSWORD=adminpassadminpass1
POSTGRES_DB=forests_wallet
POSTGRES_MIGRATOR_USER=forests_wallet_migrator
POSTGRES_MIGRATOR_PASSWORD=migratorpassmigrator1
POSTGRES_RUNTIME_USER=forests_wallet_runtime
POSTGRES_RUNTIME_PASSWORD=runtimepassruntime1
EOF

if FW_ENV="$ok" "$OPS_ROOT/init-db-roles.sh" >"$TMP/dry.out" 2>"$TMP/dry.err"; then
  pass "init-db-roles dry-run"
else
  fail "init-db-roles dry-run failed: $(tr '\n' ' ' <"$TMP/dry.err")"
fi
grep -q "forests_wallet_runtime" "$TMP/dry.err" && pass "dry-run mentions runtime role" || fail "dry-run missing runtime role"

sql_log="$TMP/psql.sql"
if FW_ENV="$ok" FW_PSQL="tee $sql_log" "$OPS_ROOT/init-db-roles.sh" --apply --yes >/dev/null 2>"$TMP/apply.err"; then
  pass "init-db-roles --apply with FW_PSQL"
else
  fail "init-db-roles --apply failed: $(tr '\n' ' ' <"$TMP/apply.err")"
fi
grep -q "CREATE ROLE forests_wallet_migrator" "$sql_log" && pass "bootstrap creates migrator" || fail "SQL missing migrator"
grep -q "CREATE ROLE forests_wallet_runtime" "$sql_log" && pass "bootstrap creates runtime" || fail "SQL missing runtime"
grep -q "OWNER TO forests_wallet_migrator" "$sql_log" && pass "database owner is migrator" || fail "SQL missing owner"

unsafe="$TMP/unsafe.env"
make_secret_env "$unsafe" <<EOF
POSTGRES_ADMIN_USER=forests_admin
POSTGRES_ADMIN_PASSWORD=adminpassadminpass1
POSTGRES_DB=forests_wallet
POSTGRES_MIGRATOR_PASSWORD=bad@password-has-at
POSTGRES_RUNTIME_PASSWORD=runtimepassruntime1
EOF
if FW_ENV="$unsafe" "$OPS_ROOT/init-db-roles.sh" >/dev/null 2>"$TMP/unsafe.err"; then
  fail "init-db-roles should refuse @ in passwords"
else
  pass "init-db-roles refuses URL-unsafe passwords"
fi

subs="$TMP/subs.env"
make_secret_env "$subs" <<EOF
POSTGRES_ADMIN_USER=forests_admin
POSTGRES_ADMIN_PASSWORD=\$(whoami)whoamiwhoami1
POSTGRES_DB=forests_wallet
POSTGRES_MIGRATOR_PASSWORD=migratorpassmigrator1
POSTGRES_RUNTIME_PASSWORD=runtimepassruntime1
EOF
if FW_ENV="$subs" "$OPS_ROOT/init-db-roles.sh" >/dev/null 2>"$TMP/subs.err"; then
  fail "init-db-roles should refuse command substitution in env"
else
  pass "init-db-roles refuses command substitution in sourced env"
fi

grep -q -- '--entrypoint fw' "$OPS_ROOT/deploy.sh" && pass "deploy uses --entrypoint fw" || fail "deploy missing --entrypoint fw"
grep -q -- '-e MIGRATE_DATABASE_URL' "$OPS_ROOT/deploy.sh" && pass "deploy injects MIGRATE_DATABASE_URL on one-shot" || fail "deploy missing -e MIGRATE_DATABASE_URL"
if grep -q 'entrypoint fw app migrate' "$OPS_ROOT/deploy.sh" || grep -q 'app migrate' "$OPS_ROOT/deploy.sh"; then
  pass "deploy runs fw migrate"
else
  fail "deploy does not run fw migrate"
fi
if grep -n 'caddy curl' "$OPS_ROOT/deploy.sh" >/dev/null; then
  fail "deploy still uses caddy curl"
else
  pass "deploy does not use caddy curl"
fi
grep -q 'init-db-roles.sh' "$OPS_ROOT/deploy.sh" && pass "deploy sequence includes init-db-roles" || fail "deploy missing init-db-roles"

if grep -q 'MIGRATE_DATABASE_URL' "$REPO_ROOT/compose.yaml"; then
  # comments may mention it; the app environment must not interpolate it
  if grep -E '^[[:space:]]+MIGRATE_DATABASE_URL:' "$REPO_ROOT/compose.yaml" >/dev/null; then
    fail "compose app service interpolates MIGRATE_DATABASE_URL"
  else
    pass "compose does not put MIGRATE_DATABASE_URL on a service"
  fi
else
  pass "compose has no MIGRATE_DATABASE_URL key"
fi

finish
