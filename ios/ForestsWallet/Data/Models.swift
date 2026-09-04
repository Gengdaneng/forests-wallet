import Foundation

enum DeviceRole: String, Codable, Sendable {
    case parent
    case child
}

struct Goal: Hashable, Sendable {
    var title: String
    var targetCents: Int
}

struct LedgerEntry: Identifiable, Hashable, Sendable {
    var id: String
    var reason: String
    var cents: Int
    var direction: MoneyDirection
    var date: String
    var categoryID: String?
    var balanceAfter: Int
    var reversed: Bool
    var occurredOnISO: String? = nil
    var kind: String? = nil
    var isCorrectable: Bool = true
}

struct BoardItem: Identifiable, Hashable, Sendable {
    var id: String { name }
    var name: String
    var goal: Int
    var rewardCents: Int
    var days: [BoardCellState]

    var asWeekItem: WeekBoardItem {
        WeekBoardItem(name: name, goal: goal, rewardCents: rewardCents, days: days)
    }

    var doneCount: Int { days.filter { $0 == .done }.count }
    var met: Bool { doneCount >= goal }
}

struct RuleItem: Identifiable, Hashable, Sendable {
    var id: String { name + (detail ?? "") }
    var name: String
    var detail: String?
    var rewardCents: Int
    var kind: RuleKind
}

struct RuleChange: Identifiable, Hashable, Sendable {
    var id: String { text }
    var text: String
    var date: String
}

struct Wish: Identifiable, Hashable, Sendable {
    var id: String { title }
    var title: String
    var cents: Int
    var date: String
}

struct PairedDevice: Identifiable, Hashable, Sendable {
    var id: String
    var name: String
    var roleLabel: String
    var glyph: FWGlyph
    var isThisDevice: Bool
}

struct WalletSnapshot: Hashable, Sendable {
    var role: DeviceRole?
    var isOnline: Bool
    var balanceCents: Int
    var goal: Goal?
    var weekLabel: String?
    var transactions: [LedgerEntry]
    var board: [BoardItem]
    var bonusCents: Int
    var adhoc: [RuleItem]
    var changes: [RuleChange]
    var wishes: [Wish]
    var pairingCode: String?
    var sundayReminder: Bool
    var previewNeedsPIN: Bool
    var settledThisWeek: Bool
    var devices: [PairedDevice]
    var pendingCelebrationCents: Int?

    var goalReached: Bool {
        guard let goal else { return false }
        return balanceCents >= goal.targetCents
    }

    var settlementLines: [SettlementLine] {
        board.map {
            SettlementLine(name: $0.name, goal: $0.goal, doneCount: $0.doneCount, rewardCents: $0.rewardCents, met: $0.met)
        }
    }

    var bonus: SettlementBonus {
        SettlementBonus(rewardCents: bonusCents, met: !board.isEmpty && board.allSatisfy(\.met))
    }

    var settlementTotalCents: Int {
        settlementLines.reduce(0) { $0 + ($1.met ? $1.rewardCents : 0) }
            + (bonus.met ? bonus.rewardCents : 0)
    }
}

/// App service seam. Auth and paired-session ledger talk to the production API;
/// `-FW*` launch flags keep the in-memory sample store.
@MainActor
protocol WalletServing: AnyObject {
    var snapshot: WalletSnapshot { get }
    var lastRecordRejectedReason: String? { get }
    var lastAuthErrorMessage: String? { get }

    func bootstrapParent() async
    func generatePairingCode() async -> String?
    func pairChild(code: String) async -> Bool
    func resetPairing()
    func refreshDevices() async
    func refreshLedger() async

    func setOnline(_ online: Bool)
    func recordEntry(direction: MoneyDirection, yuan: Int, reason: String, categoryID: String?) async -> Bool
    func toggleBoardCell(row: Int, day: Int)
    func confirmSettlement()
    func saveBoardItem(at index: Int?, name: String, goal: Int, rewardCents: Int)
    func deleteBoardItem(at index: Int)
    func setBonusCents(_ cents: Int)
    func setSundayReminder(_ on: Bool)
    func setPreviewNeedsPIN(_ on: Bool)
    func revokeDevice(id: String) async
    func dismissCelebration()
}

enum SampleData {
    /// Deterministic pairing code for the local sample store.
    static let pairingCode = "482917"
    static let previewPIN = "1234"
    static let weekLabel = "10月1日 – 10月7日"

    static let goal = Goal(title: "乐高赛车", targetCents: 40_000)

    static let transactions: [LedgerEntry] = [
        .init(id: "9", reason: "本周基础零花钱", cents: 1000, direction: .income, date: "10月5日", categoryID: nil, balanceAfter: 8700, reversed: false),
        .init(id: "8", reason: "帮忙搬水", cents: 200, direction: .income, date: "10月4日", categoryID: nil, balanceAfter: 7700, reversed: false),
        .init(id: "7", reason: "买冰淇淋", cents: 1500, direction: .spend, date: "10月3日", categoryID: "food", balanceAfter: 7500, reversed: false),
        .init(id: "6", reason: "更正：记错了", cents: 300, direction: .correction, date: "10月2日", categoryID: nil, balanceAfter: 9000, reversed: false, isCorrectable: false),
        .init(id: "5", reason: "乐高小车", cents: 1400, direction: .spend, date: "10月2日", categoryID: "toy", balanceAfter: 8700, reversed: true, isCorrectable: false),
        .init(id: "4", reason: "画笔", cents: 900, direction: .spend, date: "9月30日", categoryID: "book", balanceAfter: 10100, reversed: false),
        .init(id: "3", reason: "上周基础零花钱", cents: 1500, direction: .income, date: "9月28日", categoryID: nil, balanceAfter: 11000, reversed: false),
        .init(id: "2", reason: "送同学生日礼物", cents: 2000, direction: .spend, date: "9月26日", categoryID: "gift", balanceAfter: 9500, reversed: false),
        .init(id: "1", reason: "期初余额", cents: 11500, direction: .income, date: "9月20日", categoryID: nil, balanceAfter: 11500, reversed: false),
    ]

    static let board: [BoardItem] = [
        .init(name: "跳绳", goal: 5, rewardCents: 500, days: [.done, .done, .done, .unlogged, .future, .future, .future]),
        .init(name: "喝牛奶", goal: 7, rewardCents: 500, days: [.done, .done, .unlogged, .future, .future, .future, .future]),
        .init(name: "上学全勤", goal: 5, rewardCents: 500, days: [.done, .done, .done, .unlogged, .future, .future, .future]),
    ]

    static let adhoc: [RuleItem] = [
        .init(name: "帮忙搬水", detail: "10月4日 · 商量好的", rewardCents: 200, kind: .adhoc),
        .init(name: "主动整理书桌", detail: "9月29日 · 商量好的", rewardCents: 300, kind: .adhoc),
        .init(name: "帮妈妈拿快递", detail: "9月24日 · 商量好的", rewardCents: 100, kind: .adhoc),
    ]

    static let changes: [RuleChange] = [
        .init(text: "从 10 月 1 日起，跳绳从 5 元变成 3 元", date: "10月1日 · 和爸爸一起决定的"),
        .init(text: "加了新的一项：上学全勤，做到有 5 元", date: "9月21日 · 和爸爸一起决定的"),
    ]

    static let wishes: [Wish] = [
        .init(title: "恐龙拼图", cents: 6800, date: "8月17日 攒到"),
        .init(title: "水彩笔一套", cents: 4500, date: "7月2日 攒到"),
    ]
}
