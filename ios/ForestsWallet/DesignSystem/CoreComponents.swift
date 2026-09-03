import SwiftUI

enum FWButtonTone {
    case primary, accent, quiet, outline, danger
}

struct FWButton: View {
    var title: String
    var tone: FWButtonTone = .primary
    var size: FWControlSize = .parent
    var icon: FWGlyph? = nil
    var iconAfter: FWGlyph? = nil
    var block: Bool = false
    var disabled: Bool = false
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: size == .small ? 6 : size == .child ? 10 : 8) {
                if let icon {
                    FWIcon(glyph: icon, size: size == .small ? 16 : 20)
                }
                Text(title)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                if let iconAfter {
                    FWIcon(glyph: iconAfter, size: size == .small ? 16 : 20)
                }
            }
            .font(FWType.rounded(size == .child ? FWType.childLabel : size == .small ? FWType.caption : FWType.label, weight: .heavy))
            .foregroundStyle(foreground)
            .frame(maxWidth: block ? .infinity : nil)
            .frame(minHeight: size.touch)
            .padding(.horizontal, size == .child ? FWSpace.s7 : size == .small ? FWSpace.s4 : FWSpace.s6)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .strokeBorder(border, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
        .disabled(disabled)
        .accessibilityLabel(title)
    }

    private var radius: CGFloat {
        switch size {
        case .child: FWRadius.xl
        case .parent: FWRadius.md
        case .small: FWRadius.sm
        }
    }

    private var background: Color {
        if disabled { return FWColor.disabledBg }
        switch tone {
        case .primary: return FWColor.actionPrimary
        case .accent: return FWColor.actionAccent
        case .quiet: return FWColor.actionQuietBg
        case .outline: return Color.clear
        case .danger: return FWColor.actionDanger
        }
    }

    private var foreground: Color {
        if disabled { return FWColor.disabledText }
        switch tone {
        case .primary: return FWColor.actionPrimaryText
        case .accent: return FWColor.actionAccentText
        case .quiet, .outline: return FWColor.textBody
        case .danger: return FWColor.paper100
        }
    }

    private var border: Color {
        if disabled { return .clear }
        return tone == .outline ? FWColor.borderStrong : .clear
    }
}

enum FWCardTone {
    case paper, sunken, leaf, honey, ink
}

struct FWCard<Content: View>: View {
    var variant: FWControlSize = .parent
    var tone: FWCardTone = .paper
    var pad: CGFloat? = nil
    var action: (() -> Void)? = nil
    @ViewBuilder var content: () -> Content

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: variant.cardRadius, style: .continuous)
        Group {
            if let action {
                Button(action: action) { cardBody }.buttonStyle(.plain)
            } else {
                cardBody
            }
        }
        .background(fill)
        .clipShape(shape)
        .overlay(shape.strokeBorder(stroke, lineWidth: 1))
        .modifier(ConditionalShadow(enabled: tone != .sunken, child: variant == .child))
        .contentShape(shape)
    }

    private var cardBody: some View {
        content()
            .padding(pad ?? variant.cardPad)
            .foregroundStyle(ink)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var fill: Color {
        switch tone {
        case .paper: return FWColor.surfaceCard
        case .sunken: return FWColor.surfaceSunken
        case .leaf: return FWColor.surfaceLeaf
        case .honey: return FWColor.surfaceHoney
        case .ink: return FWColor.surfaceInk
        }
    }

    private var stroke: Color {
        tone == .paper ? FWColor.borderCard : .clear
    }

    private var ink: Color {
        switch tone {
        case .ink: return FWColor.textOnInk
        case .honey: return FWColor.textOnHoney
        case .leaf: return FWColor.spruce800
        default: return FWColor.textBody
        }
    }
}

private struct ConditionalShadow: ViewModifier {
    var enabled: Bool
    var child: Bool
    func body(content: Content) -> some View {
        if enabled {
            content.fwCardShadow(child: child)
        } else {
            content
        }
    }
}

enum FWBadgeTone {
    case income, spend, fix, debt, goal, neutral
}

struct FWBadge: View {
    var text: String
    var tone: FWBadgeTone = .neutral
    var icon: FWGlyph? = nil
    var size: FWControlSize = .parent

    var body: some View {
        HStack(spacing: 6) {
            if let icon {
                FWIcon(glyph: icon, size: size == .child ? 18 : 14)
            }
            Text(text)
        }
        .font(FWType.rounded(size == .child ? FWType.childLabel : FWType.caption, weight: .heavy))
        .foregroundStyle(colors.fg)
        .padding(.horizontal, size == .child ? 14 : 10)
        .padding(.vertical, size == .child ? 6 : 4)
        .background(colors.bg, in: Capsule())
        .accessibilityElement(children: .combine)
    }

    private var colors: (bg: Color, fg: Color) {
        switch tone {
        case .income: (FWColor.moneyInBg, FWColor.moneyIn)
        case .spend: (FWColor.moneyOutBg, FWColor.moneyOut)
        case .fix: (FWColor.moneyFixBg, FWColor.moneyFix)
        case .debt: (FWColor.moneyDebtBg, FWColor.moneyDebt)
        case .goal: (FWColor.moneyGoalTrack, FWColor.honey700)
        case .neutral: (FWColor.surfaceSunken, FWColor.textMuted)
        }
    }
}

struct SpendCategory: Identifiable, Hashable, Sendable {
    var id: String
    var emoji: String
    var label: String

    static let all: [SpendCategory] = [
        .init(id: "food", emoji: "🍦", label: "吃的"),
        .init(id: "toy", emoji: "🧸", label: "玩具"),
        .init(id: "game", emoji: "🎮", label: "游戏"),
        .init(id: "book", emoji: "📚", label: "书和文具"),
        .init(id: "gift", emoji: "🎁", label: "送人的礼物"),
        .init(id: "other", emoji: "❓", label: "其他"),
    ]

    static func named(_ id: String) -> SpendCategory? {
        all.first { $0.id == id }
    }
}

struct FWTag: View {
    var category: SpendCategory
    var selected: Bool = false
    var size: FWControlSize = .parent
    var action: (() -> Void)? = nil

    var body: some View {
        let pill = HStack(spacing: 8) {
            Text(category.emoji).font(.system(size: size == .child ? 22 : 18))
            Text(category.label)
                .font(FWType.text(size.labelSize, weight: .semibold))
                .foregroundStyle(FWColor.textBody)
        }
        .padding(.horizontal, size == .child ? 18 : 14)
        .padding(.vertical, size == .child ? 10 : 8)
        .frame(minHeight: action == nil ? nil : size.touch)
        .background(selected ? FWColor.surfaceLeaf : FWColor.surfaceSunken, in: Capsule())
        .overlay(
            Capsule().strokeBorder(selected ? FWColor.leaf500 : .clear, lineWidth: 1.5)
        )

        if let action {
            Button(action: action) { pill }
                .buttonStyle(.plain)
                .accessibilityAddTraits(selected ? [.isSelected] : [])
                .accessibilityLabel(category.label)
        } else {
            pill.accessibilityElement(children: .combine)
        }
    }
}

struct FWIconButton: View {
    var icon: FWGlyph
    var label: String
    var tone: FWButtonTone = .quiet
    var size: FWControlSize = .parent
    var bare: Bool = false
    var disabled: Bool = false
    var action: () -> Void

    var body: some View {
        let dim = size.touch
        Button(action: action) {
            FWIcon(glyph: icon, size: size == .small ? 18 : 24)
                .foregroundStyle(foreground)
                .frame(width: dim, height: dim)
                .background(background)
                .clipShape(RoundedRectangle(cornerRadius: size == .child ? FWRadius.lg : FWRadius.md, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(disabled)
        .accessibilityLabel(label)
    }

    private var background: Color {
        if disabled { return FWColor.disabledBg }
        if bare { return .clear }
        switch tone {
        case .primary: return FWColor.actionPrimary
        case .accent: return FWColor.actionAccent
        default: return FWColor.actionQuietBg
        }
    }

    private var foreground: Color {
        if disabled { return FWColor.disabledText }
        switch tone {
        case .primary: return FWColor.actionPrimaryText
        case .accent: return FWColor.actionAccentText
        default: return FWColor.textBody
        }
    }
}

struct FWScreenTitle: View {
    var text: String
    var size: FWControlSize = .parent

    var body: some View {
        Text(text)
            .font(FWType.rounded(size.titleSize, weight: .heavy))
            .foregroundStyle(FWColor.textStrong)
            .tracking(-0.4)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityAddTraits(.isHeader)
    }
}
