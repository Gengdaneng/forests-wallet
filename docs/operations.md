# Forrest's Wallet — VPS operations

Solo-parent runbook for the family pilot. One VPS, three containers, no
orchestrator, no GitHub Actions, no OpenTofu.

**Never paste any of these into chat or git:**

- Hetzner API token
- SSH private key
- database password / `DATABASE_URL`
- `age` private identity (`AGE-SECRET-KEY-...`)
- healthchecks.io ping URL

Keep them in a password manager. Keep a paper copy of the `age` private
identity at home (captain choice: password-manager-plus-paper).

---

## Shape

```
Internet → Hetzner Cloud Firewall (22/80/443 only, IPv4+IPv6)
        → Caddy (automatic public TLS on a real domain)
        → app:3000 (Compose network only)
        → postgres:18 (Compose network only; bind-mounted data)
```

Exactly three long-running services: `caddy`, `app`, `postgres`. Only Caddy
publishes host ports 80 and 443. Postgres data lives on
`POSTGRES_DATA_DIR` so `docker compose down -v` cannot erase the ledger.

Host UFW is **not** the firewall. Docker writes its own iptables/nftables
rules for published ports; UFW on the VM can allow a published port that
you thought was closed. The bound is the **provider Cloud Firewall**
outside the VM.

---

## 1. First server (Hetzner console)

This repo does not create cloud resources. Click in the console.

1. Add **your** SSH **public** key (the Mac's). Never upload a private key.
2. Create a **Cloud Firewall** (not a software firewall on the box):
   - Inbound TCP 22, 80, 443 from `0.0.0.0/0` and `::/0`
   - No 5432, no 3000, no 2019
   - IPv4 **and** IPv6 — Caddy publishes both
3. Create a server:
   - Type: **CAX11**-class (Ampere ARM, 2 vCPU / 4 GB is enough)
   - Image: newest **Ubuntu LTS** listed (24.04 or a newer LTS if shown).
     Not Fedora, not beta.
   - Attach the firewall; enable IPv4 and IPv6
   - Location: pick after you have measured latency from the household
     network; do not guess a region from this document
4. **Buy a domain before public exposure** (captain choice: this week).
   Caddy's unattended public ACME is hostname-based. Let's Encrypt *can*
   issue short-lived IP certs; that is not this setup.
5. DNS at the same provider: `A` to the IPv4, `AAAA` to the IPv6.
6. Do not point the devices at the box until DNS answers and Caddy has a
   publicly trusted certificate.

---

## 2. SSH posture and host packages

Log in as root **once** with the key, create `deploy`, then stop using root.

```sh
# as root, after the first key login works
adduser --disabled-password --gecos '' deploy
mkdir -p /home/deploy/.ssh
cp /root/.ssh/authorized_keys /home/deploy/.ssh/authorized_keys
chown -R deploy:deploy /home/deploy/.ssh
chmod 700 /home/deploy/.ssh
chmod 600 /home/deploy/.ssh/authorized_keys
```

**Open a second terminal** and confirm `ssh deploy@<host>` works. Only then
write `/etc/ssh/sshd_config.d/50-forests-wallet.conf`:

```
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin no
PubkeyAuthentication yes
```

`systemctl reload ssh` (or `ssh.service`). Do not reload until the second
session works.

Then, still as root:

```sh
sudo bash /srv/forests-wallet/ops/host-setup.sh --apply --yes
```

(or copy `ops/host-setup.sh` over first). That script installs `docker.io`,
`docker-compose-v2`, `age`, `git`, `rsync`, `unattended-upgrades`, and creates:

| Path | Why |
|---|---|
| `/srv/forests-wallet` | compose project (rsync target) |
| `/var/lib/forests-wallet/postgres` | PG 18 bind mount (`/var/lib/postgresql` in the container) |
| `/var/lib/forests-wallet/caddy` | ACME certificates |
| `/var/lib/forests-wallet/backups` | 30-day local ciphertext |
| `/var/lib/forests-wallet/backup-git` | separate git repo of ciphertext |

It does **not** enable UFW and does **not** change sshd.

Copy `.env.example` to `/srv/forests-wallet/.env`, fill real values, then:

```sh
chmod 600 /srv/forests-wallet/.env
chown deploy:deploy /srv/forests-wallet/.env
```

`POSTGRES_PASSWORD` in `.env` must match the password embedded in
`DATABASE_URL`.

---

## 3. Application CLI contract

The app image (Dockerfile is owned by the application change) must:

- listen on `0.0.0.0:3000`
- serve `GET /healthz` → `200 {"ok": true}` or `503`, no versions/counts
- read `DATABASE_URL`
- put `fw` on `PATH` with:
  - `fw migrate` — numbered SQL migrations, idempotent
  - `fw open-bootstrap` — `bootstrap_open_until = now() + 30 minutes`
  - `fw revoke-parent-devices` — revoke every parent device

Ops scripts only invoke that CLI. Do not `psql` tokens or bootstrap flags.

---

## 4. First deploy (from the Mac)

Captain choice: `deploy.sh` through the three-week pilot. No GitHub Actions
deploy key on the server.

On the Mac, `chmod 600 ~/.config/forests-wallet/deploy.env` with
`DEPLOY_SSH`, `DEPLOY_PATH`, `DOMAIN`, optional `DEPLOY_EXPECTED_REF`.

```sh
export FW_ENV="$HOME/.config/forests-wallet/deploy.env"
./ops/deploy.sh                 # dry-run: validates, mutates nothing
./ops/deploy.sh --apply         # types 'deploy' to confirm
./ops/deploy.sh --apply --yes   # unattended, still explicit
```

What `--apply` does:

1. Refuses a dirty tracked worktree and (if set) a HEAD that is not
   `DEPLOY_EXPECTED_REF`
2. rsyncs **tracked** files only (never `.env`)
3. On the VPS: `docker compose build`, wait for Postgres, `fw migrate`,
   `docker compose up -d`, wait for `http://app:3000/healthz` from Caddy
4. Writes `.deployed-revision` and keeps `.previous-revision`

Rollback:

```sh
ssh deploy@<host> 'cd /srv/forests-wallet && ./ops/rollback.sh --apply'
# or:
# APP_IMAGE_TAG=$(cat .previous-revision) docker compose --env-file .env up -d app
```

Re-running `./ops/deploy.sh --apply` from the previous git revision also
works.

---

## 5. Parent bootstrap and lost-phone recovery

Policy: **one active device per role** (captain choice). A new pairing of
the same role revokes the previous.

First parent iPhone:

```sh
ssh deploy@<host> 'cd /srv/forests-wallet && ./ops/open-bootstrap.sh --apply'
```

Then `POST /v1/bootstrap` from the phone. The window must close on success
or after 30 minutes.

Lost iPad: parent app issues a new pairing code and revokes the old child
device. No SSH.

Lost iPhone:

```sh
ssh deploy@<host> 'cd /srv/forests-wallet && ./ops/revoke-parent-devices.sh --apply'
ssh deploy@<host> 'cd /srv/forests-wallet && ./ops/open-bootstrap.sh --apply'
```

Register the replacement phone within 30 minutes. Hashed tokens in Postgres
stay revoked.

---

## 6. Daily backup

On the VPS, as `deploy`, after `backup-git` is a **separate** private repo
(not this code repo) with `origin` set and GitHub host key in
`known_hosts`:

```sh
# crontab -e  (deploy user)
15 3 * * * /srv/forests-wallet/ops/backup.sh --apply --yes >> /var/lib/forests-wallet/backup.log 2>&1
```

`ops/backup.sh`:

1. `pg_dump --format=plain` (streamed; plaintext never hits disk)
2. optional gzip (`BACKUP_COMPRESS=1`)
3. `age -r "$AGE_RECIPIENT"` — **public** recipient only
4. copy ciphertext into `BACKUP_GIT_DIR`, `git add` only `*.age`, commit, push
5. delete `forests-wallet-*.age` under `BACKUP_LOCAL_DIR` older than
   `BACKUP_RETENTION_DAYS` (refuses to prune outside that directory)
6. ping `HEALTHCHECKS_URL` **only if every prior step succeeded**

Generate the age key **on the Mac**, never on the VPS:

```sh
age-keygen -o ~/.config/forests-wallet/backup-age.key
chmod 600 ~/.config/forests-wallet/backup-age.key
# Put the private identity in the password manager and on paper.
# Put only the age1... public line in the VPS .env as AGE_RECIPIENT.
```

A VPS SSH key used to push backups is for that backup remote only. It is
not a GitHub deploy key for this application repository.

---

## 7. Weekly Mac restore test

Before Forrest's iPad is installed, this must have succeeded once.

```sh
export FW_ENV="$HOME/.config/forests-wallet/restore.env"
./ops/restore-test.sh --throwaway                 # dry-run
./ops/restore-test.sh --throwaway --apply --yes
```

It clones/pulls the **backup** remote, decrypts with the Mac age identity,
loads a disposable `postgres:18` on an isolated Docker network (no host
ports, not `POSTGRES_DATA_DIR`), runs `ops/restore-invariants.sql`, and
destroys the throwaway. Production is never in the path.

launchd (optional): a weekly `StartCalendarInterval` that runs the same
`--throwaway --apply --yes` command. Keep the plist out of git if it
contains paths to secrets.

---

## 8. Dead VPS rebuild

Tokens are SHA-256 hashes in Postgres. If the dump restores, existing
devices keep working.

1. New CAX11 + Cloud Firewall + same SSH public key (section 1)
2. Section 2 host setup; new `/srv/forests-wallet/.env` (new host, **same**
   `POSTGRES_*` only if you want; they are not in the dump's server auth —
   the dump has the ledger, including `token_hash` rows)
3. Restore the newest ciphertext **into this new Postgres before**
   `compose up` of Caddy-to-the-world:
   - decrypt on the Mac, or decrypt on the new VPS **without** copying the
     age private identity there (decrypt on the Mac, scp the plain SQL over
     a pipe, wipe it)
   - `psql` into the new bind-mounted data dir
4. `ops/deploy.sh --apply` (or rsync + compose up)
5. Point DNS A/AAAA at the new addresses; wait for TTL
6. Caddy obtains new certificates
7. Confirm `GET https://$DOMAIN/healthz` and that parent/child tokens still
   authenticate

If the dump is gone, stop. Do not invent an opening balance. Tell Forrest
the truth.

---

## 9. Smallest recovery commands

```sh
docker compose --env-file .env ps
docker compose --env-file .env logs --tail=100 app
docker compose --env-file .env exec -T caddy curl -fsS http://app:3000/healthz
docker compose --env-file .env restart app
```

Do not `docker compose down -v`. The bind mount should survive `down -v`,
but there is no reason to pass `-v`.

---

## 10. Operator wallet card

Password manager, and nothing else:

1. SSH key + VPS IPv4/IPv6 + domain
2. `age` private identity + paper copy
3. GitHub 2FA for the **backup** repo
4. healthchecks.io login
5. Commands: `open-bootstrap.sh`, `revoke-parent-devices.sh`, `restore-test.sh`
6. Proof that a dump restored onto throwaway Postgres and
   `COUNT(*)` on `transactions` matched

If step 6 has never succeeded, Forrest does not get the iPad.

---

## 11. Ops tests (this repository)

From the repo root, no extra packages are installed:

```sh
./tests/ops/run.sh
```

Missing optional tools (`shellcheck`, `caddy`, Docker images) are reported
and skipped. `docker compose config` and Caddy validate run when present.
