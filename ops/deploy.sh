#!/usr/bin/env bash
# Ship tracked files to the VPS over SSH/rsync and run guarded Compose commands.
# Default is dry-run. Production changes require --apply and confirmation.
# Does not place a GitHub deploy key on the server.
set -euo pipefail

OPS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
. "$OPS_ROOT/lib.sh"

usage() {
  cat <<'EOF'
Usage: ops/deploy.sh [--dry-run|--apply] [--yes]

Default: dry-run (validate, print plan, mutate nothing).
--apply  rsync tracked files and run compose build/migrate/up on the VPS.
--yes    skip the confirmation prompt (still requires --apply).

Required env (file via FW_ENV, or repo .env): DEPLOY_SSH, DEPLOY_PATH, DOMAIN
EOF
}

args_rc=0
fw_parse_apply_args "$@" || args_rc=$?
if [ "$args_rc" = "2" ]; then
  usage
  exit 0
fi

fw_load_env
fw_require_var DEPLOY_SSH
fw_require_var DEPLOY_PATH
fw_require_var DOMAIN
case "$DOMAIN" in
  *://*|*[/:@]*|*[.][.]*) fw_die "DOMAIN must be a bare hostname" ;;
esac
fw_require_cmd git
fw_require_cmd rsync

case "$DEPLOY_PATH" in
  /*) ;;
  *) fw_die "DEPLOY_PATH must be an absolute path" ;;
esac
[ "$DEPLOY_PATH" != "/" ] || fw_die "DEPLOY_PATH must not be /"

if git -C "$REPO_ROOT" ls-files --error-unmatch .env >/dev/null 2>&1; then
  fw_die ".env is tracked by git; untrack it before deploy"
fi

if [ -n "$(git -C "$REPO_ROOT" status --porcelain -uno)" ]; then
  if fw_is_apply; then
    fw_die "refusing --apply on a dirty worktree (tracked changes)"
  fi
  fw_log "warning: dirty worktree (allowed in dry-run only)"
fi

HEAD_SHA="$(git -C "$REPO_ROOT" rev-parse HEAD)"
HEAD_SHORT="$(git -C "$REPO_ROOT" rev-parse --short HEAD)"
if [ -n "${DEPLOY_EXPECTED_REF:-}" ]; then
  EXPECTED_SHA="$(git -C "$REPO_ROOT" rev-parse "${DEPLOY_EXPECTED_REF}^{commit}")"
  if [ "$HEAD_SHA" != "$EXPECTED_SHA" ]; then
    fw_die "HEAD $HEAD_SHA does not match DEPLOY_EXPECTED_REF $DEPLOY_EXPECTED_REF ($EXPECTED_SHA)"
  fi
fi

FILE_LIST="$(mktemp)"
cleanup() { rm -f "$FILE_LIST"; }
trap cleanup EXIT
git -C "$REPO_ROOT" ls-files >"$FILE_LIST"
[ -s "$FILE_LIST" ] || fw_die "no tracked files to ship"

RSYNC_RSH="$(fw_ssh_rsh)"
REMOTE="${DEPLOY_SSH}:${DEPLOY_PATH}/"
APP_TAG="$HEAD_SHORT"

fw_log "mode=$(fw_is_apply && echo apply || echo dry-run) head=$HEAD_SHORT dest=$DEPLOY_SSH path=$DEPLOY_PATH domain=$DOMAIN"

if ! fw_is_apply; then
  fw_log "plan: rsync tracked files to $REMOTE"
  fw_log "plan: remote APP_IMAGE_TAG=$APP_TAG docker compose build"
  fw_log "plan: remote ops/init-db-roles.sh (admin creates migrator+runtime)"
  fw_log "plan: remote fw migrate with MIGRATE_DATABASE_URL on the one-shot only"
  fw_log "plan: remote docker compose up -d"
  fw_log "plan: wait for GET /healthz via app node, then host curl https://$DOMAIN/healthz"
  fw_log "plan: record $DEPLOY_PATH/.deployed-revision (keep previous for rollback)"
  fw_log "dry-run complete; rerun with --apply --yes to mutate the VPS"
  exit 0
fi

fw_require_confirmation "Type 'deploy' to ship $HEAD_SHORT to $DEPLOY_SSH:" "deploy"

fw_log "rsync tracked files"
rsync -az --files-from="$FILE_LIST" \
  -e "$RSYNC_RSH" \
  "$REPO_ROOT/" "$REMOTE"

fw_log "remote compose build/migrate/up"
ssh_identity_args=""
if [ -n "${DEPLOY_SSH_IDENTITY:-}" ]; then
  ssh_identity_args="-i $DEPLOY_SSH_IDENTITY"
fi
# Quoted remote script so local bash cannot parse it. Values arrive via env.
# shellcheck disable=SC2086
ssh -o BatchMode=yes -o IdentitiesOnly=yes $ssh_identity_args "$DEPLOY_SSH" \
  env DEPLOY_PATH="$DEPLOY_PATH" APP_TAG="$APP_TAG" bash -s <<'REMOTE'
set -euo pipefail
cd "$DEPLOY_PATH"
umask 077
[ -f .env ] || { echo "missing $DEPLOY_PATH/.env" >&2; exit 1; }
perm=$(stat -c '%a' .env 2>/dev/null || stat -f '%Lp' .env)
case "$perm" in
  *00) : ;;
  *) echo "refusing .env mode $perm (need 600)" >&2; exit 1 ;;
esac
if [ -f .deployed-revision ]; then
  cp .deployed-revision .previous-revision
fi
export APP_IMAGE_TAG="$APP_TAG"
set -a
# shellcheck disable=SC1091
. ./.env
set +a
docker compose --env-file .env build app
docker compose --env-file .env up -d postgres
pg_i=0
while [ "$pg_i" -lt 30 ]; do
  if docker compose --env-file .env exec -T postgres pg_isready >/dev/null 2>&1; then
    break
  fi
  pg_i=$((pg_i+1))
  sleep 2
done
[ "$pg_i" -lt 30 ] || { echo "postgres did not become ready" >&2; exit 1; }
./ops/init-db-roles.sh --apply --yes
docker compose --env-file .env run --rm --no-deps --entrypoint fw \
  -e MIGRATE_DATABASE_URL \
  app migrate
docker compose --env-file .env up -d --remove-orphans
ok=0
i=0
while [ "$i" -lt 30 ]; do
  if docker compose --env-file .env exec -T app node -e "fetch('http://127.0.0.1:3000/healthz').then((r)=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))"; then
    ok=1
    break
  fi
  i=$((i+1))
  sleep 2
done
if [ "$ok" = "1" ] && command -v curl >/dev/null 2>&1; then
  pub=0
  p=0
  while [ "$p" -lt 15 ]; do
    if curl -fsS --max-time 10 --resolve "${DOMAIN}:443:127.0.0.1" "https://${DOMAIN}/healthz" >/dev/null 2>&1; then
      pub=1
      break
    fi
    p=$((p+1))
    sleep 2
  done
  if [ "$pub" != "1" ]; then
    echo "public https://$DOMAIN/healthz failed (Caddy/TLS)" >&2
    ok=0
  fi
fi
printf '%s\n' "$APP_TAG" > .deployed-revision
if [ "$ok" != "1" ]; then
  echo "healthz failed after deploy of $APP_TAG" >&2
  if [ -f .previous-revision ]; then
    echo "rollback: APP_IMAGE_TAG=$(cat .previous-revision) docker compose --env-file .env up -d app" >&2
  fi
  exit 1
fi
echo "deployed $APP_TAG"
REMOTE

fw_log "deploy of $APP_TAG complete"
fw_log "rollback: ssh $DEPLOY_SSH 'cd $DEPLOY_PATH && APP_IMAGE_TAG=\$(cat .previous-revision) docker compose --env-file .env up -d app'"
