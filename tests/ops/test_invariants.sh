#!/usr/bin/env bash
TEST_NAME=test_invariants
# shellcheck source=helpers.sh
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/helpers.sh"

SQL="$OPS_ROOT/restore-invariants.sql"

grep -q 'RAISE EXCEPTION' "$SQL" && pass "invariants raise on failure" || fail "invariants.sql never RAISE EXCEPTION"

if ! have_cmd docker; then
  skip "live invariant postgres (docker not available)"
  finish
fi

run_psql_file() {
  local name="$1"
  local file="$2"
  docker exec -i "$name" psql -U restore -d restore -v ON_ERROR_STOP=1 <"$file"
}

wait_pg() {
  local name="$1"
  local i=0
  while [ "$i" -lt 30 ]; do
    if docker exec "$name" pg_isready -U restore -d restore >/dev/null 2>&1; then
      return 0
    fi
    i=$((i + 1))
    sleep 1
  done
  return 1
}

start_pg() {
  docker run -d --name "$1" \
    -e POSTGRES_USER=restore \
    -e POSTGRES_PASSWORD=restore \
    -e POSTGRES_DB=restore \
    postgres:18 >/dev/null
}

NAME="fw-inv-$$"
NAME2="fw-inv-bad-$$"
cleanup() {
  docker rm -f "$NAME" "$NAME2" >/dev/null 2>&1 || true
}
trap cleanup EXIT

if ! start_pg "$NAME"; then
  fail "could not start throwaway postgres:18"
  finish
fi
if ! wait_pg "$NAME"; then
  fail "throwaway postgres did not become ready"
  finish
fi

err="$(mktemp)"
if run_psql_file "$NAME" "$FIXTURES/dump.sql" >/dev/null 2>"$err"; then
  pass "valid dump loads"
else
  fail "valid dump failed to load: $(tr '\n' ' ' <"$err")"
fi

if run_psql_file "$NAME" "$SQL" >/dev/null 2>"$err"; then
  pass "invariants pass on valid ledger"
else
  fail "invariants failed on valid dump: $(tr '\n' ' ' <"$err")"
fi

if docker exec -i "$NAME" psql -U restore -d restore -v ON_ERROR_STOP=1 \
  -c "INSERT INTO transactions VALUES ('00000000-0000-0000-0000-000000000099', 1);" \
  >/dev/null 2>"$err"; then
  pass "inserted corrupt row"
else
  fail "could not insert corrupt row: $(tr '\n' ' ' <"$err")"
fi

if run_psql_file "$NAME" "$SQL" >/dev/null 2>"$err"; then
  fail "invariants exited 0 on corrupt ledger"
else
  pass "invariants fail on non-integer-yuan row"
fi

if start_pg "$NAME2" && wait_pg "$NAME2"; then
  run_psql_file "$NAME2" "$FIXTURES/invalid-dump.sql" >/dev/null 2>/dev/null || true
  if run_psql_file "$NAME2" "$SQL" >/dev/null 2>/dev/null; then
    fail "invariants passed on invalid-dump.sql fixture"
  else
    pass "invalid-dump.sql fixture fails restore invariants"
  fi
else
  skip "second throwaway postgres"
fi

rm -f "$err"
finish
