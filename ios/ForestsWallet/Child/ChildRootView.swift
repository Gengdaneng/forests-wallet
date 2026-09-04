import SwiftUI

enum ChildTab: String, Hashable {
    case home, board, rules, all, wish
}

struct ChildRootView: View {
    @Environment(SampleWalletStore.self) private var store
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var tab: ChildTab = .home

    private let nav: [NavItem] = [
        .init(id: "home", label: "我的钱", icon: .wallet),
        .init(id: "board", label: "本周看板", icon: .calendarCheck),
        .init(id: "rules", label: "规则", icon: .scrollText),
        .init(id: "all", label: "全部流水", icon: .list),
        .init(id: "wish", label: "已实现的心愿", icon: .sparkles),
    ]

    var body: some View {
        Group {
            if sizeClass == .regular {
                HStack(spacing: 0) {
                    FWSidebar(items: nav, active: tab.rawValue, onSelect: select)
                    content
                }
            } else {
                VStack(spacing: 0) {
                    content
                    FWTabBar(items: compactTabs, active: tab.rawValue, onSelect: select)
                }
            }
        }
        .fwScreenBackground()
        .accessibilityIdentifier("screen.child.root")
    }

    private var compactTabs: [NavItem] {
        [
            .init(id: "home", label: "我的钱", icon: .wallet),
            .init(id: "board", label: "看板", icon: .calendarCheck),
            .init(id: "rules", label: "规则", icon: .scrollText),
            .init(id: "all", label: "流水", icon: .list),
            .init(id: "wish", label: "心愿", icon: .sparkles),
        ]
    }

    private var content: some View {
        ScrollView {
            Group {
                switch tab {
                case .home: ChildHomeView(onOpenAll: { tab = .all })
                case .board: ChildBoardView()
                case .rules: ChildRulesView()
                case .all: ChildLedgerView()
                case .wish: ChildWishesView()
                }
            }
            .padding(.horizontal, sizeClass == .regular ? FWSpace.gutterPad : FWSpace.gutterPhone)
            .padding(.vertical, sizeClass == .regular ? FWSpace.s8 : FWSpace.s6)
            .frame(maxWidth: FWSpace.maxChildColumn)
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func select(_ id: String) {
        if let next = ChildTab(rawValue: id) {
            tab = next
        }
    }
}
