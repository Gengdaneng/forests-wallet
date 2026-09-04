import SwiftUI

enum ParentTab: String, Hashable {
    case home, board, add, hist, set
}

@Observable
final class ParentNav {
    var tab: ParentTab = .home
    var entry: MoneyDirection?
    var settleView = false
    var showRules = false
    var previewChild = false
    var pairingSheet = false

    func openEntry(_ direction: MoneyDirection) {
        entry = direction
    }

    func closeEntry() {
        entry = nil
        tab = .home
    }
}

struct ParentRootView: View {
    @Environment(SampleWalletStore.self) private var store
    @State private var nav = ParentNav()

    private let tabs: [NavItem] = [
        .init(id: "home", label: "首页", icon: .wallet),
        .init(id: "board", label: "看板", icon: .calendarCheck),
        .init(id: "add", label: "记一笔", icon: .plus),
        .init(id: "hist", label: "记录", icon: .list),
        .init(id: "set", label: "设置", icon: .settings),
    ]

    var body: some View {
        VStack(spacing: 0) {
            Group {
                if let entry = nav.entry {
                    EntryFlowView(direction: entry, onCancel: { nav.entry = nil }, onDone: nav.closeEntry)
                } else if nav.settleView {
                    ScrollView {
                        VStack(alignment: .leading, spacing: FWSpace.s5) {
                            Button {
                                nav.settleView = false
                            } label: {
                                Text("← 返回首页")
                                    .font(FWType.rounded(15, weight: .bold))
                                    .foregroundStyle(FWColor.spruce600)
                                    .frame(minHeight: FWSpace.touchMin, alignment: .leading)
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("settle.back")
                            ParentSettleView()
                        }
                        .padding(.horizontal, FWSpace.gutterPhone)
                        .padding(.vertical, FWSpace.s6)
                    }
                } else if nav.showRules {
                    ScrollView {
                        VStack(alignment: .leading, spacing: FWSpace.s5) {
                            Button {
                                nav.showRules = false
                            } label: {
                                Text("← 返回设置")
                                    .font(FWType.rounded(15, weight: .bold))
                                    .foregroundStyle(FWColor.spruce600)
                                    .frame(minHeight: FWSpace.touchMin, alignment: .leading)
                            }
                            .buttonStyle(.plain)
                            ParentRulesView()
                        }
                        .padding(.horizontal, FWSpace.gutterPhone)
                        .padding(.vertical, FWSpace.s6)
                    }
                } else {
                    ScrollView {
                        tabBody
                            .padding(.horizontal, FWSpace.gutterPhone)
                            .padding(.vertical, FWSpace.s6)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            if nav.entry == nil {
                FWTabBar(items: tabs, active: nav.settleView ? "home" : nav.tab.rawValue, center: "add") { id in
                    nav.settleView = false
                    nav.showRules = false
                    if id == "add" {
                        nav.entry = .income
                    } else if let next = ParentTab(rawValue: id) {
                        nav.tab = next
                    }
                }
            }
        }
        .fwScreenBackground()
        .sheet(isPresented: Binding(get: { nav.pairingSheet }, set: { nav.pairingSheet = $0 })) {
            ParentPairingCodeSheet()
                .presentationDetents([.medium])
        }
        .fullScreenCover(isPresented: Binding(get: { nav.previewChild }, set: { nav.previewChild = $0 })) {
            NavigationStack {
                ChildRootView()
                    .environment(\.fwSize, .child)
                    .safeAreaInset(edge: .top) {
                        HStack {
                            Text("Forrest 看到的画面")
                                .font(FWType.rounded(FWType.label, weight: .heavy))
                                .foregroundStyle(FWColor.textOnInk)
                            Spacer()
                            Button("关闭") { nav.previewChild = false }
                                .font(FWType.rounded(FWType.label, weight: .bold))
                                .foregroundStyle(FWColor.honey500)
                                .frame(minHeight: FWSpace.touchMin)
                        }
                        .padding(.horizontal, FWSpace.s5)
                        .padding(.vertical, FWSpace.s3)
                        .background(FWColor.surfaceInk)
                    }
            }
        }
        .environment(nav)
        .accessibilityIdentifier("screen.parent.root")
    }

    @ViewBuilder
    private var tabBody: some View {
        switch nav.tab {
        case .home:
            ParentHomeView()
        case .board:
            ParentBoardView()
        case .add:
            EmptyView()
        case .hist:
            ParentHistoryView()
        case .set:
            ParentSettingsView()
        }
    }
}
