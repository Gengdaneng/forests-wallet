# Forrest's Wallet · iOS

Native SwiftUI app for iPhone (parent) and iPad (child). One universal target, local in-memory sample data only — no networking.

Design authority: `DesignSystem/Reference/` (extracted design-system source). Do not run the bundled JavaScript.

## Requirements

- Xcode 26.6 / Swift 6.3.3
- iOS 17+ simulator (no signing team required)

## Open and run

```
open ios/ForestsWallet.xcodeproj
```

Pick an iPhone simulator for the parent surface, or an iPad simulator for Forrest's surface. The first launch is unpaired:

- iPhone: register as parent
- iPad: enter pairing code `482917` (deterministic sample)

Launch arguments for tests and previews:

- `-FWRoleParent` — skip bootstrap, open parent home
- `-FWRoleChild` — skip pairing/welcome, open child home
- `-FWUnpaired` — force the pairing/bootstrap path
- `-FWOffline` — parent writes are refused

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
- `ForestsWallet/Data/` — `WalletServing` seam + `SampleWalletStore`
- `ForestsWallet/Parent/` · `Child/` — screens from the delivered UI kits
- `ForestsWalletTests/` — token/format/store invariants
- `ForestsWalletUITests/` — navigation and screenshot capture
