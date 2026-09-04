import SwiftUI

struct ParentBoardView: View {
    @Environment(SampleWalletStore.self) private var store
    @State private var editing: EditTarget?
    @State private var bonusEdit = false
    @State private var bonusDraft = ""

    private enum EditTarget: Equatable {
        case new
        case index(Int)
    }

    var body: some View {
        let snap = store.snapshot
        VStack(alignment: .leading, spacing: FWSpace.s5) {
            HStack {
                FWScreenTitle(text: "本周看板", size: .parent)
                FWButton(title: "加一项", tone: .accent, size: .small, icon: .plus) {
                    editing = .new
                }
            }

            FWCard {
                WeekBoard(
                    items: snap.board.map(\.asWeekItem),
                    size: .parent,
                    weekLabel: SampleData.weekLabel,
                    onToggle: { r, c in store.toggleBoardCell(row: r, day: c) }
                )
            }
            StatusBanner(kind: .norealmoney, text: "随时可以补勾 · 只有周日结算才会算成未达成", size: .parent)

            FWCard {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text("这些项目和金额")
                            .font(FWType.rounded(FWType.head, weight: .bold))
                            .foregroundStyle(FWColor.textStrong)
                        Spacer()
                        FWBadge(text: "可以改", tone: .neutral, icon: .pencil, size: .parent)
                    }
                    .padding(.bottom, FWSpace.s3)

                    ForEach(Array(snap.board.enumerated()), id: \.element.id) { i, item in
                        RuleRow(
                            name: item.name,
                            detail: "每周 \(item.goal) 次 · 已做到 \(item.doneCount) 次",
                            rewardCents: item.rewardCents,
                            size: .parent
                        ) {
                            editing = .index(i)
                        }
                    }

                    Button {
                        bonusDraft = "\(MoneyFormat.yuanNumber(snap.bonusCents))"
                        bonusEdit = true
                    } label: {
                        HStack(spacing: 12) {
                            FWIcon(glyph: .gift, size: 18)
                                .foregroundStyle(FWColor.honey700)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("全部达成奖励")
                                    .font(FWType.rounded(FWType.body, weight: .bold))
                                    .foregroundStyle(FWColor.textStrong)
                                Text("\(snap.board.count) 项都做到才有")
                                    .font(FWType.text(FWType.caption, weight: .regular))
                                    .foregroundStyle(FWColor.textMuted)
                            }
                            Spacer()
                            Text("¥\(MoneyFormat.yuanNumber(snap.bonusCents))")
                                .font(FWType.rounded(FWType.amountSm, weight: .heavy))
                                .monospacedDigit()
                                .foregroundStyle(FWColor.honey700)
                            FWIcon(glyph: .chevronRight, size: 18)
                                .foregroundStyle(FWColor.textFaint)
                        }
                        .frame(minHeight: FWSpace.touchParent)
                    }
                    .buttonStyle(.plain)

                    HStack(alignment: .firstTextBaseline, spacing: 10) {
                        Text("按现在的进度，本周")
                            .font(FWType.rounded(FWType.head, weight: .heavy))
                            .foregroundStyle(FWColor.textStrong)
                        Spacer()
                        AmountText(cents: snap.settlementTotalCents, direction: .income)
                    }
                    .padding(.top, FWSpace.s4)
                    .overlay(alignment: .top) {
                        Rectangle().fill(FWColor.spruce700).frame(height: 2)
                    }
                    .padding(.top, FWSpace.s4)
                }
            }

            if let editing {
                ItemEditor(
                    item: {
                        switch editing {
                        case .new: return nil
                        case .index(let i): return snap.board[i]
                        }
                    }(),
                    onCancel: { self.editing = nil },
                    onSave: { name, goal, cents in
                        switch editing {
                        case .new: store.saveBoardItem(at: nil, name: name, goal: goal, rewardCents: cents)
                        case .index(let i): store.saveBoardItem(at: i, name: name, goal: goal, rewardCents: cents)
                        }
                        self.editing = nil
                    },
                    onDelete: {
                        if case .index(let i) = editing {
                            store.deleteBoardItem(at: i)
                        }
                        self.editing = nil
                    }
                )
            }

            if bonusEdit {
                FWCard(tone: .sunken) {
                    VStack(alignment: .leading, spacing: FWSpace.s4) {
                        FWTextField(label: "全部达成奖励（元）", value: $bonusDraft, keyboard: .numberPad)
                        StatusBanner(
                            kind: .norealmoney,
                            text: "分项计分 + 全勤奖：漏一项不会归零，坚持到底另有价值",
                            size: .parent
                        )
                        HStack(spacing: FWSpace.s3) {
                            FWButton(title: "取消", tone: .quiet, block: true) { bonusEdit = false }
                            FWButton(title: "保存", tone: .primary, block: true) {
                                store.setBonusCents((Int(bonusDraft) ?? 0) * 100)
                                bonusEdit = false
                            }
                        }
                    }
                }
            }
        }
        .accessibilityIdentifier("screen.parent.board")
    }
}

private struct ItemEditor: View {
    var item: BoardItem?
    var onCancel: () -> Void
    var onSave: (String, Int, Int) -> Void
    var onDelete: (() -> Void)?

    @State private var name = ""
    @State private var goal = "5"
    @State private var yuan = "5"

    private var isNew: Bool { item == nil }
    private var valid: Bool {
        let g = Int(goal) ?? 0
        let y = Int(yuan) ?? -1
        return !name.trimmingCharacters(in: .whitespaces).isEmpty && g > 0 && g <= 7 && y >= 0
    }

    var body: some View {
        FWCard(tone: .sunken) {
            VStack(alignment: .leading, spacing: FWSpace.s4) {
                Text(isNew ? "加一项打卡" : "改「\(item?.name ?? "")」")
                    .font(FWType.rounded(FWType.head, weight: .bold))
                    .foregroundStyle(FWColor.textStrong)
                FWTextField(label: "打卡项名称", value: $name, placeholder: "例如：练琴", maxLength: 6)
                HStack(spacing: FWSpace.s4) {
                    FWTextField(label: "每周目标次数", value: $goal, keyboard: .numberPad)
                    FWTextField(label: "做到给多少（元）", value: $yuan, keyboard: .numberPad)
                }
                StatusBanner(
                    kind: .norealmoney,
                    text: isNew
                        ? "新加的项从这周开始算，Forrest 的规则页会出现一条记录"
                        : "改完会在 Forrest 的规则页留一条变更记录",
                    size: .parent
                )
                FWButton(title: "保存", tone: .primary, block: true, disabled: !valid) {
                    onSave(name, Int(goal) ?? 0, (Int(yuan) ?? 0) * 100)
                }
                HStack(spacing: FWSpace.s3) {
                    FWButton(title: "取消", tone: .quiet, block: true, action: onCancel)
                    if onDelete != nil {
                        FWButton(title: "删掉这项", tone: .danger, icon: .trash, block: true) {
                            onDelete?()
                        }
                    }
                }
            }
        }
        .onAppear {
            if let item {
                name = item.name
                goal = "\(item.goal)"
                yuan = "\(MoneyFormat.yuanNumber(item.rewardCents))"
            }
        }
    }
}
