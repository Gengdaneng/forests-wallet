import SwiftUI

struct RootView: View {
    @Environment(SampleWalletStore.self) private var store
    var body: some View {
        Group {
            switch store.role {
            case nil:
                if UIDevice.current.userInterfaceIdiom == .pad {
                    ChildPairingView()
                        .environment(\.fwSize, .child)
                } else {
                    ParentBootstrapView()
                        .environment(\.fwSize, .parent)
                }
            case .parent:
                ParentRootView()
                    .environment(\.fwSize, .parent)
            case .child:
                if store.hasSeenChildWelcome {
                    ChildRootView()
                        .environment(\.fwSize, .child)
                } else {
                    ChildWelcomeView()
                        .environment(\.fwSize, .child)
                }
            }
        }
        .fwScreenBackground()
        .tint(FWColor.spruce700)
        .task(id: store.role) {
            await store.refreshLedger()
        }
    }
}
