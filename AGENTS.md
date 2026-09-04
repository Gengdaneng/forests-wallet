# Agent notes

Forrest's Wallet backend is a small TypeScript HTTP service (Node built-in `http` + `pg`). Do not add an HTTP framework, ORM, queue, Redis, or worker.

## Commands

- `npm run lint`, `npm run typecheck`, `npm test`, `npm run build`
- `fw migrate` (`MIGRATE_DATABASE_URL` only; schema owner)
- `fw open-bootstrap` / `fw revoke-parent-devices` (runtime `DATABASE_URL`)
- App contract: `0.0.0.0:3000`, `GET /healthz`, runtime `DATABASE_URL`, root `Dockerfile` CMD, `fw` on PATH

See `docs/development.md` for roles, migrations, and local Docker tests.

## Boundaries

- Do not implement ledger/check-in/goal/settlement/snapshot product routes until a later slice.
- Operations files (`compose.yaml`, `Caddyfile`, `.env.example`, `ops/`, `docs/operations.md`) are owned elsewhere.
- The root `README.md` is the PRD; do not silently absorb architecture-review edits into it.

## iOS

Native SwiftUI UI is in `ios/` (universal iPhone parent / iPad child, sample data only). Design-system source is `DesignSystem/Reference/` — design input, do not execute bundled JS. See `ios/README.md`.

## Maintaining this file

Keep this file for knowledge useful to almost every future agent session in this project.
Do not repeat what the codebase already shows; point to the authoritative file or command instead.
Prefer rewriting or pruning existing entries over appending new ones.
When updating this file, preserve this bar for all agents and keep entries concise.
