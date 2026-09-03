# Shared helpers for Forrest's Wallet operator scripts.
# Bash 3.2 compatible (macOS /bin/bash). Source only; do not execute.
# shellcheck shell=bash

if [ -z "${FW_LIB_LOADED:-}" ]; then
  FW_LIB_LOADED=1
  set -euo pipefail
fi

if [ -z "${OPS_ROOT:-}" ]; then
  OPS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi
if [ -z "${REPO_ROOT:-}" ]; then
  REPO_ROOT="$(cd "$OPS_ROOT/.." && pwd)"
fi

fw_utc_now() {
  date -u +%Y-%m-%dT%H:%M:%SZ
}

fw_backup_stamp() {
  date -u +%Y%m%dT%H%M%SZ
}

# Indirect expansion without namerefs (Bash 3.2).
fw_get_var() {
  eval "printf '%s' \"\${$1:-}\""
}

fw_redact_string() {
  local s="$1"
  local v secret
  for v in \
    POSTGRES_PASSWORD \
    DATABASE_URL \
    HEALTHCHECKS_URL \
    AGE_IDENTITY \
    AGE_RECIPIENT \
    DEPLOY_SSH_IDENTITY \
    BACKUP_GIT_SSH_KEY \
    ACME_EMAIL; do
    secret="$(fw_get_var "$v")"
    if [ -n "$secret" ]; then
      s="${s//$secret/[redacted]}"
    fi
  done
  printf '%s' "$s" | sed -E \
    -e 's|postgres(ql)?://[^[:space:]]+|[redacted-db-url]|g' \
    -e 's|AGE-SECRET-KEY-[[:alnum:]_-]+|[redacted-age-identity]|g' \
    -e 's|age1[a-z0-9]{20,}|[redacted-age-recipient]|g' \
    -e 's|hc-ping\.com/[A-Za-z0-9_-]+|hc-ping.com/[redacted]|g' \
    -e 's|healthchecks\.io/ping/[A-Za-z0-9_-]+|healthchecks.io/ping/[redacted]|g' \
    -e 's|(Authorization:[[:space:]]*)[^[:space:]]+|\1[redacted]|g'
}

fw_log() {
  local msg
  msg="$(fw_redact_string "$*")"
  printf '%s %s\n' "$(fw_utc_now)" "$msg" >&2
}

fw_die() {
  fw_log "error: $*"
  exit 1
}

fw_file_mode() {
  local f="$1"
  if stat -c '%a' "$f" >/dev/null 2>&1; then
    stat -c '%a' "$f"
  else
    stat -f '%Lp' "$f"
  fi
}

# Secret files must not be group- or world-accessible (mode ends with 00).
fw_require_secret_mode() {
  local f="$1"
  local mode last2
  [ -f "$f" ] || fw_die "missing secret file: $f"
  mode="$(fw_file_mode "$f")"
  last2="$(printf '%s' "$mode" | awk '{ print substr($0, length($0)-1, 2) }')"
  if [ "$last2" != "00" ]; then
    fw_die "refusing group/world-accessible secret file $f (mode $mode); chmod 600"
  fi
}

fw_abs_path() {
  local target="$1"
  local d b
  case "$target" in
    /*) ;;
    *) target="$(pwd)/$target" ;;
  esac
  if [ -d "$target" ]; then
    (cd "$target" && pwd -P)
    return 0
  fi
  d="$(dirname -- "$target")"
  b="$(basename -- "$target")"
  if [ ! -d "$d" ]; then
    printf '%s/%s\n' "$d" "$b"
    return 0
  fi
  (cd "$d" && printf '%s/%s\n' "$(pwd -P)" "$b")
}

fw_is_inside_dir() {
  local parent="$1"
  local child="$2"
  case "$child" in
    "$parent"|"$parent"/*) return 0 ;;
    *) return 1 ;;
  esac
}

fw_load_env_file() {
  local f="$1"
  [ -f "$f" ] || fw_die "missing env file: $f"
  fw_require_secret_mode "$f"
  set -a
  # shellcheck disable=SC1090
  . "$f"
  set +a
}

# Load FW_ENV if set, else $REPO_ROOT/.env when present.
fw_load_env() {
  if [ -n "${FW_ENV:-}" ]; then
    fw_load_env_file "$FW_ENV"
  elif [ -f "$REPO_ROOT/.env" ]; then
    fw_load_env_file "$REPO_ROOT/.env"
  fi
}

fw_require_var() {
  local name="$1"
  local value
  value="$(fw_get_var "$name")"
  [ -n "$value" ] || fw_die "required variable $name is empty or unset"
}

fw_require_cmd() {
  local c="$1"
  command -v "$c" >/dev/null 2>&1 || fw_die "required command not found: $c"
}

fw_is_apply() {
  [ "${FW_APPLY:-0}" = "1" ]
}

fw_parse_apply_args() {
  FW_APPLY=0
  FW_YES=0
  while [ $# -gt 0 ]; do
    case "$1" in
      --apply) FW_APPLY=1 ;;
      --yes) FW_YES=1 ;;
      --dry-run) FW_APPLY=0 ;;
      -h|--help) return 2 ;;
      *) fw_die "unknown argument: $1" ;;
    esac
    shift
  done
}

fw_require_confirmation() {
  local prompt="$1"
  local expected="$2"
  if [ "${FW_YES:-0}" = "1" ]; then
    return 0
  fi
  if [ ! -t 0 ]; then
    fw_die "refusing unattended apply without --yes"
  fi
  printf '%s ' "$prompt" >&2
  local ans
  IFS= read -r ans || true
  [ "$ans" = "$expected" ] || fw_die "aborted"
}

fw_compose() {
  docker compose -f "$REPO_ROOT/compose.yaml" --project-directory "$REPO_ROOT" "$@"
}

fw_ssh_rsh() {
  local cmd="ssh -o BatchMode=yes -o IdentitiesOnly=yes"
  if [ -n "${DEPLOY_SSH_IDENTITY:-}" ]; then
    fw_require_secret_mode "$DEPLOY_SSH_IDENTITY"
    cmd="$cmd -i $DEPLOY_SSH_IDENTITY"
  fi
  printf '%s' "$cmd"
}

fw_app_cli() {
  local bin="${APP_CLI:-fw}"
  fw_compose exec -T app "$bin" "$@"
}
