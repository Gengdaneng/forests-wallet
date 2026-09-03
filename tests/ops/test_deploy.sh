#!/usr/bin/env bash
TEST_NAME=test_deploy
# shellcheck source=helpers.sh
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/helpers.sh"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

export FW_SSH_LOG="$TMP/ssh.log"
export FW_RSYNC_LOG="$TMP/rsync.log"
export PATH="$STUBS:$PATH"

env_ok="$TMP/deploy.env"
make_secret_env "$env_ok" <<EOF
DEPLOY_SSH=deploy@203.0.113.10
DEPLOY_PATH=/srv/forests-wallet
DOMAIN=wallet.example.com
EOF

if FW_ENV="$TMP/missing.env" "$OPS_ROOT/deploy.sh" >/dev/null 2>"$TMP/missing.err"; then
  fail "deploy without env file should fail"
else
  pass "deploy refuses missing env file"
fi

chmod 644 "$env_ok"
if FW_ENV="$env_ok" "$OPS_ROOT/deploy.sh" >/dev/null 2>"$TMP/mode.err"; then
  fail "deploy should refuse mode 644 env"
else
  pass "deploy refuses group/world-readable env"
fi
chmod 600 "$env_ok"

if FW_ENV="$env_ok" "$OPS_ROOT/deploy.sh" >"$TMP/dry.out" 2>"$TMP/dry.err"; then
  pass "deploy default is dry-run success"
else
  fail "deploy dry-run failed: $(tr '\n' ' ' <"$TMP/dry.err")"
fi

if [ -f "$FW_SSH_LOG" ] || [ -f "$FW_RSYNC_LOG" ]; then
  fail "dry-run invoked ssh or rsync"
else
  pass "dry-run did not invoke ssh/rsync"
fi
grep -q "dry-run complete" "$TMP/dry.err" && pass "dry-run announced itself" || fail "dry-run log missing"
grep -q "init-db-roles" "$TMP/dry.err" && pass "dry-run plans role bootstrap" || fail "dry-run missing init-db-roles"
grep -q "fw migrate" "$TMP/dry.err" && pass "dry-run plans fw migrate" || fail "dry-run missing fw migrate"
grep -q "app node" "$TMP/dry.err" && pass "dry-run plans app node healthz" || fail "dry-run missing app node health"
if grep -q "caddy curl" "$TMP/dry.err"; then
  fail "dry-run still mentions caddy curl"
else
  pass "dry-run does not use caddy curl"
fi

if FW_ENV="$env_ok" "$OPS_ROOT/deploy.sh" --apply >"$TMP/apply.out" 2>"$TMP/apply.err"; then
  fail "unattended --apply without --yes should fail"
else
  pass "unattended --apply without --yes refused"
fi
if [ -f "$FW_SSH_LOG" ] || [ -f "$FW_RSYNC_LOG" ]; then
  fail "--apply without confirmation invoked ssh/rsync"
else
  pass "--apply without confirmation did not invoke ssh/rsync"
fi

badref="$TMP/badref.env"
make_secret_env "$badref" <<EOF
DEPLOY_SSH=deploy@203.0.113.10
DEPLOY_PATH=/srv/forests-wallet
DOMAIN=wallet.example.com
DEPLOY_EXPECTED_REF=this-ref-does-not-exist
EOF
if FW_ENV="$badref" "$OPS_ROOT/deploy.sh" >/dev/null 2>"$TMP/badref.err"; then
  fail "deploy should refuse unexpected DEPLOY_EXPECTED_REF"
else
  pass "deploy refuses unexpected source revision"
fi

finish
