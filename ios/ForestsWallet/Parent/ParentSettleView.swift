import SwiftUI

struct ParentSettleView: View {
    @Environment(SampleWalletStore.self) private var store

    var body: some View {
        let snap = store.snapshot
        VStack(alignment: .leading, spacing: FWSpace.s5) {
            FWScreenTitle(text: "周日结算", size: .parent)

            if snap.settledThisWeek {
                Celebration(cents: snap.settlementTotalCents, reason: "本周基础零花钱 · 已入账")
            }

            FWCard {
                SettlementSummary(lines: snap.settlementLines, bonus: snap.bonus, size: .parent)
            }

            FWCard(tone: .sunken) {
                Text("规则名和金额会照现在的样子存进这笔交易里，以后改规则也不会改写这一周的历史。")
                    .font(FWType.text(FWType.caption, weight: .regular))
                    .foregroundStyle(FWColor.textMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }

            FWButton(
                title: snap.settledThisWeek
                    ? "本周已入账"
                    : "确认，记入 +¥\(MoneyFormat.yuanNumber(snap.settlementTotalCents))",
                tone: .accent,
                icon: .check,
                block: true,
                disabled: snap.settledThisWeek || !snap.isOnline
            ) {
                store.confirmSettlement()
            }
            .accessibilityIdentifier("settle.confirm")
        }
        .accessibilityIdentifier("screen.parent.settle")
    }
}
