import SwiftUI

@main
struct ForestsWalletApp: App {
    @State private var store = SampleWalletStore.makeLaunchStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(store)
                // The design system does not define a dark UI palette; paper stays paper.
                .preferredColorScheme(.light)
        }
    }
}
