#!/usr/bin/env bash
TEST_NAME=test_cli
# shellcheck source=helpers.sh
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/helpers.sh"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

if "$OPS_ROOT/open-bootstrap.sh" >"$TMP/ob.out" 2>"$TMP/ob.err"; then
  pass "open-bootstrap dry-run"
else
  fail "open-bootstrap dry-run failed"
fi
grep -q "dry-run complete" "$TMP/ob.err" && pass "open-bootstrap is non-mutating by default" || fail "open-bootstrap dry-run log"

if "$OPS_ROOT/open-bootstrap.sh" --apply >/dev/null 2>"$TMP/ob-apply.err"; then
  fail "open-bootstrap --apply without --yes should fail"
else
  pass "open-bootstrap --apply requires confirmation"
fi

if "$OPS_ROOT/revoke-parent-devices.sh" >"$TMP/rv.out" 2>"$TMP/rv.err"; then
  pass "revoke-parent-devices dry-run"
else
  fail "revoke dry-run failed"
fi
if "$OPS_ROOT/revoke-parent-devices.sh" --apply >/dev/null 2>"$TMP/rv-apply.err"; then
  fail "revoke --apply without --yes should fail"
else
  pass "revoke --apply requires confirmation"
fi

if "$OPS_ROOT/host-setup.sh" >"$TMP/hs.out" 2>"$TMP/hs.err"; then
  pass "host-setup dry-run"
else
  fail "host-setup dry-run failed"
fi
if "$OPS_ROOT/init-db-roles.sh" >/dev/null 2>"$TMP/roles-missing.err"; then
  fail "init-db-roles without env should fail"
else
  pass "init-db-roles refuses missing env"
fi

if "$OPS_ROOT/host-setup.sh" --apply >/dev/null 2>"$TMP/hs-apply.err"; then
  fail "host-setup --apply on this Mac should fail"
else
  pass "host-setup --apply refused off Linux / without confirmation"
fi

grep -q "Never paste" "$REPO_ROOT/docs/operations.md" && pass "runbook forbids pasting secrets" || fail "runbook missing paste ban"
for needle in "Hetzner" "Cloud Firewall" "UFW" "CAX11" "password manager" "paper"; do
  if grep -q "$needle" "$REPO_ROOT/docs/operations.md"; then
    pass "runbook mentions $needle"
  else
    fail "runbook missing $needle"
  fi
done

if grep -q 'AGE-SECRET-KEY-' "$REPO_ROOT/docs/operations.md" && grep -v 'AGE-SECRET-KEY-\.\.\.' "$REPO_ROOT/docs/operations.md" | grep -q 'AGE-SECRET-KEY-[A-Z0-9]'; then
  fail "runbook looks like it contains a real age identity"
else
  pass "runbook has no real age identity"
fi

finish
