#!/usr/bin/env bash
TEST_NAME=test_restore
# shellcheck source=helpers.sh
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/helpers.sh"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

export PATH="$STUBS:$PATH"
export FW_PSQL_LOG="$TMP/psql.log"
export FW_RESTORE_PSQL="$STUBS/psql"

prod_data="$TMP/production-postgres"
mkdir -p "$prod_data"
echo production-marker >"$prod_data/PG_VERSION"

pull="$TMP/backup-pull"
remote="$TMP/backup-remote.git"
mkdir -p "$pull"
git init -b main --quiet "$pull"
git init -b main --bare --quiet "$remote"
{
  echo AGE-CIPHERTEXT
  gzip -c "$FIXTURES/dump.sql"
} >"$pull/forests-wallet-20260101T000000Z.sql.gz.age"
git -C "$pull" add forests-wallet-20260101T000000Z.sql.gz.age
git -C "$pull" -c user.email=t@t -c user.name=t commit -m dump >/dev/null
git -C "$pull" remote add origin "$remote"
git -C "$pull" push -u origin main >/dev/null

ident="$TMP/age.key"
printf 'AGE-SECRET-KEY-TESTONLY\n' >"$ident"
chmod 600 "$ident"

envfile="$TMP/restore.env"
make_secret_env "$envfile" <<EOF
BACKUP_PULL_DIR=$pull
BACKUP_GIT_REMOTE=$remote
AGE_IDENTITY=$ident
POSTGRES_DATA_DIR=$prod_data
EOF

if FW_ENV="$envfile" "$OPS_ROOT/restore-test.sh" >/dev/null 2>"$TMP/nothrow.err"; then
  fail "restore-test without --throwaway should fail"
else
  pass "restore-test refuses to run without --throwaway"
fi

if FW_ENV="$envfile" "$OPS_ROOT/restore-test.sh" --throwaway >"$TMP/dry.out" 2>"$TMP/dry.err"; then
  pass "restore-test --throwaway dry-run"
else
  fail "restore dry-run failed: $(tr '\n' ' ' <"$TMP/dry.err")"
fi
if [ -f "$FW_PSQL_LOG" ]; then
  fail "dry-run invoked psql"
else
  pass "dry-run did not restore anything"
fi
[ -f "$prod_data/PG_VERSION" ] && pass "dry-run left production data dir untouched" || fail "production marker missing"

if FW_ENV="$envfile" "$OPS_ROOT/restore-test.sh" --throwaway --apply --yes >"$TMP/ok.out" 2>"$TMP/ok.err"; then
  pass "restore-test --apply on throwaway"
else
  fail "restore --apply failed: $(tr '\n' ' ' <"$TMP/ok.err")"
fi

grep -q "restored-dump" "$FW_PSQL_LOG" && pass "throwaway received the dump" || fail "psql did not load dump"
grep -q "checked-invariants" "$FW_PSQL_LOG" && pass "throwaway ran ledger invariants" || fail "psql did not run invariants"
[ -f "$prod_data/PG_VERSION" ] && grep -q production-marker "$prod_data/PG_VERSION" && pass "production data dir untouched after restore" || fail "production data dir changed"

# Same path as production data dir for pull → refuse
bad="$TMP/bad.env"
make_secret_env "$bad" <<EOF
BACKUP_PULL_DIR=$prod_data
BACKUP_GIT_REMOTE=$remote
AGE_IDENTITY=$ident
POSTGRES_DATA_DIR=$prod_data
EOF
if FW_ENV="$bad" "$OPS_ROOT/restore-test.sh" --throwaway --apply --yes >/dev/null 2>"$TMP/prod.err"; then
  fail "restore-test should refuse production data dir as pull dir"
else
  pass "restore-test refuses production POSTGRES_DATA_DIR as pull dir"
fi

finish
