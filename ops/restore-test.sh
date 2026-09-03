#!/usr/bin/env bash
# Weekly Mac restore test: pull encrypted dumps, decrypt locally, load into
# a throwaway Postgres, check ledger invariants. Never touches production.
set -euo pipefail

OPS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
. "$OPS_ROOT/lib.sh"

usage() {
  cat <<'EOF'
Usage: ops/restore-test.sh --throwaway [--apply] [--yes]

Requires --throwaway so this cannot be aimed at production by accident.
Default is dry-run. --apply pulls, decrypts, and restores into a disposable
Postgres container that is destroyed on exit.
EOF
}

FW_APPLY=0
FW_YES=0
THROWAWAY=0
while [ $# -gt 0 ]; do
  case "$1" in
    --throwaway) THROWAWAY=1 ;;
    --apply) FW_APPLY=1 ;;
    --yes) FW_YES=1 ;;
    --dry-run) FW_APPLY=0 ;;
    -h|--help) usage; exit 0 ;;
    *) fw_die "unknown argument: $1" ;;
  esac
  shift
done

[ "$THROWAWAY" = "1" ] || fw_die "refusing to run without --throwaway"

fw_load_env
fw_require_var BACKUP_PULL_DIR
fw_require_var BACKUP_GIT_REMOTE
fw_require_var AGE_IDENTITY

BACKUP_PULL_DIR="$(fw_abs_path "$BACKUP_PULL_DIR")"
AGE_IDENTITY="$(fw_abs_path "$AGE_IDENTITY")"
fw_require_secret_mode "$AGE_IDENTITY"

if [ -n "${POSTGRES_DATA_DIR:-}" ]; then
  prod="$(fw_abs_path "$POSTGRES_DATA_DIR")"
  case "$BACKUP_PULL_DIR" in
    "$prod"|"$prod"/*) fw_die "BACKUP_PULL_DIR must not be production POSTGRES_DATA_DIR" ;;
  esac
fi

NAME="fw-restore-test-$$"
fw_log "mode=$(fw_is_apply && echo apply || echo dry-run) throwaway=$NAME"

if ! fw_is_apply; then
  fw_log "plan: git fetch/pull $BACKUP_GIT_REMOTE into $BACKUP_PULL_DIR"
  fw_log "plan: decrypt newest forests-wallet-*.age with local age identity"
  fw_log "plan: docker run isolated postgres:18 (no host ports, not production data dir)"
  fw_log "plan: psql restore + ops/restore-invariants.sql"
  fw_log "plan: destroy throwaway container/volume"
  fw_log "dry-run complete; production was not contacted"
  exit 0
fi

fw_require_cmd git
fw_require_cmd age
fw_require_cmd docker

mkdir -p "$BACKUP_PULL_DIR"
if [ ! -d "$BACKUP_PULL_DIR/.git" ]; then
  fw_log "cloning backup remote (separate from the code repo)"
  git clone "$BACKUP_GIT_REMOTE" "$BACKUP_PULL_DIR"
else
  git -C "$BACKUP_PULL_DIR" fetch --quiet origin
  if git -C "$BACKUP_PULL_DIR" rev-parse --verify origin/main >/dev/null 2>&1; then
    git -C "$BACKUP_PULL_DIR" checkout -q -B main origin/main
  elif git -C "$BACKUP_PULL_DIR" rev-parse --verify origin/master >/dev/null 2>&1; then
    git -C "$BACKUP_PULL_DIR" checkout -q -B master origin/master
  else
    git -C "$BACKUP_PULL_DIR" pull --ff-only --quiet
  fi
fi

CODE_TOP="$(git -C "$REPO_ROOT" rev-parse --show-toplevel 2>/dev/null || true)"
PULL_TOP="$(git -C "$BACKUP_PULL_DIR" rev-parse --show-toplevel)"
if [ -n "$CODE_TOP" ] && [ "$CODE_TOP" = "$PULL_TOP" ]; then
  fw_die "BACKUP_PULL_DIR must not be the application repository"
fi

newest=""
for f in "$BACKUP_PULL_DIR"/forests-wallet-*.age; do
  [ -f "$f" ] || continue
  newest="$f"
done
# glob order is lexical; stamps are UTC YYYYMMDDThhmmssZ so last match is newest
for f in "$BACKUP_PULL_DIR"/forests-wallet-*.age; do
  [ -f "$f" ] || continue
  [ "$f" -nt "$newest" ] && newest="$f"
done
[ -n "$newest" ] || fw_die "no forests-wallet-*.age files in $BACKUP_PULL_DIR"

fw_log "restoring $(basename -- "$newest") into throwaway postgres"

TMPDIR_RESTORE="$(mktemp -d)"
cleanup() {
  rm -rf "$TMPDIR_RESTORE"
  if [ -n "${FW_RESTORE_PSQL:-}" ]; then
    return 0
  fi
  docker rm -f "$NAME" >/dev/null 2>&1 || true
  docker network rm "$NAME" >/dev/null 2>&1 || true
}
trap cleanup EXIT

PLAIN="$TMPDIR_RESTORE/dump.sql"
umask 077
case "$newest" in
  *.sql.gz.age)
    age -d -i "$AGE_IDENTITY" -o - "$newest" | gzip -dc >"$PLAIN"
    ;;
  *.sql.age)
    age -d -i "$AGE_IDENTITY" -o "$PLAIN" "$newest"
    ;;
  *)
    fw_die "unrecognized backup name (want *.sql.gz.age or *.sql.age)"
    ;;
esac
[ -s "$PLAIN" ] || fw_die "decrypted dump is empty"
if ! grep -q "PostgreSQL database dump" "$PLAIN"; then
  fw_die "decrypted file does not look like a plain-SQL pg_dump"
fi

run_psql_file() {
  local src="$1"
  local dest="$2"
  if [ -n "${FW_RESTORE_PSQL:-}" ]; then
    "$FW_RESTORE_PSQL" -v ON_ERROR_STOP=1 -f "$src"
  else
    docker run --rm --network "$NAME" \
      -v "$src:$dest:ro" \
      -e PGPASSWORD=restore \
      postgres:18 \
      psql -h "$NAME" -U restore -d restore -v ON_ERROR_STOP=1 -f "$dest"
  fi
}

if [ -z "${FW_RESTORE_PSQL:-}" ]; then
  docker network create "$NAME" >/dev/null
  docker run -d --name "$NAME" --network "$NAME" \
    --network-alias postgres-throwaway \
    -e POSTGRES_USER=restore \
    -e POSTGRES_PASSWORD=restore \
    -e POSTGRES_DB=restore \
    postgres:18 >/dev/null
  i=0
  while [ "$i" -lt 30 ]; do
    if docker exec "$NAME" pg_isready -U restore -d restore >/dev/null 2>&1; then
      break
    fi
    i=$((i + 1))
    sleep 1
  done
  [ "$i" -lt 30 ] || fw_die "throwaway postgres did not become ready"
fi

run_psql_file "$PLAIN" /dump.sql >/dev/null
run_psql_file "$OPS_ROOT/restore-invariants.sql" /invariants.sql

fw_log "restore test passed for $(basename -- "$newest")"
