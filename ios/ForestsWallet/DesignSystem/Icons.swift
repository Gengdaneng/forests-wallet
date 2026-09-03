import SwiftUI

/// Line-drawing icons. Lucide names from the design system mapped to SF Symbols.
enum FWGlyph: String, Hashable {
    case wallet
    case calendarCheck
    case scrollText
    case list
    case sparkles
    case target
    case arrowDownLeft
    case arrowUpRight
    case rotateCcw
    case alertTriangle
    case cloudOff
    case shieldCheck
    case settings
    case tablet
    case smartphone
    case plus
    case minus
    case chevronRight
    case chevronLeft
    case lock
    case eye
    case pencil
    case trash
    case gift
    case check
    case checkCircle
    case refreshOff
    case notebook
    case partyPopper
    case delete
    case eraser
    case moveRight
    case equal
    case `repeat`
    case link
    case clock
    case repeatIcon

    var systemName: String {
        switch self {
        case .wallet: "wallet.pass"
        case .calendarCheck: "calendar.badge.checkmark"
        case .scrollText: "text.justify.leading"
        case .list: "list.bullet"
        case .sparkles: "sparkles"
        case .target: "target"
        case .arrowDownLeft: "arrow.down.left"
        case .arrowUpRight: "arrow.up.right"
        case .rotateCcw: "arrow.counterclockwise"
        case .alertTriangle: "exclamationmark.triangle"
        case .cloudOff: "icloud.slash"
        case .shieldCheck: "checkmark.shield"
        case .settings: "gearshape"
        case .tablet: "ipad"
        case .smartphone: "iphone"
        case .plus: "plus"
        case .minus: "minus"
        case .chevronRight: "chevron.right"
        case .chevronLeft: "chevron.left"
        case .lock: "lock"
        case .eye: "eye"
        case .pencil: "pencil"
        case .trash: "trash"
        case .gift: "gift"
        case .check: "checkmark"
        case .checkCircle: "checkmark.circle"
        case .refreshOff: "arrow.triangle.2.circlepath"
        case .notebook: "book"
        case .partyPopper: "sparkle"
        case .delete: "delete.backward"
        case .eraser: "eraser"
        case .moveRight: "arrow.right"
        case .equal: "equal"
        case .repeat, .repeatIcon: "repeat"
        case .link: "link"
        case .clock: "clock"
        }
    }
}

struct FWIcon: View {
    var glyph: FWGlyph
    var size: CGFloat = 24
    var weight: Font.Weight = .medium
    var label: String? = nil

    var body: some View {
        Image(systemName: glyph.systemName)
            .font(.system(size: size * 0.84, weight: weight))
            .frame(width: size, height: size)
            .accessibilityLabel(label ?? "")
            .accessibilityHidden(label == nil)
    }
}
