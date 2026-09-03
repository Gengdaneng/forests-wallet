#!/usr/bin/env bash
# Idempotent first-database role bootstrap.
# Creates forests_wallet_migrator (schema owner) and forests_wallet_runtime
# (app). Run as the Postgres image admin. Does not apply SQL migrations.
set -euo pipefail

OPS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
. "$OPS_ROOT/lib.sh"

usage() {
  cat <<'EOF'
Usage: ops/init-db-roles.sh [--dry-run|--apply] [--yes]

Creates/updates LOGIN roles forests_wallet_migrator and
forests_wallet_runtime, then ALTERs the database owner to the migrator.
Idempotent. Required before `fw migrate` (migration 002 expects the
runtime role to already exist).
EOF
}

args_rc=0
fw_parse_apply_args "$@" || args_rc=$?
if [ "$args_rc" = "2" ]; then
  usage
  exit 0
fi

fw_load_env
fw_require_sql_ident POSTGRES_ADMIN_USER
fw_require_sql_ident POSTGRES_DB
fw_require_safe_secret POSTGRES_ADMIN_PASSWORD
fw_require_safe_secret POSTGRES_MIGRATOR_PASSWORD
fw_require_safe_secret POSTGRES_RUNTIME_PASSWORD

if [ "${POSTGRES_MIGRATOR_USER:-forests_wallet_migrator}" != "forests_wallet_migrator" ]; then
  fw_die "POSTGRES_MIGRATOR_USER must be forests_wallet_migrator"
fi
if [ "${POSTGRES_RUNTIME_USER:-forests_wallet_runtime}" != "forests_wallet_runtime" ]; then
  fw_die "POSTGRES_RUNTIME_USER must be forests_wallet_runtime"
fi
if [ "$POSTGRES_ADMIN_USER" = "forests_wallet_runtime" ] || [ "$POSTGRES_ADMIN_USER" = "forests_wallet_migrator" ]; then
  fw_die "POSTGRES_ADMIN_USER must not be the migrator or runtime role"
fi

fw_log "mode=$(fw_is_apply && echo apply || echo dry-run) init-db-roles db=$POSTGRES_DB"

if ! fw_is_apply; then
  fw_log "plan: CREATE/ALTER ROLE forests_wallet_migrator LOGIN NOSUPERUSER"
  fw_log "plan: CREATE/ALTER ROLE forests_wallet_runtime LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE"
  fw_log "plan: ALTER DATABASE $POSTGRES_DB OWNER TO forests_wallet_migrator"
  fw_log "dry-run complete"
  exit 0
fi

# Passwords already charset-checked; safe to embed in this generated SQL.
SQL=$(cat <<SQL
DO \$\$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'forests_wallet_migrator') THEN
    CREATE ROLE forests_wallet_migrator LOGIN PASSWORD '${POSTGRES_MIGRATOR_PASSWORD}' NOSUPERUSER NOCREATEDB NOCREATEROLE;
  ELSE
    ALTER ROLE forests_wallet_migrator WITH LOGIN PASSWORD '${POSTGRES_MIGRATOR_PASSWORD}' NOSUPERUSER NOCREATEDB NOCREATEROLE;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'forests_wallet_runtime') THEN
    CREATE ROLE forests_wallet_runtime LOGIN PASSWORD '${POSTGRES_RUNTIME_PASSWORD}' NOSUPERUSER NOCREATEDB NOCREATEROLE;
  ELSE
    ALTER ROLE forests_wallet_runtime WITH LOGIN PASSWORD '${POSTGRES_RUNTIME_PASSWORD}' NOSUPERUSER NOCREATEDB NOCREATEROLE;
  END IF;
END
\$\$;

ALTER DATABASE ${POSTGRES_DB} OWNER TO forests_wallet_migrator;
GRANT CONNECT ON DATABASE ${POSTGRES_DB} TO forests_wallet_migrator;
GRANT CONNECT ON DATABASE ${POSTGRES_DB} TO forests_wallet_runtime;
SQL
)

if [ -n "${FW_PSQL:-}" ]; then
  printf '%s\n' "$SQL" | sh -c "$FW_PSQL"
else
  fw_require_cmd docker
  printf '%s\n' "$SQL" | fw_compose exec -T postgres \
    psql -U "$POSTGRES_ADMIN_USER" -d "$POSTGRES_DB" -v ON_ERROR_STOP=1
fi

fw_log "roles ready (migrator owns $POSTGRES_DB; runtime cannot DDL)"
