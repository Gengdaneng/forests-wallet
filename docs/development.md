# Development

Application HTTP service for Forrest's Wallet. Product requirements stay in the root `README.md`. Operations files (`compose.yaml`, `Caddyfile`, `.env.example`, `ops/`, `docs/operations.md`) are owned by a separate change.

## Shape

- Listens on `0.0.0.0:3000`
- `GET /healthz` → `{"ok":true}` or generic `503 {"ok":false}`
- Runtime `DATABASE_URL` (role `forests_wallet_runtime`)
- Migrations: `MIGRATE_DATABASE_URL` or `DATABASE_URL` as the schema owner `forests_wallet_migrator`
- Root `Dockerfile` starts `node dist/server.js`

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
node dist/cli.js migrate
```

The runtime role cannot DDL and cannot `UPDATE`/`DELETE` `transactions`.

## Commands

```
npm ci
npm run lint
npm run typecheck
npm test
npm run build
node dist/cli.js migrate
node dist/cli.js open-bootstrap
node dist/cli.js revoke-all-parent-devices
docker build -t forests-wallet-app .
```

Tests start an ephemeral Postgres 18 container. Docker must be running.

`FORESTS_WALLET_TEST_ROUTES=1` enables `POST /v1/_test/idempotent-echo` for the write-idempotency contract. Do not enable that in production.

## Operator CLI (application-owned)

Run inside the app environment with the runtime `DATABASE_URL`:

- `open-bootstrap` — opens parent registration for 30 minutes; refuses if an active parent device exists
- `revoke-all-parent-devices` — lost-phone recovery; then `open-bootstrap`
