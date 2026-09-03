#!/usr/bin/env bash
TEST_NAME=test_backup
# shellcheck source=helpers.sh
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/helpers.sh"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

export PATH="$STUBS:$PATH"
export FW_CURL_LOG="$TMP/curl.log"
export FW_PG_DUMP="cat \"$FIXTURES/dump.sql\""

git_src="$TMP/backup-git"
git_remote="$TMP/backup-remote.git"
local_dir="$TMP/backups"
outside="$TMP/outside"
mkdir -p "$local_dir" "$outside" "$git_src"
echo keep-outside >"$outside/secret.txt"
echo keep-local >"$local_dir/notes.txt"

git init --bare --quiet "$git_remote"
git init --quiet "$git_src"
git -C "$git_src" checkout -b main >/dev/null 2>&1 || git -C "$git_src" checkout -b master >/dev/null 2>&1 || true
git -C "$git_src" -c user.email=t@t -c user.name=t commit --allow-empty -m init >/dev/null

envfile="$TMP/backup.env"
make_secret_env "$envfile" <<EOF
POSTGRES_USER=forests
POSTGRES_PASSWORD=supersecret-db-password
POSTGRES_DB=forests_wallet
AGE_RECIPIENT=age1examplepublicrecipientxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
BACKUP_LOCAL_DIR=$local_dir
BACKUP_GIT_DIR=$git_src
BACKUP_GIT_REMOTE=$git_remote
BACKUP_RETENTION_DAYS=30
BACKUP_COMPRESS=1
HEALTHCHECKS_URL=https://hc-ping.com/secret-ping-uuid-do-not-log
EOF

if FW_ENV="$envfile" "$OPS_ROOT/backup.sh" >"$TMP/dry.out" 2>"$TMP/dry.err"; then
  pass "backup default is dry-run"
else
  fail "backup dry-run failed: $(tr '\n' ' ' <"$TMP/dry.err")"
fi
if [ -f "$FW_CURL_LOG" ]; then
  fail "dry-run pinged healthchecks"
else
  pass "dry-run did not ping healthchecks"
fi
if ls "$local_dir"/forests-wallet-*.age >/dev/null 2>&1; then
  fail "dry-run wrote a backup file"
else
  pass "dry-run wrote no backup files"
fi

if FW_ENV="$envfile" "$OPS_ROOT/backup.sh" --apply --yes >"$TMP/ok.out" 2>"$TMP/ok.err"; then
  pass "backup --apply succeeded"
else
  fail "backup --apply failed: $(tr '\n' ' ' <"$TMP/ok.err")"
fi

if [ -f "$FW_CURL_LOG" ]; then
  pass "success ping sent"
else
  fail "success did not ping healthchecks"
fi

age_files="$(git -C "$git_src" ls-files '*.age' || true)"
other="$(git -C "$git_src" ls-files | grep -v '\.age$' | grep -v '^$' || true)"
[ -n "$age_files" ] && pass "git contains ciphertext" || fail "git missing .age files"
[ -z "$other" ] && pass "git contains only ciphertext paths" || fail "git has non-age files: $other"

cipher="$(ls "$local_dir"/forests-wallet-*.age | head -n 1)"
if grep -q "PostgreSQL database dump" "$cipher"; then
  fail "plaintext dump reached local backup dir"
else
  pass "local backup is not plaintext SQL"
fi
staged_copy="$(git -C "$git_src" ls-files '*.age' | head -n 1)"
if git -C "$git_src" show "HEAD:$staged_copy" | grep -q "PostgreSQL database dump"; then
  fail "plaintext dump was git-staged"
else
  pass "git object is not plaintext SQL"
fi

if grep -q "supersecret-db-password" "$TMP/ok.err" || grep -q "secret-ping-uuid-do-not-log" "$TMP/ok.err"; then
  fail "backup logs leaked a secret"
else
  pass "backup logs redacted secrets"
fi

# Failed dump must not ping.
rm -f "$FW_CURL_LOG"
export FW_PG_DUMP="false"
if FW_ENV="$envfile" "$OPS_ROOT/backup.sh" --apply --yes >/dev/null 2>"$TMP/dumpfail.err"; then
  fail "backup should fail when dump fails"
else
  pass "backup fails when dump fails"
fi
if [ -f "$FW_CURL_LOG" ]; then
  fail "failed dump still pinged healthchecks"
else
  pass "failed dump did not ping"
fi

# Failed encryption must not ping.
export FW_PG_DUMP="cat \"$FIXTURES/dump.sql\""
export FW_AGE_FAIL=1
rm -f "$FW_CURL_LOG"
if FW_ENV="$envfile" "$OPS_ROOT/backup.sh" --apply --yes >/dev/null 2>"$TMP/agefail.err"; then
  fail "backup should fail when age fails"
else
  pass "backup fails when encryption fails"
fi
if [ -f "$FW_CURL_LOG" ]; then
  fail "failed encryption still pinged"
else
  pass "failed encryption did not ping"
fi
unset FW_AGE_FAIL

# Failed push must not ping. Force a new ciphertext so git has something to push.
export FW_PG_DUMP="printf '%s\\n' '-- PostgreSQL database dump' '-- unique-$$'"
bad="$TMP/backup-bad.env"
make_secret_env "$bad" <<EOF
POSTGRES_USER=forests
POSTGRES_PASSWORD=supersecret-db-password
POSTGRES_DB=forests_wallet
AGE_RECIPIENT=age1examplepublicrecipientxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
BACKUP_LOCAL_DIR=$local_dir
BACKUP_GIT_DIR=$git_src
BACKUP_GIT_REMOTE=$TMP/no-such-remote.git
BACKUP_RETENTION_DAYS=30
BACKUP_COMPRESS=1
HEALTHCHECKS_URL=https://hc-ping.com/secret-ping-uuid-do-not-log
EOF
rm -f "$FW_CURL_LOG"
if FW_ENV="$bad" "$OPS_ROOT/backup.sh" --apply --yes >/dev/null 2>"$TMP/pushfail.err"; then
  fail "backup should fail when push fails"
else
  pass "backup fails when push fails"
fi
if [ -f "$FW_CURL_LOG" ]; then
  fail "failed push still pinged"
else
  pass "failed push did not ping"
fi

# Retention must not escape BACKUP_LOCAL_DIR or delete unrelated files.
old="$local_dir/forests-wallet-20000101T000000Z.sql.gz.age"
echo AGE-CIPHERTEXT >"$old"
touch -t 200001010000 "$old"
export FW_PG_DUMP="cat \"$FIXTURES/dump.sql\""
rm -f "$FW_CURL_LOG"
if FW_ENV="$envfile" "$OPS_ROOT/backup.sh" --apply --yes >/dev/null 2>"$TMP/prune.err"; then
  pass "backup with prune succeeded"
else
  fail "backup prune run failed: $(tr '\n' ' ' <"$TMP/prune.err")"
fi
if [ -f "$old" ]; then
  fail "old ciphertext inside root was not pruned"
else
  pass "retention pruned matching files inside root"
fi
[ -f "$outside/secret.txt" ] && pass "retention did not delete files outside root" || fail "outside file vanished"
[ -f "$local_dir/notes.txt" ] && pass "retention did not delete non-backup files" || fail "notes.txt was pruned"

# Broad retention root refused.
broad="$TMP/broad.env"
make_secret_env "$broad" <<EOF
POSTGRES_USER=forests
POSTGRES_PASSWORD=x
POSTGRES_DB=forests_wallet
AGE_RECIPIENT=age1examplepublicrecipientxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
BACKUP_LOCAL_DIR=/tmp
BACKUP_GIT_DIR=$git_src
BACKUP_GIT_REMOTE=$git_remote
BACKUP_RETENTION_DAYS=30
HEALTHCHECKS_URL=https://hc-ping.com/secret-ping-uuid-do-not-log
EOF
if FW_ENV="$broad" "$OPS_ROOT/backup.sh" --apply --yes >/dev/null 2>"$TMP/broad.err"; then
  fail "backup should refuse BACKUP_LOCAL_DIR=/tmp"
else
  pass "backup refuses a too-broad retention root"
fi

finish
