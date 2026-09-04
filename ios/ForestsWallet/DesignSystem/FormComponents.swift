import SwiftUI

struct NumberPad: View {
    @Binding var value: String
    var maxDigits: Int = 5

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let keys = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "clear", "0", "back"]

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: FWSpace.s4), count: 3), spacing: FWSpace.s4) {
            ForEach(keys, id: \.self) { key in
                PadKey(key: key, reduceMotion: reduceMotion) { press(key) }
            }
        }
    }

    private func press(_ key: String) {
        switch key {
        case "back":
            if !value.isEmpty { value.removeLast() }
        case "clear":
            value = ""
        default:
            if value.count >= maxDigits { return }
            if key == "0" && value.isEmpty { return }
            value.append(key)
        }
    }
}

private struct PadKey: View {
    var key: String
    var reduceMotion: Bool
    var action: () -> Void

    var body: some View {
        let special = key == "back" || key == "clear"
        Button(action: action) {
            Group {
                if key == "back" {
                    FWIcon(glyph: .delete, size: 24)
                } else if key == "clear" {
                    FWIcon(glyph: .eraser, size: 24)
                } else {
                    Text(key)
                        .font(FWType.rounded(28, weight: .heavy))
                }
            }
            .foregroundStyle(FWColor.textStrong)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 62)
            .background(special ? Color.clear : FWColor.surfaceCard)
            .clipShape(RoundedRectangle(cornerRadius: FWRadius.md, style: .continuous))
            .modifier(ConditionalCardShadow(enabled: !special))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(key == "back" ? "删除" : key == "clear" ? "清空" : key)
        .accessibilityIdentifier("pad.\(key)")
    }
}

private struct ConditionalCardShadow: ViewModifier {
    var enabled: Bool
    func body(content: Content) -> some View {
        if enabled { content.fwCardShadow(child: false) } else { content }
    }
}

struct DigitHero: View {
    var value: String
    var label: String? = nil
    var placeholder: String = "0"
    var accessibilityName: String = "数字"

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: FWSpace.s3) {
            if let label {
                Text(label)
                    .font(FWType.text(FWType.label, weight: .semibold))
                    .foregroundStyle(FWColor.textMuted)
            }
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value.isEmpty ? placeholder : value)
                    .font(FWType.rounded(56, weight: .black))
                    .monospacedDigit()
                    .foregroundStyle(FWColor.spruce700)
                    .lineLimit(1)
                    .minimumScaleFactor(0.4)
                    .tracking(value.count > 1 ? 6 : 0)
                CaretBar(color: FWColor.spruce700, reduceMotion: reduceMotion)
            }
        }
        .padding(.vertical, FWSpace.s6)
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(accessibilityName) \(value.isEmpty ? placeholder : value)")
        .accessibilityIdentifier("digit.hero")
    }
}

struct AmountField: View {
    var value: String
    var direction: MoneyDirection = .income
    var label: String? = nil

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: FWSpace.s3) {
            if let label {
                Text(label)
                    .font(FWType.text(FWType.label, weight: .semibold))
                    .foregroundStyle(FWColor.textMuted)
            }
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(direction.sign)¥")
                    .font(FWType.rounded(40, weight: .black))
                Text(value.isEmpty ? "0" : value)
                    .font(FWType.rounded(64, weight: .black))
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.4)
                CaretBar(color: direction.color, reduceMotion: reduceMotion)
                    .padding(.leading, 4)
            }
            .foregroundStyle(direction.color)
            .tracking(-0.8)
        }
        .padding(.vertical, FWSpace.s6)
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label ?? direction.spokenVerb) \(value.isEmpty ? "0" : value) 元")
        .accessibilityIdentifier("amount.field")
    }
}

private struct CaretBar: View {
    var color: Color
    var reduceMotion: Bool
    @State private var on = true

    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(color)
            .frame(width: 3, height: 48)
            .opacity(reduceMotion ? 1 : (on ? 1 : 0))
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                    on = false
                }
            }
            .accessibilityHidden(true)
    }
}

struct FWTextField: View {
    var label: String? = nil
    @Binding var value: String
    var placeholder: String = ""
    var optional: Bool = false
    var maxLength: Int? = nil
    var size: FWControlSize = .parent
    var keyboard: UIKeyboardType = .default

    @FocusState private var focused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: FWSpace.s3) {
            if let label {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(label)
                        .font(FWType.text(FWType.label, weight: .semibold))
                        .foregroundStyle(FWColor.textBody)
                    if optional {
                        Text("可跳过")
                            .font(FWType.text(FWType.caption, weight: .regular))
                            .foregroundStyle(FWColor.textFaint)
                    }
                }
            }
            TextField(placeholder, text: $value)
                .font(FWType.text(size.bodySize, weight: .regular))
                .foregroundStyle(FWColor.textStrong)
                .keyboardType(keyboard)
                .focused($focused)
                .padding(.horizontal, FWSpace.s4)
                .frame(minHeight: size.touch)
                .background(FWColor.surfaceCard)
                .clipShape(RoundedRectangle(cornerRadius: FWRadius.control, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: FWRadius.control, style: .continuous)
                        .strokeBorder(focused ? FWColor.spruce500 : FWColor.borderCard, lineWidth: 1.5)
                )
                .shadow(color: focused ? FWColor.honey600.opacity(0.55) : .clear, radius: 3)
                .onChange(of: value) { _, new in
                    if let maxLength, new.count > maxLength {
                        value = String(new.prefix(maxLength))
                    }
                }
        }
    }
}

struct CategoryPicker: View {
    @Binding var value: String?
    var categories: [SpendCategory] = SpendCategory.all
    var size: FWControlSize = .parent
    var label: String = "花在什么上"

    var body: some View {
        VStack(alignment: .leading, spacing: FWSpace.s3) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(label)
                    .font(FWType.text(FWType.label, weight: .semibold))
                    .foregroundStyle(FWColor.textBody)
                Text("可跳过，默认「其他」")
                    .font(FWType.text(FWType.caption, weight: .regular))
                    .foregroundStyle(FWColor.textFaint)
            }
            FlowLayout(spacing: FWSpace.s3) {
                ForEach(categories) { cat in
                    FWTag(category: cat, selected: value == cat.id, size: size) {
                        value = (value == cat.id) ? nil : cat.id
                    }
                }
            }
        }
    }
}

/// Simple wrapping layout for category tags.
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, origin) in result.origins.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + origin.x, y: bounds.minY + origin.y),
                proposal: .unspecified
            )
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, origins: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var origins: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var width: CGFloat = 0

        for sub in subviews {
            let size = sub.sizeThatFits(.unspecified)
            if x > 0 && x + size.width > maxWidth {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            origins.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            width = max(width, x - spacing)
        }
        return (CGSize(width: width, height: y + rowHeight), origins)
    }
}

struct FWToggle: View {
    var label: String
    var hint: String? = nil
    @Binding var isOn: Bool
    var disabled: Bool = false

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Button {
            if !disabled { isOn.toggle() }
        } label: {
            HStack(spacing: FWSpace.s4) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(FWType.text(FWType.body, weight: .semibold))
                        .foregroundStyle(FWColor.textStrong)
                    if let hint {
                        Text(hint)
                            .font(FWType.text(FWType.caption, weight: .regular))
                            .foregroundStyle(FWColor.textMuted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                ZStack(alignment: isOn ? .trailing : .leading) {
                    Capsule()
                        .fill(disabled ? FWColor.disabledBg : isOn ? FWColor.leaf500 : FWColor.paper300)
                    Circle()
                        .fill(FWColor.paper000)
                        .shadow(color: FWColor.spruce900.opacity(0.28), radius: 1.5, y: 1)
                        .padding(3)
                }
                .frame(width: 52, height: 32)
                .animation(FWMotion.bounce(FWMotion.fast, reduceMotion: reduceMotion), value: isOn)
            }
            .frame(minHeight: FWSpace.touchParent)
        }
        .buttonStyle(.plain)
        .disabled(disabled)
        .accessibilityLabel(label)
        .accessibilityValue(isOn ? "打开" : "关闭")
        .accessibilityAddTraits(.isButton)
    }
}
