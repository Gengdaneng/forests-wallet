import SwiftUI

struct ParentHomeView: View {
    @Environment(SampleWalletStore.self) private var store
    @Environment(ParentNav.self) private var nav
    @State private var editingGoal = false

    var body: some View {
        let snap = store.snapshot
        VStack(alignment: .leading, spacing: FWSpace.s5) {
            HStack(alignment: .center, spacing: 10) {
                FWScreenTitle(text: "Forrest 的账本", size: .parent)
                StatusBanner(
                    kind: snap.isOnline ? .online : .failed,
                    text: snap.isOnline ? "已连上" : "离线 · 不能记账",
                    size: .parent
                )
            }

            BalanceHero(
                cents: snap.balanceCents,
                caption: "你现在有",
                size: .parent,
                note: "1:1 无条件兑现 · 他真的有这么多"
            )

            HStack(spacing: FWSpace.s3) {
                FWButton(title: "加进来", tone: .accent, icon: .plus, block: true, disabled: !snap.isOnline) {
                    nav.openEntry(.income)
                }
                FWButton(title: "花掉了", tone: .quiet, icon: .minus, block: true, disabled: !snap.isOnline) {
                    nav.openEntry(.spend)
                }
                FWButton(title: "更正", tone: .outline, icon: .rotateCcw, block: true, disabled: !snap.isOnline) {
                    nav.openEntry(.correction)
                }
            }

            if !snap.isOnline {
                StatusBanner(kind: .failed, text: "没有写入任何记录 —— 记账必须联网", size: .parent)
            } else if let reason = store.lastRecordRejectedReason {
                StatusBanner(kind: .failed, text: reason, size: .parent)
            } else if let message = store.lastAuthErrorMessage {
                StatusBanner(
                    kind: store.lastAuthErrorIsOffline ? .offline : .failed,
                    text: message,
                    size: .parent
                )
            }

            FWCard(tone: .leaf, action: { nav.settleView = true }) {
                HStack(spacing: 12) {
                    FWIcon(glyph: .calendarCheck, size: 22)
                        .foregroundStyle(FWColor.spruce700)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("周日结算等你确认")
                            .font(FWType.rounded(FWType.body, weight: .bold))
                            .foregroundStyle(FWColor.textStrong)
                        Text(settleSubtitle(snap))
                            .font(FWType.text(FWType.caption, weight: .regular))
                            .foregroundStyle(FWColor.spruce600)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    FWIcon(glyph: .chevronRight, size: 20)
                        .foregroundStyle(FWColor.spruce600)
                }
                .frame(minHeight: FWSpace.touchParent)
            }
            .accessibilityIdentifier("home.settle")

            if let goal = snap.goal {
                FWCard(tone: .honey) {
                    VStack(alignment: .leading, spacing: FWSpace.s3) {
                        GoalProgress(
                            title: goal.title,
                            savedCents: snap.balanceCents,
                            targetCents: goal.targetCents,
                            size: .parent,
                            reached: snap.goalReached
                        )
                        if store.isRemoteAuth {
                            HStack(spacing: FWSpace.s3) {
                                FWButton(title: "改心愿", tone: .quiet, size: .small) {
                                    editingGoal = true
                                }
                                FWButton(title: "先不攒了", tone: .outline, size: .small, disabled: store.isAuthBusy) {
                                    Task { await store.archiveGoal() }
                                }
                            }
                        }
                    }
                }
            } else if store.isRemoteAuth {
                FWButton(title: "设一个心愿", tone: .outline, icon: .target, block: true, disabled: !snap.isOnline || store.isAuthBusy) {
                    editingGoal = true
                }
            }

            if editingGoal {
                GoalEditor(
                    goal: snap.goal,
                    onCancel: { editingGoal = false },
                    onSave: { title, cents in
                        editingGoal = false
                        Task { await store.saveGoal(title: title, targetCents: cents) }
                    }
                )
            }

            FWCard {
                VStack(alignment: .leading, spacing: FWSpace.s3) {
                    HStack {
                        Text("最近记的")
                            .font(FWType.rounded(FWType.head, weight: .bold))
                            .foregroundStyle(FWColor.textStrong)
                        Spacer()
                        FWBadge(text: "不能删", tone: .neutral, icon: .lock, size: .parent)
                    }
                    ForEach(snap.transactions.prefix(4)) { tx in
                        TransactionRow(
                            reason: tx.reason,
                            cents: tx.cents,
                            direction: tx.direction,
                            date: tx.date,
                            categoryID: tx.categoryID,
                            balanceAfter: tx.balanceAfter,
                            size: .parent,
                            reversed: tx.reversed
                        )
                    }
                }
            }
        }
        .accessibilityIdentifier("screen.parent.home")
    }

    private func settleSubtitle(_ snap: WalletSnapshot) -> String {
        let met = snap.board.filter(\.met).count
        let total = snap.board.count
        return "\(total) 项达成 \(met) 项 · 本周 ¥\(MoneyFormat.yuanNumber(store.isRemoteAuth ? snap.settlementItemCents : snap.settlementTotalCents))"
    }
}

private struct GoalEditor: View {
    var goal: Goal?
    var onCancel: () -> Void
    var onSave: (String, Int) -> Void

    @State private var name = ""
    @State private var yuan = ""

    private var valid: Bool {
        let y = Int(yuan) ?? 0
        return !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && y > 0
    }

    var body: some View {
        FWCard(tone: .sunken) {
            VStack(alignment: .leading, spacing: FWSpace.s4) {
                Text(goal == nil ? "设一个心愿" : "改「\(goal?.title ?? "")」")
                    .font(FWType.rounded(FWType.head, weight: .bold))
                    .foregroundStyle(FWColor.textStrong)
                FWTextField(label: "想攒什么", value: $name, placeholder: "乐高赛车", maxLength: 32)
                FWTextField(label: "目标（元）", value: $yuan, keyboard: .numberPad)
                StatusBanner(
                    kind: .norealmoney,
                    text: "先不攒了不会把钱花掉。买的时候再用「花掉了」。",
                    size: .parent
                )
                FWButton(title: "保存", tone: .primary, block: true, disabled: !valid) {
                    onSave(name, (Int(yuan) ?? 0) * 100)
                }
                FWButton(title: "取消", tone: .quiet, block: true, action: onCancel)
            }
        }
        .onAppear {
            if let goal {
                name = goal.title
                yuan = "\(MoneyFormat.yuanNumber(goal.targetCents))"
            }
        }
    }
}
