# Forrest's Wallet

Family virtual allowance ledger for Forrest on iPad and a parent on iPhone.
It records numbers only — it does not hold, move, or custody real money.

This repository is the open-source native iPhone/iPad app and its design-system reference.

## Current scope

One universal SwiftUI target. Authentication talks to `https://wallet.gengdaneng.com`; ledger state is still local in-memory sample data:

- **iPhone** — parent surface (register, record, board, settle, history, settings)
- **iPad** — Forrest's surface (read-only home, board, rules, wishes)

The first launch is unpaired unless a Keychain session already exists. On iPhone, register as parent (an operator must open the bootstrap window first). On iPad, enter the six-digit pairing code from the parent device.

Tokens live in the Keychain only. Launch arguments (`-FWRoleParent`, `-FWRoleChild`, `-FWUnpaired`, `-FWOffline`) keep deterministic sample mode for tests and do not require a live server. Details: [`ios/README.md`](ios/README.md).

The production backend is maintained privately and is not in this tree.

## Requirements

- Xcode 26.6 / Swift 6.3.3
- iOS 17+ simulator (no signing team required)

## Open and run

```
open ios/ForestsWallet.xcodeproj
```

Pick an iPhone simulator for the parent surface, or an iPad simulator for Forrest's surface.

Launch arguments and screen layout are documented in [`ios/README.md`](ios/README.md).

## Build and test

From the repo root:

```
xcodebuild -project ios/ForestsWallet.xcodeproj -scheme ForestsWallet -destination 'platform=iOS Simulator,name=iPhone 17' test
xcodebuild -project ios/ForestsWallet.xcodeproj -scheme ForestsWallet -destination 'platform=iOS Simulator,name=iPad Pro 11-inch (M5)' test
```

Generic simulator compile:

```
xcodebuild -project ios/ForestsWallet.xcodeproj -scheme ForestsWallet -destination 'generic/platform=iOS Simulator' build
```

## Layout

- `ios/` — native SwiftUI app, sample store, auth client, unit and UI tests
- `DesignSystem/` — visual and interaction authority (extracted reference source)

## Design system

Provenance and usage rules live in [`DesignSystem/README.md`](DesignSystem/README.md). `DesignSystem/Reference/` is design input, not an executable tool; do not run the bundled JavaScript.
Native SwiftUI tokens and components in `ios/` translate that system rather than wrapping it.
