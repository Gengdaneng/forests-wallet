import SwiftUI

struct ParentHistoryView: View {
    @Environment(SampleWalletStore.self) private var store

    var body: some View {
        let snap = store.snapshot
        VStack(alignment: .leading, spacing: FWSpace.s5) {
            HStack {
                FWScreenTitle(text: "全部记录", size: .parent)
                FWBadge(text: "不可删除", tone: .neutral, icon: .lock, size: .parent)
            }
            FWCard {
                VStack(spacing: 0) {
                    ForEach(snap.transactions) { tx in
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
            if let note = correctionNote(snap) {
                FWCard(tone: .sunken) {
                    HStack(alignment: .top, spacing: 10) {
                        FWIcon(glyph: .link, size: 18)
                            .foregroundStyle(FWColor.moneyFix)
                        Text(note)
                            .font(FWType.text(FWType.caption, weight: .regular))
                            .foregroundStyle(FWColor.textMuted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .accessibilityIdentifier("screen.parent.history")
    }

    private func correctionNote(_ snap: WalletSnapshot) -> String? {
        if snap.transactions.contains(where: { $0.reason == "乐高小车" && $0.reversed }) {
            return "10月2日「乐高小车 −¥14」已被冲正，并写入正确的一笔。原记录、冲正、正确记录三条互相关联，都留在流水里。"
        }
        if snap.transactions.contains(where: \.reversed) {
            return "原记录会被冲正，并写入正确的一笔。原记录、冲正、正确记录三条互相关联，都留在流水里。"
        }
        return nil
    }
}

struct ParentRulesView: View {
    @Environment(SampleWalletStore.self) private var store

    var body: some View {
        let snap = store.snapshot
        VStack(alignment: .leading, spacing: FWSpace.s5) {
            FWScreenTitle(text: "规则清单", size: .parent)
            FWCard {
                VStack(alignment: .leading, spacing: 0) {
                    Text("每周都有的")
                        .font(FWType.rounded(FWType.head, weight: .bold))
                        .foregroundStyle(FWColor.textStrong)
                        .padding(.bottom, FWSpace.s2)
                    ForEach(snap.board) { item in
                        RuleRow(
                            name: item.name,
                            detail: "每周 \(item.goal) 次",
                            rewardCents: item.rewardCents,
                            size: .parent,
                            kind: .base
                        )
                    }
                    RuleRow(
                        name: "全部达成奖励",
                        detail: "\(snap.board.count) 项都做到才有",
                        rewardCents: snap.bonusCents,
                        size: .parent,
                        kind: .base
                    )
                }
            }
            StatusBanner(
                kind: .norealmoney,
                text: "项目和金额在「本周看板」里改 · 改完这里和 Forrest 的规则页同步",
                size: .parent
            )
            FWCard {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .firstTextBaseline, spacing: 10) {
                        Text("商量好的")
                            .font(FWType.rounded(FWType.head, weight: .bold))
                            .foregroundStyle(FWColor.textStrong)
                        Spacer()
                        Text("一事一议，直接记账")
                            .font(FWType.text(FWType.caption, weight: .regular))
                            .foregroundStyle(FWColor.textMuted)
                    }
                    .padding(.bottom, FWSpace.s2)
                    ForEach(snap.adhoc) { r in
                        RuleRow(name: r.name, detail: r.detail, rewardCents: r.rewardCents, size: .parent, kind: .adhoc)
                    }
                }
            }
            VStack(spacing: FWSpace.s3) {
                ForEach(snap.changes) { c in
                    ChangeNote(text: c.text, date: c.date, size: .parent)
                }
            }
        }
        .accessibilityIdentifier("screen.parent.rules")
    }
}
