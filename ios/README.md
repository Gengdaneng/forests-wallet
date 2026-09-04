# Forrest's Wallet · iOS

Native SwiftUI app for iPhone (parent) and iPad (child). One universal target.

Design authority: `DesignSystem/Reference/` (extracted design-system source). Do not run the bundled JavaScript.

## Auth and sample mode

Production talks only to `https://wallet.gengdaneng.com`. Parent registration (`POST /v1/bootstrap`) succeeds only while an operator-opened bootstrap window is active. A parent then creates a six-digit pairing code; Forrest's iPad claims it.

Bearer token, device ID, and role are stored in the Keychain. They are never written to `UserDefaults`, source files, logs, screenshots, analytics, or UI-test arguments. Clearing pairing / a rejected token removes the Keychain session.

Paired production sessions load `GET /v1/snapshot` into parent/child home, history, and related screens, and parent writes go to `POST /v1/transactions` (and correction when the existing 更正 flow is used). Launch arguments keep deterministic in-memory sample mode for previews, unit tests, and UI tests — the test suite does not need a live server:

- `-FWRoleParent` — skip bootstrap, open parent home
- `-FWRoleChild` — skip pairing/welcome, open child home
- `-FWUnpaired` — force the pairing/bootstrap path
- `-FWOffline` — parent writes are refused

Without those flags, a normal app launch uses the real auth client. Absent Keychain credentials, routing stays unpaired by device: iPhone registers as parent, iPad enters a pairing code.

## Requirements

- Xcode 26.6 / Swift 6.3.3
- iOS 17+ simulator (no signing team required)

## Open and run

```
open ios/ForestsWallet.xcodeproj
```

Pick an iPhone simulator for the parent surface, or an iPad simulator for Forrest's surface.

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

- `ForestsWallet/DesignSystem/` — tokens and reusable SwiftUI primitives
- `ForestsWallet/Data/` — `WalletServing` seam, `SampleWalletStore`, production auth/ledger client, Keychain wrapper
- `ForestsWallet/Parent/` · `Child/` — screens from the delivered UI kits
- `ForestsWalletTests/` — token/format/store invariants and mocked auth/ledger networking
- `ForestsWalletUITests/` — navigation and screenshot capture
