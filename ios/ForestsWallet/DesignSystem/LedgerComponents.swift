import SwiftUI

enum BoardCellState: String, Hashable, Sendable {
    case done, unlogged, future, missed

    var label: String {
        switch self {
        case .done: "已完成"
        case .unlogged: "还没记"
        case .future: "还没到"
        case .missed: "未达成"
        }
    }
}

struct BoardCell: View {
    var state: BoardCellState = .unlogged
    var size: FWControlSize = .child
    var onToggle: (() -> Void)? = nil

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var dim: CGFloat { size == .child ? 54 : 44 }
    private var interactive: Bool { onToggle != nil && state != .future }

    var body: some View {
        Button(action: { onToggle?() }) {
            ZStack {
                RoundedRectangle(cornerRadius: FWRadius.cell, style: .continuous)
                    .fill(fill)
                RoundedRectangle(cornerRadius: FWRadius.cell, style: .continuous)
                    .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: dashed ? [4, 3] : []))
                    .foregroundStyle(border)
                if let glyph {
                    FWIcon(glyph: glyph, size: size == .child ? 26 : 20, weight: .bold)
                        .foregroundStyle(ink)
                }
            }
            .frame(width: dim, height: dim)
        }
        .buttonStyle(.plain)
        .disabled(!interactive)
        .accessibilityLabel(state.label)
        .accessibilityAddTraits(interactive ? [] : .isStaticText)
        .animation(FWMotion.standard(FWMotion.fast, reduceMotion: reduceMotion), value: state)
    }

    private var fill: Color {
        switch state {
        case .done: return FWColor.cellDoneBg
        case .unlogged: return FWColor.cellUnloggedBg
        case .future: return FWColor.cellFutureBg
        case .missed: return FWColor.cellMissedBg
        }
    }

    private var ink: Color {
        switch state {
        case .done: return FWColor.cellDoneInk
        case .unlogged: return FWColor.textFaint
        case .future: return FWColor.cellFutureInk
        case .missed: return FWColor.cellMissedInk
        }
    }

    private var dashed: Bool { state == .unlogged }
    private var border: Color { dashed ? FWColor.cellUnloggedLine : .clear }
    private var glyph: FWGlyph? {
        switch state {
        case .done: .check
        case .missed: .minus
        default: nil
        }
    }
}

struct WeekBoardItem: Hashable, Sendable {
    var name: String
    var goal: Int
    var rewardCents: Int
    var days: [BoardCellState]
}

struct WeekBoard: View {
    var items: [WeekBoardItem]
    var size: FWControlSize = .child
    var weekLabel: String? = nil
    var onToggle: ((Int, Int) -> Void)? = nil

    private let days = ["一", "二", "三", "四", "五", "六", "日"]
    private var cell: CGFloat { size == .child ? 54 : 44 }
    private var gap: CGFloat { size == .child ? 10 : 6 }

    var body: some View {
        VStack(alignment: .leading, spacing: FWSpace.s4) {
            if let weekLabel {
                Text(weekLabel)
                    .font(FWType.rounded(size.headSize, weight: .heavy))
                    .foregroundStyle(FWColor.textStrong)
            }

            ViewThatFits(in: .horizontal) {
                grid
                ScrollView(.horizontal, showsIndicators: false) {
                    grid
                }
            }

            HStack(spacing: size == .child ? 20 : 14) {
                legend(.done, "做到了")
                legend(.unlogged, "爸爸还没记")
                legend(.future, "还没到")
            }
            .font(FWType.text(size.captionSize, weight: .regular))
            .foregroundStyle(FWColor.textMuted)
            .padding(.top, FWSpace.s2)
        }
        .accessibilityElement(children: .contain)
    }

    private var grid: some View {
        Grid(alignment: .leading, horizontalSpacing: gap, verticalSpacing: gap) {
            GridRow {
                Color.clear.frame(width: 96, height: 1)
                ForEach(days, id: \.self) { d in
                    Text(d)
                        .font(FWType.rounded(size == .child ? 17 : 13, weight: .bold))
                        .foregroundStyle(FWColor.textMuted)
                        .frame(width: cell, alignment: .center)
                }
            }
            ForEach(Array(items.enumerated()), id: \.offset) { r, item in
                GridRow {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.name)
                            .font(FWType.rounded(size == .child ? FWType.childBody : FWType.label, weight: .bold))
                            .foregroundStyle(FWColor.textStrong)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        Text("\(item.days.filter { $0 == .done }.count)/\(item.goal) · ¥\(MoneyFormat.yuanNumber(item.rewardCents))")
                            .font(FWType.text(size == .child ? 15 : 12, weight: .regular))
                            .foregroundStyle(FWColor.textMuted)
                            .monospacedDigit()
                    }
                    .frame(minWidth: 96, alignment: .leading)
                    .gridColumnAlignment(.leading)

                    ForEach(Array(item.days.enumerated()), id: \.offset) { c, st in
                        BoardCell(state: st, size: size, onToggle: onToggle.map { handler in
                            { handler(r, c) }
                        })
                        .frame(width: cell, height: cell)
                        .gridColumnAlignment(.center)
                    }
                }
            }
        }
    }

    private func legend(_ state: BoardCellState, _ label: String) -> some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .fill(state == .done ? FWColor.cellDoneBg : state == .future ? FWColor.cellFutureBg : FWColor.cellUnloggedBg)
                .overlay {
                    if state == .unlogged {
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [3, 2]))
                            .foregroundStyle(FWColor.cellUnloggedLine)
                    }
                }
                .frame(width: 18, height: 18)
            Text(label)
        }
    }
}

enum RuleKind: String, Sendable {
    case base, adhoc
}

struct RuleRow: View {
    var name: String
    var detail: String? = nil
    var rewardCents: Int
    var met: Bool? = nil
    var size: FWControlSize = .child
    var kind: RuleKind = .base
    var action: (() -> Void)? = nil

    var body: some View {
        let row = HStack(spacing: size == .child ? FWSpace.s5 : FWSpace.s4) {
            ZStack {
                RoundedRectangle(cornerRadius: FWRadius.md, style: .continuous)
                    .fill(kind == .base ? FWColor.surfaceLeaf : FWColor.surfaceHoney)
                FWIcon(glyph: kind == .base ? .repeat : .sparkles, size: size == .child ? 22 : 18)
                    .foregroundStyle(kind == .base ? FWColor.spruce700 : FWColor.honey700)
            }
            .frame(width: size == .child ? 44 : 36, height: size == .child ? 44 : 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(FWType.rounded(size.bodySize, weight: .bold))
                    .foregroundStyle(FWColor.textStrong)
                if let detail {
                    Text(detail)
                        .font(FWType.text(size.captionSize, weight: .regular))
                        .foregroundStyle(FWColor.textMuted)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 10) {
                if let met {
                    FWBadge(
                        text: met ? "做到了" : "还没记",
                        tone: met ? .income : .neutral,
                        icon: met ? .check : .clock,
                        size: size
                    )
                }
                Text("¥\(MoneyFormat.yuanNumber(rewardCents))")
                    .font(FWType.rounded(size.amountSize, weight: .heavy))
                    .monospacedDigit()
                    .foregroundStyle(FWColor.spruce700)
            }
        }
        .frame(minHeight: size.touch)
        .padding(.vertical, size == .child ? FWSpace.s4 : FWSpace.s3)
        .overlay(alignment: .bottom) {
            Rectangle().fill(FWColor.borderHair).frame(height: 1)
        }
        .accessibilityElement(children: .combine)

        if let action {
            Button(action: action) { row }.buttonStyle(.plain)
        } else {
            row
        }
    }
}

struct ChangeNote: View {
    var text: String
    var date: String? = nil
    var size: FWControlSize = .child

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            FWIcon(glyph: .pencil, size: size == .child ? 22 : 18)
                .foregroundStyle(FWColor.moneyFix)
                .padding(.top, 2)
            VStack(alignment: .leading, spacing: 4) {
                Text(text)
                    .font(FWType.text(size.bodySize, weight: .semibold))
                    .foregroundStyle(FWColor.textStrong)
                    .fixedSize(horizontal: false, vertical: true)
                if let date {
                    Text(date)
                        .font(FWType.text(size.captionSize, weight: .regular))
                        .foregroundStyle(FWColor.textMuted)
                }
            }
        }
        .padding(size == .child ? FWSpace.s5 : FWSpace.s4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(FWColor.surfaceSunken, in: RoundedRectangle(cornerRadius: FWRadius.lg, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}

struct SettlementLine: Hashable, Sendable {
    var name: String
    var goal: Int
    var doneCount: Int
    var rewardCents: Int
    var met: Bool
}

struct SettlementBonus: Hashable, Sendable {
    var rewardCents: Int
    var met: Bool
}

struct SettlementSummary: View {
    var lines: [SettlementLine]
    var bonus: SettlementBonus? = nil
    var size: FWControlSize = .parent

    private var total: Int {
        lines.reduce(0) { $0 + ($1.met ? $1.rewardCents : 0) }
            + ((bonus?.met == true) ? (bonus?.rewardCents ?? 0) : 0)
    }

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                row(
                    label: line.name,
                    note: "目标 \(line.goal) 次 · 做到 \(line.doneCount) 次",
                    cents: line.rewardCents,
                    met: line.met
                )
            }
            if let bonus {
                row(label: "三项全达成奖励", note: bonus.met ? "达成" : "未达成", cents: bonus.rewardCents, met: bonus.met)
            }

            HStack(spacing: 10) {
                FWIcon(glyph: .equal, size: size == .child ? 22 : 18)
                    .foregroundStyle(FWColor.spruce700)
                Text("本周基础零花钱")
                    .font(FWType.rounded(size.headSize, weight: .heavy))
                    .foregroundStyle(FWColor.textStrong)
                Spacer()
                Text("+¥\(MoneyFormat.yuanNumber(total))")
                    .font(FWType.rounded(size == .child ? 34 : 26, weight: .black))
                    .monospacedDigit()
                    .foregroundStyle(FWColor.moneyIn)
            }
            .padding(.top, FWSpace.s4)
            .overlay(alignment: .top) {
                Rectangle().fill(FWColor.spruce700).frame(height: 2)
            }
            .padding(.top, FWSpace.s4)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("本周基础零花钱 \(MoneyFormat.yuanNumber(total)) 元")
    }

    private func row(label: String, note: String, cents: Int, met: Bool) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text(label)
                .font(FWType.text(size.bodySize, weight: .semibold))
                .foregroundStyle(met ? FWColor.textStrong : FWColor.textMuted)
                .lineLimit(1)
            Rectangle()
                .fill(FWColor.borderCard)
                .frame(height: 1)
                .overlay(
                    Rectangle().stroke(style: StrokeStyle(lineWidth: 1, dash: [2, 3]))
                        .foregroundStyle(FWColor.borderCard)
                )
            Text(note)
                .font(FWType.text(size.captionSize, weight: .regular))
                .foregroundStyle(FWColor.textMuted)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Text(met ? "+¥\(MoneyFormat.yuanNumber(cents))" : "¥0")
                .font(FWType.rounded(size.bodySize, weight: .heavy))
                .monospacedDigit()
                .foregroundStyle(met ? FWColor.moneyIn : FWColor.textFaint)
                .frame(minWidth: 56, alignment: .trailing)
        }
        .padding(.vertical, size == .child ? 10 : 7)
    }
}
