#!/usr/bin/env bash
TEST_NAME=test_host_setup
# shellcheck source=helpers.sh
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/helpers.sh"

HS_ERR="$(mktemp)"
HS_OUT="$(mktemp)"
if "$OPS_ROOT/host-setup.sh" >"$HS_OUT" 2>"$HS_ERR"; then
  pass "host-setup dry-run"
else
  fail "host-setup dry-run failed"
fi

grep -q "chmod 755" "$HS_ERR" && grep -q postgres "$HS_ERR" && pass "dry-run plans chmod 755 on postgres mount" || fail "dry-run missing chmod 755 postgres"
grep -q "chmod 700" "$HS_ERR" && grep -q backups "$HS_ERR" && pass "dry-run plans chmod 700 on backup dirs" || fail "dry-run missing chmod 700 backups"

if grep -E 'chmod 700 .*postgres|/postgres".*700' "$OPS_ROOT/host-setup.sh" >/dev/null; then
  fail "host-setup.sh still chmod 700 the postgres mount"
else
  pass "host-setup.sh does not chmod 700 postgres"
fi
grep -q 'chmod 755 "$DATA_ROOT/postgres"' "$OPS_ROOT/host-setup.sh" && pass "host-setup apply chmod 755 postgres" || fail "missing chmod 755 postgres apply line"
grep -q 'chmod 700 "$DATA_ROOT" "$DATA_ROOT/backups" "$DATA_ROOT/backup-git"' "$OPS_ROOT/host-setup.sh" && pass "host-setup apply chmod 700 backups only" || fail "backup chmod 700 line missing or includes postgres"

# Non-TTY SSH examples in the runbook must pass --yes (no prompt).
doc="$REPO_ROOT/docs/operations.md"
ssh_bad=0
while IFS= read -r line; do
  case "$line" in
    *ssh*'--apply'*)
      case "$line" in
        *'--yes'*) ;;
        *)
          fail "non-TTY ssh example missing --yes: $line"
          ssh_bad=1
          ;;
      esac
      ;;
  esac
done <"$doc"
if [ "$ssh_bad" = "0" ]; then
  pass "every ssh --apply example includes --yes"
fi

# Scripts refuse --apply when stdin is not a TTY and --yes is absent.
if "$OPS_ROOT/open-bootstrap.sh" --apply </dev/null >/dev/null 2>"$HS_ERR"; then
  fail "open-bootstrap --apply on non-TTY without --yes should fail"
else
  pass "open-bootstrap --apply refuses non-TTY without --yes"
fi
if "$OPS_ROOT/revoke-parent-devices.sh" --apply </dev/null >/dev/null 2>"$HS_ERR"; then
  fail "revoke --apply on non-TTY without --yes should fail"
else
  pass "revoke --apply refuses non-TTY without --yes"
fi
rb="$(mktemp -d)"
echo local >"$rb/.previous-revision"
make_secret_env "$rb/env" <<EOF
DEPLOY_PATH=$rb
EOF
if FW_ENV="$rb/env" "$OPS_ROOT/rollback.sh" --apply </dev/null >/dev/null 2>"$HS_ERR"; then
  fail "rollback --apply on non-TTY without --yes should fail"
else
  pass "rollback --apply refuses non-TTY without --yes"
fi
rm -rf "$rb"

# Linux-accurate: Postgres 18 uid 999 cannot traverse a 700 bind-mount root
# owned by another user; 755 allows traverse to PGDATA (.../18/docker).
if have_cmd docker; then
  script='
set -e
mkdir -p /mnt/pg700 /mnt/pg755
chown 1000:1000 /mnt/pg700 /mnt/pg755
chmod 700 /mnt/pg700
chmod 755 /mnt/pg755
mkdir -p /mnt/pg700/18/docker /mnt/pg755/18/docker
chown postgres:postgres /mnt/pg700/18/docker /mnt/pg755/18/docker
chmod 700 /mnt/pg700/18/docker /mnt/pg755/18/docker
if gosu postgres test -x /mnt/pg700; then
  echo TRAVERSE_700=yes
else
  echo TRAVERSE_700=no
fi
if gosu postgres test -x /mnt/pg755; then
  echo TRAVERSE_755=yes
else
  echo TRAVERSE_755=no
fi
if gosu postgres touch /mnt/pg755/18/docker/ok 2>/dev/null; then
  echo WRITE_755_PGDATA=yes
else
  echo WRITE_755_PGDATA=no
fi
'
  out="$(docker run --rm postgres:18 bash -c "$script" 2>/dev/null || true)"
  printf '%s\n' "$out" | grep -q 'TRAVERSE_700=no' && pass "uid 999 cannot traverse chmod 700 postgres root" || fail "expected TRAVERSE_700=no; got $out"
  printf '%s\n' "$out" | grep -q 'TRAVERSE_755=yes' && pass "uid 999 can traverse chmod 755 postgres root" || fail "expected TRAVERSE_755=yes; got $out"
  printf '%s\n' "$out" | grep -q 'WRITE_755_PGDATA=yes' && pass "uid 999 can write PGDATA under 755 mount root" || fail "expected WRITE_755_PGDATA=yes; got $out"
else
  skip "PG18 uid 999 permission regression (docker not available)"
fi

rm -f "$HS_ERR" "$HS_OUT"
finish
