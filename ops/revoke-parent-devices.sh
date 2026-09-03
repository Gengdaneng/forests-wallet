#!/usr/bin/env bash
# Revoke every parent device via the application CLI. One active parent
# device is the family-pilot policy. Does not edit SQL by hand.
set -euo pipefail

OPS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
. "$OPS_ROOT/lib.sh"

usage() {
  cat <<'EOF'
Usage: ops/revoke-parent-devices.sh [--dry-run|--apply] [--yes]

Calls `fw revoke-parent-devices` in the running app container.
After this, open-bootstrap.sh so the replacement iPhone can register.
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

fw_log "mode=$(fw_is_apply && echo apply || echo dry-run) cli=$BIN revoke-parent-devices"

if ! fw_is_apply; then
  fw_log "plan: docker compose exec -T app $BIN revoke-parent-devices"
  fw_log "dry-run complete"
  exit 0
fi

fw_require_confirmation "Type 'revoke' to revoke ALL parent devices:" "revoke"
fw_require_cmd docker
fw_app_cli revoke-parent-devices
fw_log "parent devices revoked; next request with the old token must 401"
