import SwiftUI

/// Hex values from `DesignSystem/Reference/tokens/colors.css`.
enum FWPalette {
    static let spruce900: UInt32 = 0x0E2A24
    static let spruce800: UInt32 = 0x123329
    static let spruce700: UInt32 = 0x173D35
    static let spruce600: UInt32 = 0x245247
    static let spruce500: UInt32 = 0x356B5D
    static let spruce300: UInt32 = 0x7BA79A
    static let spruce100: UInt32 = 0xC3DCD3

    static let leaf500: UInt32 = 0x4F9E68
    static let leaf400: UInt32 = 0x7FBE8C
    static let leaf300: UInt32 = 0xAFDCAE
    static let leaf200: UInt32 = 0xD8EDD5
    static let leaf100: UInt32 = 0xEAF6E7

    static let honey700: UInt32 = 0xA9741A
    static let honey600: UInt32 = 0xD9A93C
    static let honey500: UInt32 = 0xF3C968
    static let honey300: UInt32 = 0xF8DFA4
    static let honey100: UInt32 = 0xFCF1D8

    static let paper000: UInt32 = 0xFFFDF7
    static let paper100: UInt32 = 0xFBF7ED
    static let paper200: UInt32 = 0xF4EEDF
    static let paper300: UInt32 = 0xE9E0CB
    static let paper400: UInt32 = 0xD8CCB0

    static let clay600: UInt32 = 0x8C6A50
    static let clay400: UInt32 = 0xB99274
    static let clay100: UInt32 = 0xEFE2D5
    static let berry600: UInt32 = 0xBE3E2B
    static let berry400: UInt32 = 0xD9705E
    static let berry100: UInt32 = 0xF7E1DC
    static let slate600: UInt32 = 0x3E6E8E
    static let slate100: UInt32 = 0xE1ECF2

    static let textMuted: UInt32 = 0x6B7C74
    static let textFaint: UInt32 = 0x94A39C
    static let dangerPress: UInt32 = 0x9E3222
}

extension Color {
    init(fw hex: UInt32, alpha: Double = 1) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}

enum FWColor {
    static let spruce900 = Color(fw: FWPalette.spruce900)
    static let spruce800 = Color(fw: FWPalette.spruce800)
    static let spruce700 = Color(fw: FWPalette.spruce700)
    static let spruce600 = Color(fw: FWPalette.spruce600)
    static let spruce500 = Color(fw: FWPalette.spruce500)
    static let spruce300 = Color(fw: FWPalette.spruce300)
    static let spruce100 = Color(fw: FWPalette.spruce100)

    static let leaf500 = Color(fw: FWPalette.leaf500)
    static let leaf200 = Color(fw: FWPalette.leaf200)
    static let leaf100 = Color(fw: FWPalette.leaf100)

    static let honey700 = Color(fw: FWPalette.honey700)
    static let honey600 = Color(fw: FWPalette.honey600)
    static let honey500 = Color(fw: FWPalette.honey500)
    static let honey100 = Color(fw: FWPalette.honey100)

    static let paper000 = Color(fw: FWPalette.paper000)
    static let paper100 = Color(fw: FWPalette.paper100)
    static let paper200 = Color(fw: FWPalette.paper200)
    static let paper300 = Color(fw: FWPalette.paper300)
    static let paper400 = Color(fw: FWPalette.paper400)

    static let clay600 = Color(fw: FWPalette.clay600)
    static let clay100 = Color(fw: FWPalette.clay100)
    static let berry600 = Color(fw: FWPalette.berry600)
    static let berry400 = Color(fw: FWPalette.berry400)
    static let berry100 = Color(fw: FWPalette.berry100)
    static let slate600 = Color(fw: FWPalette.slate600)
    static let slate100 = Color(fw: FWPalette.slate100)

    static let surfaceApp = paper100
    static let surfaceCard = paper000
    static let surfaceSunken = paper200
    static let surfaceInk = spruce700
    static let surfaceLeaf = leaf200
    static let surfaceHoney = honey100
    static let surfaceOverlay = Color(fw: FWPalette.spruce900, alpha: 0.42)

    static let textBody = spruce800
    static let textStrong = spruce900
    static let textMuted = Color(fw: FWPalette.textMuted)
    static let textFaint = Color(fw: FWPalette.textFaint)
    static let textOnInk = paper100
    static let textOnInkMuted = Color(fw: FWPalette.paper100, alpha: 0.66)
    static let textOnHoney = spruce800

    static let moneyIn = leaf500
    static let moneyInBg = leaf100
    static let moneyOut = clay600
    static let moneyOutBg = clay100
    static let moneyFix = slate600
    static let moneyFixBg = slate100
    static let moneyDebt = berry600
    static let moneyDebtBg = berry100
    static let moneyGoal = honey600
    static let moneyGoalTrack = honey100

    static let actionPrimary = spruce700
    static let actionPrimaryPress = spruce900
    static let actionPrimaryText = paper100
    static let actionAccent = honey500
    static let actionAccentPress = honey600
    static let actionAccentText = spruce800
    static let actionQuietBg = paper200
    static let actionQuietPress = paper300
    static let actionDanger = berry600
    static let actionDangerPress = Color(fw: FWPalette.dangerPress)
    static let focusRing = honey600
    static let disabledBg = paper300
    static let disabledText = textFaint

    static let borderHair = paper300
    static let borderCard = paper300
    static let borderStrong = spruce300
    static let borderInk = Color(fw: FWPalette.spruce700, alpha: 0.14)

    static let cellDoneBg = leaf200
    static let cellDoneInk = spruce700
    static let cellUnloggedBg = paper000
    static let cellUnloggedLine = paper400
    static let cellFutureBg = paper200
    static let cellFutureInk = textFaint
    static let cellMissedBg = clay100
    static let cellMissedInk = clay600

    static let sidebarActive = Color(fw: FWPalette.paper100, alpha: 0.14)
}

enum FWSpace {
    static let s1: CGFloat = 2
    static let s2: CGFloat = 4
    static let s3: CGFloat = 8
    static let s4: CGFloat = 12
    static let s5: CGFloat = 16
    static let s6: CGFloat = 20
    static let s7: CGFloat = 24
    static let s8: CGFloat = 32
    static let s9: CGFloat = 40
    static let s10: CGFloat = 48
    static let s11: CGFloat = 64
    static let s12: CGFloat = 80

    static let gutterPhone: CGFloat = 16
    static let gutterPad: CGFloat = 32
    static let cardPadParent: CGFloat = 16
    static let cardPadChild: CGFloat = 24
    static let stackTight: CGFloat = 8
    static let stack: CGFloat = 12
    static let stackLoose: CGFloat = 20
    static let sectionGap: CGFloat = 32

    static let touchMin: CGFloat = 44
    static let touchParent: CGFloat = 48
    static let touchChild: CGFloat = 54

    static let maxChildColumn: CGFloat = 720
    static let sidebarWidth: CGFloat = 280
}

enum FWRadius {
    static let xs: CGFloat = 6
    static let sm: CGFloat = 10
    static let md: CGFloat = 16
    static let lg: CGFloat = 20
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
    static let pill: CGFloat = 999
    static let cardParent: CGFloat = md
    static let cardChild: CGFloat = xl
    static let control: CGFloat = md
    static let cell: CGFloat = sm
}

enum FWType {
    static let balanceSize: CGFloat = 96
    static let balanceSmSize: CGFloat = 56
    static let childTitle: CGFloat = 34
    static let childHead: CGFloat = 26
    static let childBody: CGFloat = 20
    static let childLabel: CGFloat = 17
    static let title: CGFloat = 28
    static let head: CGFloat = 20
    static let body: CGFloat = 17
    static let label: CGFloat = 15
    static let caption: CGFloat = 13
    static let amount: CGFloat = 22
    static let amountSm: CGFloat = 17

    static func rounded(_ size: CGFloat, weight: Font.Weight) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }

    static func text(_ size: CGFloat, weight: Font.Weight) -> Font {
        .system(size: size, weight: weight, design: .default)
    }

    static func mono(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }
}

enum FWControlSize {
    case child, parent, small

    var touch: CGFloat {
        switch self {
        case .child: FWSpace.touchChild
        case .parent: FWSpace.touchParent
        case .small: FWSpace.touchMin
        }
    }

    var cardRadius: CGFloat {
        self == .child ? FWRadius.cardChild : FWRadius.cardParent
    }

    var cardPad: CGFloat {
        self == .child ? FWSpace.cardPadChild : FWSpace.cardPadParent
    }

    var titleSize: CGFloat { self == .child ? FWType.childTitle : FWType.title }
    var headSize: CGFloat { self == .child ? FWType.childHead : FWType.head }
    var bodySize: CGFloat { self == .child ? FWType.childBody : FWType.body }
    var labelSize: CGFloat { self == .child ? FWType.childLabel : FWType.label }
    var captionSize: CGFloat { self == .child ? FWType.childLabel : FWType.caption }
    var amountSize: CGFloat { self == .child ? FWType.amount : FWType.amountSm }
    var gutter: CGFloat { self == .child ? FWSpace.gutterPad : FWSpace.gutterPhone }
    var pressScale: CGFloat { self == .child ? 0.95 : 0.97 }
}

private struct FWControlSizeKey: EnvironmentKey {
    static let defaultValue: FWControlSize = .parent
}

extension EnvironmentValues {
    var fwSize: FWControlSize {
        get { self[FWControlSizeKey.self] }
        set { self[FWControlSizeKey.self] = newValue }
    }
}

enum FWMotion {
    static let instant: TimeInterval = 0.12
    static let fast: TimeInterval = 0.20
    static let base: TimeInterval = 0.32
    static let slow: TimeInterval = 0.52
    static let celebrate: TimeInterval = 0.90

    static func duration(_ seconds: TimeInterval, reduceMotion: Bool) -> TimeInterval {
        reduceMotion ? 0 : seconds
    }

    static func standard(_ seconds: TimeInterval, reduceMotion: Bool) -> Animation {
        reduceMotion
            ? .linear(duration: 0)
            : .timingCurve(0.2, 0.8, 0.2, 1, duration: seconds)
    }

    static func easeOut(_ seconds: TimeInterval, reduceMotion: Bool) -> Animation {
        reduceMotion
            ? .linear(duration: 0)
            : .timingCurve(0.16, 1, 0.3, 1, duration: seconds)
    }

    static func bounce(_ seconds: TimeInterval, reduceMotion: Bool) -> Animation {
        reduceMotion
            ? .linear(duration: 0)
            : .timingCurve(0.34, 1.56, 0.64, 1, duration: seconds)
    }
}

struct FWCardShadow: ViewModifier {
    var child: Bool
    var raised: Bool = false

    func body(content: Content) -> some View {
        if raised {
            content.shadow(color: FWColor.spruce700.opacity(0.10), radius: 12, y: 8)
        } else if child {
            content
                .shadow(color: FWColor.spruce700.opacity(0.05), radius: 0, y: 2)
                .shadow(color: FWColor.spruce700.opacity(0.07), radius: 8, y: 6)
        } else {
            content
                .shadow(color: FWColor.spruce700.opacity(0.04), radius: 0, y: 1)
                .shadow(color: FWColor.spruce700.opacity(0.05), radius: 3, y: 2)
        }
    }
}

extension View {
    func fwCardShadow(child: Bool, raised: Bool = false) -> some View {
        modifier(FWCardShadow(child: child, raised: raised))
    }

    func fwScreenBackground() -> some View {
        background(FWColor.surfaceApp.ignoresSafeArea())
    }
}

enum MoneyFormat {
    /// Cents in, whole yuan out, zh-CN grouping. Matches `formatYuan`.
    static func yuan(_ cents: Int) -> String {
        let value = abs(cents) / 100
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.minimumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    static func yuanNumber(_ cents: Int) -> Int {
        abs(cents) / 100
    }
}
