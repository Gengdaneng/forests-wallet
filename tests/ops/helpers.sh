# shellcheck shell=bash
# Shared assertions for tests/ops. Source from a test script.

set -euo pipefail

TESTS_OPS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$TESTS_OPS/../.." && pwd)"
OPS_ROOT="$REPO_ROOT/ops"
FIXTURES="$TESTS_OPS/fixtures"
STUBS="$TESTS_OPS/stubs"

PASS=0
FAIL=0
SKIP=0
FAILURES=""

pass() {
  PASS=$((PASS + 1))
  printf '  PASS %s\n' "$1"
}

fail() {
  FAIL=$((FAIL + 1))
  FAILURES="$FAILURES
  - $1"
  printf '  FAIL %s\n' "$1"
}

skip() {
  SKIP=$((SKIP + 1))
  printf '  SKIP %s\n' "$1"
}

have_cmd() {
  command -v "$1" >/dev/null 2>&1
}

make_secret_env() {
  local dest="$1"
  cat >"$dest"
  chmod 600 "$dest"
}

finish() {
  printf '\n%s: %s pass, %s fail, %s skip\n' "${TEST_NAME:-test}" "$PASS" "$FAIL" "$SKIP"
  if [ "$FAIL" -ne 0 ]; then
    printf 'failures:%s\n' "$FAILURES"
    exit 1
  fi
  exit 0
}
