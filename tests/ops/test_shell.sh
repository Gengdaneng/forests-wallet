#!/usr/bin/env bash
TEST_NAME=test_shell
# shellcheck source=helpers.sh
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/helpers.sh"

scripts=""
for f in "$OPS_ROOT"/*.sh "$TESTS_OPS"/run.sh "$TESTS_OPS"/test_*.sh; do
  [ -f "$f" ] || continue
  scripts="$scripts $f"
  if bash -n "$f"; then
    pass "bash -n $(basename "$f")"
  else
    fail "bash -n $(basename "$f")"
  fi
done

if have_cmd shellcheck; then
  # shellcheck disable=SC2086
  if shellcheck -s bash -x "$OPS_ROOT/lib.sh" $scripts; then
    pass "shellcheck"
  else
    fail "shellcheck reported issues"
  fi
else
  skip "shellcheck (not installed; not installing)"
fi

finish
