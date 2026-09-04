# Agent notes

Public Forrest's Wallet tree: native SwiftUI iPhone (parent) / iPad (child) app plus design-system reference. Auth talks to `https://wallet.gengdaneng.com`; ledger stays in-memory sample data.

## Scope

- `ios/` — universal target. See `ios/README.md` for auth/sample mode, Keychain tokens, launch arguments, and `xcodebuild` commands.
- `DesignSystem/Reference/` — design input. Do not run bundled JavaScript.
- Production backend is private. Do not add a server, database, or hosting operations here.

## Maintaining this file

Keep this file for knowledge useful to almost every future agent session in this project.
Do not repeat what the codebase already shows; point to the authoritative file or command instead.
Prefer rewriting or pruning existing entries over appending new ones.
When updating this file, preserve this bar for all agents and keep entries concise.
