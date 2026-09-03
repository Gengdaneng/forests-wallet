#!/usr/bin/env bash
# Operations acceptance checks. Never installs packages.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
failed=0
ran=0

printf 'Forrest Wallet ops tests\n'

for t in "$ROOT"/test_*.sh; do
  [ -f "$t" ] || continue
  ran=$((ran + 1))
  printf '\n== %s ==\n' "$(basename "$t")"
  if bash "$t"; then
    :
  else
    failed=$((failed + 1))
  fi
done

printf '\n== summary ==\n'
printf 'suites=%s failed=%s\n' "$ran" "$failed"
if [ "$failed" -ne 0 ]; then
  exit 1
fi
printf 'all ops suites passed\n'
