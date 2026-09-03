# Development

Application HTTP service for Forrest's Wallet. Product requirements stay in the root `README.md`. Operations files (`compose.yaml`, `Caddyfile`, `.env.example`, `ops/`, `docs/operations.md`) are owned by a separate change.

## Shape

- Listens on `0.0.0.0:3000`
- `GET /healthz` → `{"ok":true}` or generic `503 {"ok":false}`
- Runtime `DATABASE_URL` (role `forests_wallet_runtime`)
- Migrations: `fw migrate` with `MIGRATE_DATABASE_URL` (schema owner `forests_wallet_migrator`)
- Runtime process: `DATABASE_URL` only
- Root `Dockerfile` starts `node dist/server.js` and puts `fw` on PATH

## Database roles

Create the database as a superuser, then migrate as the owner:

```sql
CREATE ROLE forests_wallet_migrator LOGIN PASSWORD '...';
CREATE ROLE forests_wallet_runtime LOGIN PASSWORD '...' NOSUPERUSER NOCREATEDB NOCREATEROLE;
CREATE DATABASE forests_wallet OWNER forests_wallet_migrator;
```

```
MIGRATE_DATABASE_URL=postgres://forests_wallet_migrator:.../forests_wallet
DATABASE_URL=postgres://forests_wallet_runtime:.../forests_wallet
fw migrate
```

The runtime role cannot DDL and cannot `UPDATE`/`DELETE` `transactions`.

## Commands

```
npm ci
npm run lint
npm run typecheck
npm test
npm run build
fw migrate
fw open-bootstrap
fw revoke-parent-devices
docker build -t forests-wallet-app .
```

Tests start an ephemeral Postgres 18 container. Docker must be running.

`FORESTS_WALLET_TEST_ROUTES=1` enables `POST /v1/_test/idempotent-echo` for the write-idempotency contract. Do not enable that in production.

## Operator CLI (application-owned)

Canonical image commands (`fw` on PATH). The long-running app container uses runtime `DATABASE_URL` only; inject `MIGRATE_DATABASE_URL` solely for `fw migrate`.

- `fw migrate` — apply numbered SQL migrations as the schema owner
- `fw open-bootstrap` — opens parent registration for 30 minutes; refuses if an active parent device exists
- `fw revoke-parent-devices` — lost-phone recovery; then `fw open-bootstrap`
