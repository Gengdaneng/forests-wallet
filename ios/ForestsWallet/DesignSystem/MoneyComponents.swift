import SwiftUI

enum MoneyDirection: String, Hashable, Sendable {
    case income = "in"
    case spend = "out"
    case correction = "fix"
    case debt
    case flat

    var sign: String {
        switch self {
        case .income: "+"
        case .spend, .debt: "−"
        case .correction: "±"
        case .flat: ""
        }
    }

    var color: Color {
        switch self {
        case .income: return FWColor.moneyIn
        case .spend: return FWColor.moneyOut
        case .correction: return FWColor.moneyFix
        case .debt: return FWColor.moneyDebt
        case .flat: return FWColor.textBody
        }
    }

    var spokenVerb: String {
        switch self {
        case .income: "加进来了"
        case .spend: "花掉了"
        case .correction: "更正"
        case .debt: "欠"
        case .flat: "现在有"
        }
    }

    var glyph: FWGlyph {
        switch self {
        case .income: .arrowDownLeft
        case .spend: .arrowUpRight
        case .correction: .rotateCcw
        case .debt: .alertTriangle
        case .flat: .wallet
        }
    }

    var iconBg: Color {
        switch self {
        case .income: return FWColor.moneyInBg
        case .spend: return FWColor.moneyOutBg
        case .correction: return FWColor.moneyFixBg
        case .debt: return FWColor.moneyDebtBg
        case .flat: return FWColor.surfaceSunken
        }
    }
}

enum AmountSize {
    case hero, heroSm, row, small
}

struct AmountText: View {
    var cents: Int
    var direction: MoneyDirection? = nil
    var size: AmountSize = .row
    var showSign: Bool = true
    var colorOverride: Color? = nil

    var resolved: MoneyDirection {
        if let direction { return direction }
        if cents < 0 { return .debt }
        if cents > 0 { return .income }
        return .flat
    }

    var body: some View {
        let dir = resolved
        let font: Font = {
            switch size {
            case .hero: FWType.rounded(FWType.balanceSize, weight: .black)
            case .heroSm: FWType.rounded(FWType.balanceSmSize, weight: .black)
            case .row: FWType.rounded(FWType.amount, weight: .heavy)
            case .small: FWType.rounded(FWType.amountSm, weight: .bold)
            }
        }()
        Text("\(showSign ? dir.sign : "")¥\(MoneyFormat.yuan(cents))")
            .font(font)
            .tracking(-0.4)
            .monospacedDigit()
            .foregroundStyle(colorOverride ?? dir.color)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .accessibilityLabel("\(dir.spokenVerb) \(MoneyFormat.yuanNumber(cents)) 元")
    }
}

struct BalanceHero: View {
    var cents: Int
    var caption: String = "你现在有"
    var size: FWControlSize = .child
    var note: String? = nil

    var negative: Bool { cents < 0 }

    var body: some View {
        VStack(alignment: size == .child ? .center : .leading, spacing: 0) {
            Text(negative ? "你现在欠爸爸" : caption)
                .font(FWType.rounded(size == .child ? FWType.childHead : FWType.label, weight: .bold))
                .foregroundStyle(negative ? FWColor.moneyDebt : FWColor.textOnInkMuted)
                .padding(.bottom, size == .child ? FWSpace.s4 : FWSpace.s2)

            AmountText(
                cents: cents,
                direction: .flat,
                size: size == .child ? .hero : .heroSm,
                showSign: false,
                colorOverride: negative ? FWColor.moneyDebt : FWColor.paper000
            )

            if negative {
                HStack(spacing: 8) {
                    FWIcon(glyph: .alertTriangle, size: size == .child ? 22 : 18)
                    Text("下次零花钱会先还上")
                        .font(FWType.text(size.bodySize, weight: .semibold))
                }
                .foregroundStyle(FWColor.moneyDebt)
                .padding(.top, FWSpace.s4)
            } else if let note {
                Text(note)
                    .font(FWType.text(size == .child ? FWType.childBody : FWType.caption, weight: .regular))
                    .foregroundStyle(FWColor.textOnInkMuted)
                    .padding(.top, FWSpace.s4)
                    .multilineTextAlignment(size == .child ? .center : .leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: size == .child ? .center : .leading)
        .padding(size == .child ? EdgeInsets(top: FWSpace.s9, leading: FWSpace.s8, bottom: FWSpace.s9, trailing: FWSpace.s8) : EdgeInsets(top: FWSpace.s6, leading: FWSpace.s6, bottom: FWSpace.s6, trailing: FWSpace.s6))
        .background(negative ? FWColor.moneyDebtBg : FWColor.surfaceInk)
        .clipShape(RoundedRectangle(cornerRadius: size == .child ? FWRadius.xxl : FWRadius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: size == .child ? FWRadius.xxl : FWRadius.lg, style: .continuous)
                .strokeBorder(negative ? FWColor.berry400 : .clear, lineWidth: 1.5)
        )
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("balance.hero")
    }
}

struct GoalProgress: View {
    var title: String
    var savedCents: Int
    var targetCents: Int
    var size: FWControlSize = .child
    var reached: Bool = false

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var saved: Int { max(0, MoneyFormat.yuanNumber(savedCents)) }
    private var target: Int { max(1, MoneyFormat.yuanNumber(targetCents)) }
    private var pct: CGFloat { min(1, CGFloat(saved) / CGFloat(target)) }
    private var left: Int { max(0, target - saved) }

    var body: some View {
        VStack(alignment: .leading, spacing: size == .child ? FWSpace.s4 : FWSpace.s3) {
            HStack(spacing: 10) {
                FWIcon(glyph: .target, size: size == .child ? 26 : 20)
                    .foregroundStyle(FWColor.honey700)
                Text(title)
                    .font(FWType.rounded(size.headSize, weight: .heavy))
                    .foregroundStyle(FWColor.textStrong)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(FWColor.moneyGoalTrack)
                    Capsule()
                        .fill(reached ? FWColor.leaf500 : FWColor.moneyGoal)
                        .frame(width: max(size == .child ? 20 : 12, geo.size.width * pct))
                }
            }
            .frame(height: size == .child ? 20 : 12)
            .animation(FWMotion.easeOut(FWMotion.slow, reduceMotion: reduceMotion), value: pct)

            HStack {
                Text("已攒 ¥\(saved) / ¥\(target)")
                    .font(FWType.rounded(size == .child ? FWType.childBody : FWType.label, weight: .bold))
                    .monospacedDigit()
                    .foregroundStyle(FWColor.textBody)
                Spacer()
                Text(reached ? "你可以买了" : "还差 ¥\(left)")
                    .font(FWType.rounded(size == .child ? FWType.childBody : FWType.label, weight: .bold))
                    .foregroundStyle(reached ? FWColor.moneyIn : FWColor.honey700)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            reached
                ? "\(title)，已攒 \(saved) 元，目标 \(target) 元，你可以买了"
                : "\(title)，已攒 \(saved) 元，目标 \(target) 元，还差 \(left) 元"
        )
    }
}

struct TransactionRow: View {
    var reason: String
    var cents: Int
    var direction: MoneyDirection = .income
    var date: String
    var categoryID: String? = nil
    var balanceAfter: Int? = nil
    var size: FWControlSize = .child
    var reversed: Bool = false
    var action: (() -> Void)? = nil

    var body: some View {
        let row = HStack(spacing: size == .child ? FWSpace.s5 : FWSpace.s4) {
            ZStack {
                RoundedRectangle(cornerRadius: FWRadius.md, style: .continuous)
                    .fill(direction.iconBg)
                if let cat = categoryID.flatMap(SpendCategory.named) {
                    Text(cat.emoji).font(.system(size: size == .child ? 24 : 20))
                } else {
                    FWIcon(glyph: direction.glyph, size: size == .child ? 24 : 20)
                        .foregroundStyle(direction.color)
                }
            }
            .frame(width: size == .child ? 48 : 40, height: size == .child ? 48 : 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(reason)
                    .font(FWType.rounded(size.bodySize, weight: .bold))
                    .foregroundStyle(FWColor.textStrong)
                    .strikethrough(reversed)
                    .lineLimit(1)
                HStack(spacing: 8) {
                    Text(date)
                    if reversed { Text("· 已改正") }
                }
                .font(FWType.text(size.captionSize, weight: .regular))
                .foregroundStyle(FWColor.textMuted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .trailing, spacing: 2) {
                AmountText(cents: cents, direction: direction, size: size == .child ? .row : .small)
                if let balanceAfter {
                    Text("剩 ¥\(MoneyFormat.yuanNumber(balanceAfter))")
                        .font(FWType.mono(size == .child ? 15 : 12))
                        .foregroundStyle(FWColor.textFaint)
                }
            }
        }
        .frame(minHeight: size.touch)
        .padding(.vertical, size == .child ? FWSpace.s4 : FWSpace.s3)
        .opacity(reversed ? 0.55 : 1)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityText)

        if let action {
            Button(action: action) { row }.buttonStyle(.plain)
        } else {
            row
        }
    }

    private var accessibilityText: String {
        var parts = ["\(direction.spokenVerb) \(MoneyFormat.yuanNumber(cents)) 元", reason, date]
        if reversed { parts.append("已改正") }
        if let balanceAfter {
            parts.append("之后剩 \(MoneyFormat.yuanNumber(balanceAfter)) 元")
        }
        return parts.joined(separator: "，")
    }
}

struct CostHint: View {
    var cents: Int
    var goalTitle: String?

    var body: some View {
        HStack(spacing: 12) {
            FWIcon(glyph: .moveRight, size: 20)
                .foregroundStyle(FWColor.honey700)
            Text(label)
                .font(FWType.text(FWType.body, weight: .semibold))
                .foregroundStyle(FWColor.textOnHoney)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, FWSpace.s5)
        .padding(.vertical, FWSpace.s4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(FWColor.surfaceHoney, in: RoundedRectangle(cornerRadius: FWRadius.lg, style: .continuous))
        .accessibilityElement(children: .combine)
    }

    private var label: String {
        let yuan = MoneyFormat.yuanNumber(cents)
        if let goalTitle {
            return "离「\(goalTitle)」又远了 ¥\(yuan)"
        }
        return "离你的目标又远了 ¥\(yuan)"
    }
}
