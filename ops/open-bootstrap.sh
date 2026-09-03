#!/usr/bin/env bash
# Open the parent-device bootstrap window via the application CLI.
# Does not edit SQL by hand.
set -euo pipefail

OPS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
. "$OPS_ROOT/lib.sh"

usage() {
  cat <<'EOF'
Usage: ops/open-bootstrap.sh [--dry-run|--apply] [--yes]

Calls `fw open-bootstrap` in the running app container (≤30 minutes).
Use only after every parent device has been revoked, or on first install.
EOF
}

args_rc=0
fw_parse_apply_args "$@" || args_rc=$?
if [ "$args_rc" = "2" ]; then
  usage
  exit 0
fi

fw_load_env
BIN="${APP_CLI:-fw}"

fw_log "mode=$(fw_is_apply && echo apply || echo dry-run) cli=$BIN open-bootstrap"

if ! fw_is_apply; then
  fw_log "plan: docker compose exec -T app $BIN open-bootstrap"
  fw_log "dry-run complete"
  exit 0
fi

fw_require_confirmation "Type 'bootstrap' to open parent registration:" "bootstrap"
fw_require_cmd docker
fw_app_cli open-bootstrap
fw_log "bootstrap window opened; it must close on parent register or after 30 minutes"
