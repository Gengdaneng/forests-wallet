#!/usr/bin/env bash
# Daily plain-SQL pg_dump → optional gzip → age encrypt → local retain →
# commit/push to a separate private git remote → healthchecks ping on success.
# The age private identity never reaches the VPS.
set -euo pipefail

OPS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
. "$OPS_ROOT/lib.sh"

usage() {
  cat <<'EOF'
Usage: ops/backup.sh [--dry-run|--apply] [--yes]

Default: dry-run. --apply performs dump/encrypt/push.
Pings HEALTHCHECKS_URL only after dump, encryption, and git push succeed.
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
fw_require_var AGE_RECIPIENT
fw_require_var BACKUP_LOCAL_DIR
fw_require_var BACKUP_GIT_DIR
fw_require_var BACKUP_GIT_REMOTE
fw_require_var BACKUP_RETENTION_DAYS
fw_require_var HEALTHCHECKS_URL

case "$AGE_RECIPIENT" in
  age1*) ;;
  *) fw_die "AGE_RECIPIENT must be an age public recipient (age1...)" ;;
esac

case "$HEALTHCHECKS_URL" in
  https://*) ;;
  *) fw_die "HEALTHCHECKS_URL must be https" ;;
esac

case "$BACKUP_RETENTION_DAYS" in
  *[!0-9]*) fw_die "BACKUP_RETENTION_DAYS must be a positive integer" ;;
esac
[ "$BACKUP_RETENTION_DAYS" -gt 0 ] || fw_die "BACKUP_RETENTION_DAYS must be > 0"
[ "$BACKUP_RETENTION_DAYS" -le 3650 ] || fw_die "BACKUP_RETENTION_DAYS is unreasonably large"

BACKUP_COMPRESS="${BACKUP_COMPRESS:-1}"
BACKUP_LOCAL_DIR="$(fw_abs_path "$BACKUP_LOCAL_DIR")"
BACKUP_GIT_DIR="$(fw_abs_path "$BACKUP_GIT_DIR")"

case "$BACKUP_LOCAL_DIR" in
  /|/tmp|/private/tmp|/var|/private/var|/usr|/etc|/home|/root|/private|/opt|/srv)
    fw_die "BACKUP_LOCAL_DIR is too broad: $BACKUP_LOCAL_DIR"
    ;;
esac
backup_depth=0
_oldifs="$IFS"
IFS=/
for _part in $BACKUP_LOCAL_DIR; do
  if [ -n "$_part" ]; then
    backup_depth=$((backup_depth + 1))
  fi
done
IFS="$_oldifs"
[ "$backup_depth" -ge 2 ] || fw_die "BACKUP_LOCAL_DIR is too broad: $BACKUP_LOCAL_DIR"
fw_is_inside_dir "$BACKUP_LOCAL_DIR" "$BACKUP_GIT_DIR" && \
  fw_die "BACKUP_GIT_DIR must not live inside BACKUP_LOCAL_DIR (retention would eat git)"

STAMP="$(fw_backup_stamp)"
if [ "$BACKUP_COMPRESS" = "1" ]; then
  BACKUP_NAME="forests-wallet-${STAMP}.sql.gz.age"
else
  BACKUP_NAME="forests-wallet-${STAMP}.sql.age"
fi
LOCAL_OUT="$BACKUP_LOCAL_DIR/$BACKUP_NAME"

fw_log "mode=$(fw_is_apply && echo apply || echo dry-run) backup=$BACKUP_NAME"

if ! fw_is_apply; then
  fw_log "plan: pg_dump plain SQL as $POSTGRES_ADMIN_USER/$POSTGRES_DB"
  fw_log "plan: encrypt to local $BACKUP_LOCAL_DIR (age public recipient only)"
  fw_log "plan: copy ciphertext into $BACKUP_GIT_DIR and git add/commit/push $BACKUP_GIT_REMOTE"
  fw_log "plan: prune forests-wallet-*.age older than $BACKUP_RETENTION_DAYS days inside $BACKUP_LOCAL_DIR"
  fw_log "plan: ping healthchecks only after push succeeds"
  fw_log "dry-run complete; no dump, git, or ping"
  exit 0
fi

fw_require_cmd age
fw_require_cmd git
fw_require_cmd curl
if [ "$BACKUP_COMPRESS" = "1" ]; then
  fw_require_cmd gzip
fi

umask 077
mkdir -p "$BACKUP_LOCAL_DIR"

if [ ! -d "$BACKUP_GIT_DIR/.git" ]; then
  fw_die "BACKUP_GIT_DIR is not a git repo: $BACKUP_GIT_DIR"
fi

CODE_TOP="$(git -C "$REPO_ROOT" rev-parse --show-toplevel 2>/dev/null || true)"
BACKUP_TOP="$(git -C "$BACKUP_GIT_DIR" rev-parse --show-toplevel)"
if [ -n "$CODE_TOP" ] && [ "$CODE_TOP" = "$BACKUP_TOP" ]; then
  fw_die "backup git dir must be a separate repository, not the application repo"
fi

CODE_ORIGIN="$(git -C "$REPO_ROOT" remote get-url origin 2>/dev/null || true)"
if [ -n "$CODE_ORIGIN" ] && [ "$CODE_ORIGIN" = "$BACKUP_GIT_REMOTE" ]; then
  fw_die "BACKUP_GIT_REMOTE must not be the application code remote"
fi

run_pg_dump() {
  if [ -n "${FW_PG_DUMP:-}" ]; then
    sh -c "$FW_PG_DUMP"
  else
    fw_require_cmd docker
    fw_compose exec -T postgres \
      pg_dump -U "$POSTGRES_ADMIN_USER" -d "$POSTGRES_DB" \
        --no-owner --no-privileges --format=plain
  fi
}

encrypt_stream() {
  if [ "$BACKUP_COMPRESS" = "1" ]; then
    gzip -c | age -r "$AGE_RECIPIENT" -o "$LOCAL_OUT"
  else
    age -r "$AGE_RECIPIENT" -o "$LOCAL_OUT"
  fi
}

fw_log "dumping and encrypting (plaintext never written to disk)"
if ! run_pg_dump | encrypt_stream; then
  rm -f "$LOCAL_OUT"
  fw_die "dump or encryption failed; not staging, not pinging"
fi
[ -s "$LOCAL_OUT" ] || { rm -f "$LOCAL_OUT"; fw_die "encrypted backup is empty"; }
chmod 600 "$LOCAL_OUT"

# Ciphertext only from here. Never git add a path from a temp dump.
GIT_DEST="$BACKUP_GIT_DIR/$BACKUP_NAME"
cp "$LOCAL_OUT" "$GIT_DEST"
chmod 600 "$GIT_DEST"

if [ -n "${BACKUP_GIT_SSH_KEY:-}" ]; then
  fw_require_secret_mode "$BACKUP_GIT_SSH_KEY"
  export GIT_SSH_COMMAND="ssh -i $BACKUP_GIT_SSH_KEY -o IdentitiesOnly=yes -o BatchMode=yes -o StrictHostKeyChecking=yes"
fi

fw_log "staging ciphertext in backup git repo"
git -C "$BACKUP_GIT_DIR" add -- "$BACKUP_NAME"

STAGED="$(git -C "$BACKUP_GIT_DIR" diff --cached --name-only)"
if [ -z "$STAGED" ]; then
  if git -C "$BACKUP_GIT_DIR" cat-file -e "HEAD:$BACKUP_NAME" 2>/dev/null; then
    fw_log "identical ciphertext already in git; skip commit/push"
  else
    fw_die "nothing staged; refusing to ping"
  fi
else
  while IFS= read -r path; do
    [ -n "$path" ] || continue
    case "$path" in
      *.age) ;;
      *) fw_die "refusing to commit non-encrypted path: $path" ;;
    esac
  done <<STAGED_EOF
$STAGED
STAGED_EOF
  git -C "$BACKUP_GIT_DIR" \
    -c user.email=backup@forests-wallet.local \
    -c user.name=forests-wallet-backup \
    commit -m "backup $STAMP"
  fw_log "pushing backup remote"
  if ! git -C "$BACKUP_GIT_DIR" push "$BACKUP_GIT_REMOTE" HEAD:refs/heads/main; then
    fw_die "git push failed; not pinging healthchecks"
  fi
fi

fw_log "pruning local ciphertext older than $BACKUP_RETENTION_DAYS days"
cutoff_epoch=$(($(date -u +%s) - BACKUP_RETENTION_DAYS * 86400))
# Portable mtime: GNU stat -c %Y, BSD stat -f %m
for f in "$BACKUP_LOCAL_DIR"/forests-wallet-*.age; do
  [ -e "$f" ] || continue
  [ -f "$f" ] || continue
  abs="$(fw_abs_path "$f")"
  fw_is_inside_dir "$BACKUP_LOCAL_DIR" "$abs" || fw_die "retention path escaped root: $abs"
  case "$(basename -- "$abs")" in
    forests-wallet-*.age) ;;
    *) continue ;;
  esac
  if stat -c '%Y' "$abs" >/dev/null 2>&1; then
    mtime="$(stat -c '%Y' "$abs")"
  else
    mtime="$(stat -f '%m' "$abs")"
  fi
  if [ "$mtime" -lt "$cutoff_epoch" ]; then
    fw_log "prune $(basename -- "$abs")"
    rm -f "$abs"
  fi
done

fw_log "backup ok; pinging healthchecks"
curl -fsS --max-time 20 -o /dev/null "$HEALTHCHECKS_URL" \
  || fw_die "healthchecks ping failed after a successful backup"
fw_log "backup complete"
