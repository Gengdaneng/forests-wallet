#!/usr/bin/env bash
# Smallest VPS package/directory setup. Does not create Hetzner resources,
# does not touch sshd (lockout risk), does not enable UFW.
# Default is dry-run. --apply is Linux-only.
set -euo pipefail

OPS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
. "$OPS_ROOT/lib.sh"

usage() {
  cat <<'EOF'
Usage: ops/host-setup.sh [--dry-run|--apply] [--yes]

Installs docker.io, docker-compose-v2, age, git, rsync, unattended-upgrades
and creates /srv/forests-wallet plus /var/lib/forests-wallet bind-mount roots.
SSHD hardening is documented in docs/operations.md (second-session check).
EOF
}

args_rc=0
fw_parse_apply_args "$@" || args_rc=$?
if [ "$args_rc" = "2" ]; then
  usage
  exit 0
fi

DEPLOY_USER="${DEPLOY_USER:-deploy}"
SRV_DIR="${SRV_DIR:-/srv/forests-wallet}"
DATA_ROOT="${DATA_ROOT:-/var/lib/forests-wallet}"

plan() {
  fw_log "plan: apt-get update && install ca-certificates curl git gzip rsync age docker.io docker-compose-v2 unattended-upgrades"
  fw_log "plan: systemctl enable --now docker"
  fw_log "plan: mkdir $SRV_DIR $DATA_ROOT/{postgres,caddy,caddy-config,backups,backup-git}"
  fw_log "plan: chown $DEPLOY_USER:$DEPLOY_USER those trees; chmod 700 data roots"
  fw_log "plan: enable unattended-upgrades (security updates only)"
}

plan

if ! fw_is_apply; then
  fw_log "dry-run complete; rerun on the VPS with --apply --yes"
  exit 0
fi

if [ "$(uname -s)" != "Linux" ]; then
  fw_die "host-setup --apply is only for the VPS (Linux)"
fi
if [ "$(id -u)" -ne 0 ]; then
  fw_die "host-setup --apply must run as root"
fi

fw_require_confirmation "Type 'setup' to install packages and create directories:" "setup"

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y --no-install-recommends \
  ca-certificates \
  curl \
  git \
  gzip \
  rsync \
  age \
  docker.io \
  docker-compose-v2 \
  unattended-upgrades

systemctl enable --now docker

if ! id "$DEPLOY_USER" >/dev/null 2>&1; then
  useradd --create-home --shell /bin/bash "$DEPLOY_USER"
fi
usermod -aG docker "$DEPLOY_USER"

mkdir -p "$SRV_DIR" \
  "$DATA_ROOT/postgres" \
  "$DATA_ROOT/caddy" \
  "$DATA_ROOT/caddy-config" \
  "$DATA_ROOT/backups" \
  "$DATA_ROOT/backup-git"

chown -R "$DEPLOY_USER:$DEPLOY_USER" "$SRV_DIR" "$DATA_ROOT"
chmod 700 "$DATA_ROOT" "$DATA_ROOT/postgres" "$DATA_ROOT/backups" "$DATA_ROOT/backup-git"
chmod 755 "$SRV_DIR"

if [ -d /etc/apt/apt.conf.d ]; then
  cat >/etc/apt/apt.conf.d/20auto-upgrades <<'APT'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
APT
fi

fw_log "host-setup complete. Next: copy .env (mode 600), sshd hardening from docs/operations.md"
