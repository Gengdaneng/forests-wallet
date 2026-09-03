import SwiftUI

struct EntryFlowView: View {
    var direction: MoneyDirection
    var onCancel: () -> Void
    var onDone: () -> Void

    @Environment(SampleWalletStore.self) private var store
    @State private var step: Step = .amount
    @State private var amt = ""
    @State private var reason = ""
    @State private var category: String?

    private enum Step { case amount, extra, done }

    private var title: String {
        switch direction {
        case .income: "加进来"
        case .spend: "花掉了"
        case .correction: "更正这笔"
        default: "记一笔"
        }
    }

    private var amountLabel: String {
        switch direction {
        case .income: "加进来多少"
        case .spend: "花了多少"
        case .correction: "更正多少"
        default: "多少"
        }
    }

    private var cents: Int { (Int(amt) ?? 0) * 100 }

    var body: some View {
        VStack(spacing: 0) {
            if step != .done {
                NavHeader(title: title, size: .parent, onBack: onCancel) {
                    if direction == .correction {
                        FWBadge(text: "留痕", tone: .fix, icon: .rotateCcw, size: .parent)
                    }
                }
                .padding(.horizontal, FWSpace.gutterPhone)
            }

            if step == .done {
                doneBody
            } else if step == .amount {
                amountBody
            } else {
                extraBody
            }
        }
        .fwScreenBackground()
        .accessibilityIdentifier("screen.parent.entry")
    }

    private var amountBody: some View {
        VStack(spacing: 0) {
            AmountField(value: amt, direction: direction, label: amountLabel)
            NumberPad(value: $amt)
            Spacer(minLength: FWSpace.s5)
            FWButton(title: "确认记录", tone: .primary, block: true, disabled: amt.isEmpty) {
                step = .extra
            }
            .accessibilityIdentifier("entry.confirm")
        }
        .padding(.horizontal, FWSpace.gutterPhone)
        .padding(.bottom, FWSpace.s5)
    }

    private var extraBody: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: FWSpace.s5) {
                FWCard(tone: .sunken) {
                    AmountText(cents: cents, direction: direction, size: .heroSm)
                        .frame(maxWidth: .infinity)
                }
                FWTextField(label: "为什么", value: $reason, placeholder: "买冰淇淋", optional: true, maxLength: 8)
                if direction == .spend {
                    CategoryPicker(value: $category)
                }
                if direction == .correction {
                    StatusBanner(kind: .norealmoney, text: "原记录会保留，另外写入一笔冲正", size: .parent)
                }
                VStack(spacing: FWSpace.s3) {
                    FWButton(title: "记下来", tone: .primary, block: true, action: commit)
                    FWButton(title: "都跳过，直接记", tone: .quiet, block: true) {
                        reason = ""
                        category = nil
                        commit()
                    }
                }
            }
            .padding(.horizontal, FWSpace.gutterPhone)
            .padding(.bottom, FWSpace.s5)
        }
    }

    private var doneBody: some View {
        ScrollView {
            VStack(spacing: FWSpace.s5) {
                VStack(spacing: FWSpace.s3) {
                    FWIcon(glyph: .checkCircle, size: 44)
                        .foregroundStyle(FWColor.moneyIn)
                    Text("已记录")
                        .font(FWType.rounded(FWType.title, weight: .heavy))
                        .foregroundStyle(FWColor.textStrong)
                    AmountText(cents: cents, direction: direction, size: .heroSm)
                    Text(reason.isEmpty ? "（没写事由）" : reason)
                        .foregroundStyle(FWColor.textMuted)
                }
                .padding(.top, FWSpace.s6)
                .frame(maxWidth: .infinity)

                StatusBanner(kind: .norealmoney, text: "已记录 · 没有任何真实资金移动", size: .parent)
                if direction == .spend {
                    CostHint(cents: cents, goalTitle: store.goal.title)
                }
                FWButton(title: "回首页", tone: .primary, block: true, action: onDone)
                    .accessibilityIdentifier("entry.home")
            }
            .padding(.horizontal, FWSpace.gutterPhone)
            .padding(.bottom, FWSpace.s5)
        }
    }

    private func commit() {
        _ = store.recordEntry(
            direction: direction,
            yuan: Int(amt) ?? 0,
            reason: reason,
            categoryID: category
        )
        step = .done
    }
}
