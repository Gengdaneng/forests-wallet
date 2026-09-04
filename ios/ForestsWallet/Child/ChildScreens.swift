import SwiftUI

struct ChildHomeView: View {
    var onOpenAll: () -> Void
    @Environment(SampleWalletStore.self) private var store

    var body: some View {
        let snap = store.snapshot
        VStack(alignment: .leading, spacing: FWSpace.s7) {
            HStack(spacing: FWSpace.s4) {
                FWScreenTitle(text: "我的钱", size: .child)
                StatusBanner(kind: snap.isOnline ? .online : .offline, size: .child)
            }

            if let cents = snap.pendingCelebrationCents {
                Celebration(cents: cents, reason: "本周基础零花钱") {
                    store.dismissCelebration()
                }
            }

            BalanceHero(
                cents: snap.balanceCents,
                size: .child,
                note: "爸爸记下的每一笔都在下面，你可以自己数一遍。"
            )

            if let goal = snap.goal {
                FWCard(variant: .child, tone: .honey) {
                    GoalProgress(
                        title: goal.title,
                        savedCents: snap.balanceCents,
                        targetCents: goal.targetCents,
                        size: .child,
                        reached: snap.goalReached
                    )
                }
            }

            FWCard(variant: .child) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 12) {
                        Text("钱为什么变了")
                            .font(FWType.rounded(FWType.childHead, weight: .heavy))
                            .foregroundStyle(FWColor.textStrong)
                        Spacer()
                        FWBadge(text: "只能看", tone: .neutral, icon: .eye, size: .child)
                    }
                    .padding(.bottom, FWSpace.s4)

                    ForEach(snap.transactions.prefix(5)) { tx in
                        TransactionRow(
                            reason: tx.reason,
                            cents: tx.cents,
                            direction: tx.direction,
                            date: tx.date,
                            categoryID: tx.categoryID,
                            balanceAfter: tx.balanceAfter,
                            size: .child,
                            reversed: tx.reversed
                        )
                    }

                    FWButton(title: "看全部流水", tone: .quiet, size: .child, iconAfter: .chevronRight, action: onOpenAll)
                        .padding(.top, FWSpace.s5)
                        .accessibilityIdentifier("child.openAll")
                }
            }
        }
        .accessibilityIdentifier("screen.child.home")
    }
}

struct ChildBoardView: View {
    @Environment(SampleWalletStore.self) private var store

    var body: some View {
        let snap = store.snapshot
        VStack(alignment: .leading, spacing: FWSpace.s7) {
            FWScreenTitle(text: "本周看板", size: .child)
            FWCard(variant: .child) {
                WeekBoard(items: snap.board.map(\.asWeekItem), size: .child, weekLabel: snap.weekLabel)
            }
            FWCard(variant: .child, tone: .leaf) {
                VStack(alignment: .leading, spacing: FWSpace.s4) {
                    Text("周日一起算算看")
                        .font(FWType.rounded(FWType.childHead, weight: .heavy))
                        .foregroundStyle(FWColor.textStrong)
                    SettlementSummary(lines: snap.settlementLines, bonus: snap.bonus, size: .child)
                    Text("现在还没到周日，空着的格子只是爸爸还没记。")
                        .font(FWType.text(FWType.childBody, weight: .regular))
                        .foregroundStyle(FWColor.spruce600)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .accessibilityIdentifier("screen.child.board")
    }
}

struct ChildRulesView: View {
    @Environment(SampleWalletStore.self) private var store

    var body: some View {
        let snap = store.snapshot
        VStack(alignment: .leading, spacing: FWSpace.s7) {
            FWScreenTitle(text: "规则", size: .child)
            FWCard(variant: .child) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("每周都有的")
                        .font(FWType.rounded(FWType.childHead, weight: .heavy))
                        .foregroundStyle(FWColor.textStrong)
                        .padding(.bottom, FWSpace.s3)
                    ForEach(snap.board) { item in
                        RuleRow(
                            name: item.name,
                            detail: "每周 \(item.goal) 次",
                            rewardCents: item.rewardCents,
                            met: item.name == "跳绳" ? false : nil,
                            size: .child,
                            kind: .base
                        )
                    }
                    RuleRow(
                        name: "三项全达成奖励",
                        detail: "三项都做到才有",
                        rewardCents: snap.bonusCents,
                        size: .child,
                        kind: .base
                    )
                }
            }
            FWCard(variant: .child) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .firstTextBaseline, spacing: 10) {
                        Text("商量好的")
                            .font(FWType.rounded(FWType.childHead, weight: .heavy))
                            .foregroundStyle(FWColor.textStrong)
                        Text("一共 12 条，下面是最近 3 条")
                            .font(FWType.text(FWType.childLabel, weight: .regular))
                            .foregroundStyle(FWColor.textMuted)
                    }
                    .padding(.bottom, FWSpace.s3)
                    ForEach(snap.adhoc) { r in
                        RuleRow(name: r.name, detail: r.detail, rewardCents: r.rewardCents, size: .child, kind: .adhoc)
                    }
                }
            }
            VStack(alignment: .leading, spacing: FWSpace.s4) {
                Text("规则改过哪些")
                    .font(FWType.rounded(FWType.childHead, weight: .heavy))
                    .foregroundStyle(FWColor.textStrong)
                ForEach(snap.changes) { c in
                    ChangeNote(text: c.text, date: c.date, size: .child)
                }
            }
        }
        .accessibilityIdentifier("screen.child.rules")
    }
}

struct ChildLedgerView: View {
    @Environment(SampleWalletStore.self) private var store

    var body: some View {
        let snap = store.snapshot
        VStack(alignment: .leading, spacing: FWSpace.s6) {
            FWScreenTitle(text: "全部流水", size: .child)
            if let goal = snap.goal, let spend = snap.transactions.first(where: { $0.direction == .spend && !$0.reversed }) {
                CostHint(cents: spend.cents, goalTitle: goal.title)
            }
            FWCard(variant: .child) {
                VStack(spacing: 0) {
                    ForEach(snap.transactions) { tx in
                        TransactionRow(
                            reason: tx.reason,
                            cents: tx.cents,
                            direction: tx.direction,
                            date: tx.date,
                            categoryID: tx.categoryID,
                            balanceAfter: tx.balanceAfter,
                            size: .child,
                            reversed: tx.reversed
                        )
                    }
                }
            }
        }
        .accessibilityIdentifier("screen.child.ledger")
    }
}

struct ChildWishesView: View {
    @Environment(SampleWalletStore.self) private var store

    var body: some View {
        let snap = store.snapshot
        VStack(alignment: .leading, spacing: FWSpace.s7) {
            FWScreenTitle(text: "已实现的心愿", size: .child)
            LazyVGrid(columns: [GridItem(.flexible(), spacing: FWSpace.s5), GridItem(.flexible(), spacing: FWSpace.s5)], spacing: FWSpace.s5) {
                ForEach(snap.wishes) { wish in
                    FWCard(variant: .child, tone: .honey) {
                        VStack(alignment: .leading, spacing: FWSpace.s2) {
                            FWIcon(glyph: .partyPopper, size: 30)
                                .foregroundStyle(FWColor.honey700)
                            Text(wish.title)
                                .font(FWType.rounded(FWType.childHead, weight: .heavy))
                                .foregroundStyle(FWColor.textStrong)
                                .padding(.top, FWSpace.s2)
                            AmountText(cents: wish.cents, direction: .flat, showSign: false)
                            Text(wish.date)
                                .font(FWType.text(FWType.childLabel, weight: .regular))
                                .foregroundStyle(FWColor.honey700)
                        }
                    }
                }
            }
            FWCard(variant: .child, tone: .sunken, pad: 0) {
                EmptyState(
                    icon: .target,
                    title: "下一个心愿正在攒",
                    bodyText: wishGoalLine(snap),
                    size: .child
                )
            }
        }
        .accessibilityIdentifier("screen.child.wishes")
    }

    private func wishGoalLine(_ snap: WalletSnapshot) -> String {
        if let goal = snap.goal {
            return "\(goal.title) · 已攒 ¥\(MoneyFormat.yuanNumber(snap.balanceCents)) / ¥\(MoneyFormat.yuanNumber(goal.targetCents))"
        }
        return "已攒 ¥\(MoneyFormat.yuanNumber(snap.balanceCents))"
    }
}
