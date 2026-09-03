#!/usr/bin/env bash
# Recreate the app container from the previous deploy tag.
# Run on the VPS (or via ssh) from the compose project directory.
set -euo pipefail

OPS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
. "$OPS_ROOT/lib.sh"

usage() {
  cat <<'EOF'
Usage: ops/rollback.sh [--dry-run|--apply] [--yes]

Reads $DEPLOY_PATH/.previous-revision (written by ops/deploy.sh) and
runs: APP_IMAGE_TAG=<that> docker compose up -d app
EOF
}

args_rc=0
fw_parse_apply_args "$@" || args_rc=$?
if [ "$args_rc" = "2" ]; then
  usage
  exit 0
fi

fw_load_env
DEPLOY_PATH="${DEPLOY_PATH:-$REPO_ROOT}"
PREV="$DEPLOY_PATH/.previous-revision"
[ -f "$PREV" ] || fw_die "no $PREV (nothing to roll back to)"
TAG="$(tr -d '[:space:]' <"$PREV")"
[ -n "$TAG" ] || fw_die "previous revision file is empty"

fw_log "mode=$(fw_is_apply && echo apply || echo dry-run) rollback_to=$TAG"

if ! fw_is_apply; then
  fw_log "plan: APP_IMAGE_TAG=$TAG docker compose up -d app"
  fw_log "dry-run complete"
  exit 0
fi

fw_require_confirmation "Type 'rollback' to start app image $TAG:" "rollback"
fw_require_cmd docker
cd "$DEPLOY_PATH"
APP_IMAGE_TAG="$TAG" docker compose --env-file .env up -d app
fw_log "rollback to $TAG requested; confirm GET /healthz"
