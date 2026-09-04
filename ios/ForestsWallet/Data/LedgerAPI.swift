import Foundation

struct RemoteChild: Decodable, Equatable, Sendable {
    var id: String
    var displayName: String

    enum CodingKeys: String, CodingKey {
        case id
        case displayName = "display_name"
    }
}

struct RemoteWeek: Decodable, Equatable, Sendable {
    var start: String
    var end: String
}

struct RemoteCategory: Decodable, Equatable, Sendable {
    var id: String?
    var slug: String
    var label: String
    var sort: Int?
}

struct RemoteCategoryRef: Decodable, Equatable, Sendable {
    var slug: String
    var label: String
}

struct RemoteTransaction: Decodable, Equatable, Sendable {
    var id: String
    var amountFen: Int
    var occurredOn: String
    var recordedAt: String?
    var memo: String?
    var category: RemoteCategoryRef?
    var kind: String
    var reversesId: String?
    var replacesId: String?
    var balanceAfterFen: Int?
    var settlementWeekStart: String?
    var ruleSnapshot: String?

    enum CodingKeys: String, CodingKey {
        case id
        case amountFen = "amount_fen"
        case occurredOn = "occurred_on"
        case recordedAt = "recorded_at"
        case memo, category, kind
        case reversesId = "reverses_id"
        case replacesId = "replaces_id"
        case balanceAfterFen = "balance_after_fen"
        case settlementWeekStart = "settlement_week_start"
        case ruleSnapshot = "rule_snapshot"
    }
}

struct RemoteCheckinItem: Decodable, Equatable, Sendable {
    var id: String
    var name: String
    var weeklyTarget: Int
    var amountFen: Int
    var sort: Int?

    enum CodingKeys: String, CodingKey {
        case id, name, sort
        case weeklyTarget = "weekly_target"
        case amountFen = "amount_fen"
    }
}

struct RemoteCheckin: Decodable, Equatable, Sendable {
    var itemId: String
    var localDate: String

    enum CodingKeys: String, CodingKey {
        case itemId = "item_id"
        case localDate = "local_date"
    }
}

struct RemoteRuleChange: Decodable, Equatable, Sendable {
    var id: String
    var occurredOn: String
    var summary: String
    var recordedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, summary
        case occurredOn = "occurred_on"
        case recordedAt = "recorded_at"
    }
}

struct RemoteGoal: Decodable, Equatable, Sendable {
    var id: String
    var name: String
    var targetAmountFen: Int
    var status: String?

    enum CodingKeys: String, CodingKey {
        case id, name, status
        case targetAmountFen = "target_amount_fen"
    }
}

/// Empty-safe snapshot. Missing arrays become `[]`; missing `goal` / `null` stays nil.
struct RemoteSnapshot: Decodable, Equatable, Sendable {
    var child: RemoteChild?
    var timezone: String?
    var week: RemoteWeek?
    var balanceFen: Int
    var categories: [RemoteCategory]
    var recentTransactions: [RemoteTransaction]
    var checkinItems: [RemoteCheckinItem]
    var checkins: [RemoteCheckin]
    var ruleChanges: [RemoteRuleChange]
    var goal: RemoteGoal?

    enum CodingKeys: String, CodingKey {
        case child, timezone, week
        case balanceFen = "balance_fen"
        case categories
        case recentTransactions = "recent_transactions"
        case checkinItems = "checkin_items"
        case checkins
        case ruleChanges = "rule_changes"
        case goal
    }

    init(
        child: RemoteChild? = nil,
        timezone: String? = nil,
        week: RemoteWeek? = nil,
        balanceFen: Int = 0,
        categories: [RemoteCategory] = [],
        recentTransactions: [RemoteTransaction] = [],
        checkinItems: [RemoteCheckinItem] = [],
        checkins: [RemoteCheckin] = [],
        ruleChanges: [RemoteRuleChange] = [],
        goal: RemoteGoal? = nil
    ) {
        self.child = child
        self.timezone = timezone
        self.week = week
        self.balanceFen = balanceFen
        self.categories = categories
        self.recentTransactions = recentTransactions
        self.checkinItems = checkinItems
        self.checkins = checkins
        self.ruleChanges = ruleChanges
        self.goal = goal
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        child = try container.decodeIfPresent(RemoteChild.self, forKey: .child)
        timezone = try container.decodeIfPresent(String.self, forKey: .timezone)
        week = try container.decodeIfPresent(RemoteWeek.self, forKey: .week)
        balanceFen = try container.decodeIfPresent(Int.self, forKey: .balanceFen) ?? 0
        categories = try container.decodeIfPresent([RemoteCategory].self, forKey: .categories) ?? []
        recentTransactions = try container.decodeIfPresent([RemoteTransaction].self, forKey: .recentTransactions) ?? []
        checkinItems = try container.decodeIfPresent([RemoteCheckinItem].self, forKey: .checkinItems) ?? []
        checkins = try container.decodeIfPresent([RemoteCheckin].self, forKey: .checkins) ?? []
        ruleChanges = try container.decodeIfPresent([RemoteRuleChange].self, forKey: .ruleChanges) ?? []
        goal = try container.decodeIfPresent(RemoteGoal.self, forKey: .goal)
    }
}

struct CreateTransactionRequest: Encodable, Equatable, Sendable {
    var kind: String
    var amountFen: Int
    var occurredOn: String
    var memo: String? = nil
    var category: String? = nil

    enum CodingKeys: String, CodingKey {
        case kind
        case amountFen = "amount_fen"
        case occurredOn = "occurred_on"
        case memo, category
    }
}

struct CorrectionRequest: Encodable, Equatable, Sendable {
    var amountFen: Int
    var occurredOn: String
    var memo: String? = nil
    var category: String? = nil

    enum CodingKeys: String, CodingKey {
        case amountFen = "amount_fen"
        case occurredOn = "occurred_on"
        case memo, category
    }
}

struct CreateTransactionResponse: Decodable, Equatable, Sendable {
    var transaction: RemoteTransaction
    var balanceFen: Int

    enum CodingKeys: String, CodingKey {
        case transaction
        case balanceFen = "balance_fen"
    }
}

struct CorrectionResponse: Decodable, Equatable, Sendable {
    var original: RemoteTransaction
    var reverse: RemoteTransaction
    var replacement: RemoteTransaction
    var balanceFen: Int

    enum CodingKeys: String, CodingKey {
        case original, reverse, replacement
        case balanceFen = "balance_fen"
    }
}

struct CreateCheckinItemRequest: Encodable, Equatable, Sendable {
    var name: String
    var weeklyTarget: Int
    var amountFen: Int

    enum CodingKeys: String, CodingKey {
        case name
        case weeklyTarget = "weekly_target"
        case amountFen = "amount_fen"
    }
}

struct UpdateCheckinItemRequest: Encodable, Equatable, Sendable {
    var name: String?
    var weeklyTarget: Int?
    var amountFen: Int?

    enum CodingKeys: String, CodingKey {
        case name
        case weeklyTarget = "weekly_target"
        case amountFen = "amount_fen"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(weeklyTarget, forKey: .weeklyTarget)
        try container.encodeIfPresent(amountFen, forKey: .amountFen)
    }
}

struct CheckinItemResponse: Decodable, Equatable, Sendable {
    var item: RemoteCheckinItem
}

struct TickRequest: Encodable, Equatable, Sendable {
    var localDate: String
    var ticked: Bool

    enum CodingKeys: String, CodingKey {
        case localDate = "local_date"
        case ticked
    }
}

struct TickResponse: Decodable, Equatable, Sendable {
    var itemId: String
    var localDate: String
    var ticked: Bool

    enum CodingKeys: String, CodingKey {
        case itemId = "item_id"
        case localDate = "local_date"
        case ticked
    }
}

struct SettlementRequest: Encodable, Equatable, Sendable {
    var weekStart: String

    enum CodingKeys: String, CodingKey {
        case weekStart = "week_start"
    }
}

struct CreateGoalRequest: Encodable, Equatable, Sendable {
    var name: String
    var targetAmountFen: Int

    enum CodingKeys: String, CodingKey {
        case name
        case targetAmountFen = "target_amount_fen"
    }
}

struct GoalMutationResponse: Decodable, Equatable, Sendable {
    var goal: RemoteGoal
    var archived: RemoteGoal?
}

struct GoalArchiveResponse: Decodable, Equatable, Sendable {
    var goal: RemoteGoal
}

struct OkResponse: Decodable, Equatable, Sendable {
    var ok: Bool?
}

enum LedgerDate {
    static let shanghai = TimeZone(identifier: "Asia/Shanghai")!

    static func todayISO(now: Date = Date()) -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = shanghai
        let parts = calendar.dateComponents([.year, .month, .day], from: now)
        return String(
            format: "%04d-%02d-%02d",
            parts.year ?? 0,
            parts.month ?? 0,
            parts.day ?? 0
        )
    }

    /// Monday of the Asia/Shanghai week containing `now`.
    static func weekStartISO(now: Date = Date()) -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = shanghai
        let today = calendar.startOfDay(for: now)
        let weekday = calendar.component(.weekday, from: today) // 1 = Sunday
        let daysFromMonday = (weekday + 5) % 7
        let monday = calendar.date(byAdding: .day, value: -daysFromMonday, to: today) ?? today
        return todayISO(now: monday)
    }

    static func chinese(_ iso: String) -> String {
        let parts = iso.split(separator: "-")
        guard parts.count >= 3, let month = Int(parts[1]), let day = Int(parts[2]) else {
            return iso
        }
        return "\(month)月\(day)日"
    }

    static func weekBand(start: String, end: String) -> String {
        "\(chinese(start)) – \(chinese(end))"
    }

    static func addDays(_ iso: String, days: Int) -> String? {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: iso) else { return nil }
        guard let next = Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: date) else {
            return nil
        }
        return formatter.string(from: next)
    }
}

enum LedgerMapping {
    static func uiCategoryID(fromAPI slug: String?) -> String? {
        guard let slug, !slug.isEmpty else { return nil }
        switch slug {
        case "toys": return "toy"
        case "games": return "game"
        case "books": return "book"
        case "gifts": return "gift"
        default: return slug
        }
    }

    static func apiCategory(fromUI id: String?) -> String? {
        guard let id, !id.isEmpty else { return nil }
        switch id {
        case "toy": return "toys"
        case "game": return "games"
        case "book": return "books"
        case "gift": return "gifts"
        default: return id
        }
    }

    static func direction(kind: String, amountFen: Int) -> MoneyDirection {
        switch kind {
        case "spend":
            return .spend
        case "reverse":
            return .correction
        default:
            return amountFen < 0 ? .spend : .income
        }
    }

    static func entries(from rows: [RemoteTransaction]) -> [LedgerEntry] {
        let reversedIDs = Set(rows.compactMap(\.reversesId))
        return rows.map { row in
            let reversed = reversedIDs.contains(row.id)
            let reason = displayReason(kind: row.kind, memo: row.memo)
            let kind = row.kind
            let showCategory = kind == "spend" || (kind != "reverse" && row.amountFen < 0)
            return LedgerEntry(
                id: row.id,
                reason: reason,
                cents: abs(row.amountFen),
                direction: direction(kind: kind, amountFen: row.amountFen),
                date: LedgerDate.chinese(row.occurredOn),
                categoryID: showCategory ? uiCategoryID(fromAPI: row.category?.slug) : nil,
                balanceAfter: row.balanceAfterFen ?? 0,
                reversed: reversed,
                occurredOnISO: row.occurredOn,
                kind: kind,
                isCorrectable: kind != "reverse" && !reversed
            )
        }
    }

    static func weekLabel(from week: RemoteWeek?) -> String? {
        guard let week else { return nil }
        return LedgerDate.weekBand(start: week.start, end: week.end)
    }

    static func displayReason(kind: String, memo: String?) -> String {
        let trimmed = (memo ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty, kind == "allowance_weekly" {
            return "本周基础零花钱"
        }
        return trimmed.isEmpty ? "（没写事由）" : trimmed
    }

    static func goal(from remote: RemoteGoal?) -> Goal? {
        guard let remote else { return nil }
        let title = remote.name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { return nil }
        return Goal(id: remote.id, title: title, targetCents: remote.targetAmountFen)
    }

    static func settledThisWeek(transactions: [RemoteTransaction], weekStart: String?) -> Bool {
        guard let weekStart else { return false }
        return transactions.contains { row in
            guard row.kind == "allowance_weekly" else { return false }
            if let marked = row.settlementWeekStart {
                return marked == weekStart
            }
            return row.occurredOn == weekStart
        }
    }

    static func categories(from remote: [RemoteCategory]) -> [SpendCategory] {
        let mapped: [SpendCategory] = remote.compactMap { item in
            let uiID = uiCategoryID(fromAPI: item.slug) ?? item.slug
            if let known = SpendCategory.named(uiID) {
                return SpendCategory(id: known.id, emoji: known.emoji, label: item.label.isEmpty ? known.label : item.label)
            }
            guard !item.slug.isEmpty else { return nil }
            return SpendCategory(id: uiID, emoji: "❓", label: item.label)
        }
        return mapped.isEmpty ? SpendCategory.all : mapped
    }

    static func board(
        items: [RemoteCheckinItem],
        checkins: [RemoteCheckin],
        week: RemoteWeek?,
        todayISO: String
    ) -> [BoardItem] {
        guard let week else { return [] }
        let ticks = Set(checkins.map { "\($0.itemId)|\($0.localDate)" })
        return items.map { item in
            let days: [BoardCellState] = (0..<7).map { offset in
                let iso = LedgerDate.addDays(week.start, days: offset) ?? week.start
                if iso > todayISO { return .future }
                if ticks.contains("\(item.id)|\(iso)") { return .done }
                return .unlogged
            }
            return BoardItem(
                id: item.id,
                name: item.name,
                goal: item.weeklyTarget,
                rewardCents: item.amountFen,
                days: days
            )
        }
    }

    static func changes(from remote: [RemoteRuleChange]) -> [RuleChange] {
        remote.map {
            RuleChange(text: $0.summary, date: LedgerDate.chinese($0.occurredOn))
        }
    }

    static func writeKind(for direction: MoneyDirection) -> String? {
        switch direction {
        case .income: "income_temp"
        case .spend: "spend"
        default: nil
        }
    }

    static func signedFen(direction: MoneyDirection, yuan: Int) -> Int {
        let fen = yuan * 100
        switch direction {
        case .spend, .debt: return -fen
        default: return fen
        }
    }

    static func signedFenForCorrection(target: LedgerEntry, yuan: Int) -> Int {
        signedFen(direction: target.direction == .correction ? .income : target.direction, yuan: yuan)
    }
}
