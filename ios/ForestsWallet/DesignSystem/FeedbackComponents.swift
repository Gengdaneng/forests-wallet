import SwiftUI

enum StatusKind: String {
    case offline, failed, online, norealmoney

    var icon: FWGlyph {
        switch self {
        case .offline: .cloudOff
        case .failed: .refreshOff
        case .online: .checkCircle
        case .norealmoney: .shieldCheck
        }
    }

    var background: Color {
        switch self {
        case .offline: return FWColor.slate100
        case .failed: return FWColor.moneyOutBg
        case .online: return FWColor.moneyInBg
        case .norealmoney: return FWColor.surfaceSunken
        }
    }

    var foreground: Color {
        switch self {
        case .offline: return FWColor.slate600
        case .failed: return FWColor.moneyOut
        case .online: return FWColor.moneyIn
        case .norealmoney: return FWColor.textMuted
        }
    }

    var defaultText: String {
        switch self {
        case .offline: "正在显示已保存的信息"
        case .failed: "更新失败，这是上次保存的信息"
        case .online: "信息是最新的"
        case .norealmoney: "只是记账，没有真的钱在动"
        }
    }
}

struct StatusBanner: View {
    var kind: StatusKind = .offline
    var text: String? = nil
    var size: FWControlSize = .child

    var body: some View {
        HStack(spacing: 10) {
            FWIcon(glyph: kind.icon, size: size == .child ? 20 : 16)
            Text(text ?? kind.defaultText)
                .font(FWType.text(size == .child ? FWType.childLabel : FWType.caption, weight: .semibold))
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .foregroundStyle(kind.foreground)
        .padding(.horizontal, size == .child ? 18 : 14)
        .padding(.vertical, size == .child ? 10 : 8)
        .background(kind.background, in: Capsule())
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.updatesFrequently)
        .accessibilityIdentifier("status.\(kind.rawValue)")
    }
}

struct EmptyState: View {
    var icon: FWGlyph = .notebook
    var title: String
    var bodyText: String? = nil
    var size: FWControlSize = .child

    var body: some View {
        VStack(spacing: FWSpace.s3) {
            ZStack {
                RoundedRectangle(cornerRadius: FWRadius.xl, style: .continuous)
                    .fill(FWColor.surfaceLeaf)
                FWIcon(glyph: icon, size: size == .child ? 40 : 30)
                    .foregroundStyle(FWColor.spruce600)
            }
            .frame(width: size == .child ? 88 : 64, height: size == .child ? 88 : 64)
            .padding(.bottom, FWSpace.s2)

            Text(title)
                .font(FWType.rounded(size.headSize, weight: .heavy))
                .foregroundStyle(FWColor.textStrong)
                .multilineTextAlignment(.center)

            if let bodyText {
                Text(bodyText)
                    .font(FWType.text(size.bodySize, weight: .regular))
                    .foregroundStyle(FWColor.textMuted)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 420)
            }
        }
        .padding(size == .child ? EdgeInsets(top: FWSpace.s10, leading: FWSpace.s7, bottom: FWSpace.s10, trailing: FWSpace.s7) : EdgeInsets(top: FWSpace.s8, leading: FWSpace.s5, bottom: FWSpace.s8, trailing: FWSpace.s5))
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }
}

struct Celebration: View {
    var cents: Int
    var reason: String? = nil
    var onDone: (() -> Void)? = nil

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var popped = false

    var body: some View {
        ZStack {
            if !reduceMotion {
                FallingLeaves()
            }
            VStack(spacing: FWSpace.s3) {
                Text("加进来了")
                    .font(FWType.rounded(FWType.childHead, weight: .heavy))
                    .foregroundStyle(FWColor.spruce700)
                AmountText(cents: cents, direction: .income, size: .heroSm)
                    .scaleEffect(popped || reduceMotion ? 1 : 0.6)
                if let reason {
                    Text(reason)
                        .font(FWType.text(FWType.childBody, weight: .regular))
                        .foregroundStyle(FWColor.spruce600)
                }
            }
            .padding(.vertical, FWSpace.s9)
            .padding(.horizontal, FWSpace.s7)
        }
        .frame(maxWidth: .infinity)
        .background(FWColor.surfaceLeaf)
        .clipShape(RoundedRectangle(cornerRadius: FWRadius.xxl, style: .continuous))
        .clipped()
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.updatesFrequently)
        .onAppear {
            if !reduceMotion {
                withAnimation(FWMotion.bounce(FWMotion.celebrate, reduceMotion: false)) {
                    popped = true
                }
            }
            if let onDone {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) { onDone() }
            }
        }
    }
}

private struct FallingLeaves: View {
    private let offsets: [CGFloat] = [-160, -95, -30, 35, 100, 165]
    @State private var dropped = false

    var body: some View {
        GeometryReader { geo in
            ForEach(Array(offsets.enumerated()), id: \.offset) { i, x in
                RoundedRectangle(cornerRadius: 6)
                    .fill(i.isMultiple(of: 2) ? FWColor.leaf500 : FWColor.honey500)
                    .frame(width: 14, height: 14)
                    .rotationEffect(.degrees(dropped ? 220 : 0))
                    .position(x: geo.size.width / 2 + x, y: dropped ? geo.size.height + 20 : -12)
                    .opacity(dropped ? 0 : 1)
                    .animation(
                        .timingCurve(0.16, 1, 0.3, 1, duration: FWMotion.celebrate)
                            .delay(Double(i) * 0.07),
                        value: dropped
                    )
            }
        }
        .allowsHitTesting(false)
        .onAppear { dropped = true }
    }
}
