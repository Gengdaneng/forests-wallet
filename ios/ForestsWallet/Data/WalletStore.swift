import Foundation
import SwiftUI

enum LaunchRole: String {
    case unpaired, parent, child
}

@Observable
@MainActor
final class SampleWalletStore: WalletServing {
    private(set) var role: DeviceRole?
    var isOnline: Bool = true
    var balanceCents: Int = 8700
    var goal: Goal = SampleData.goal
    var transactions: [LedgerEntry] = SampleData.transactions
    var board: [BoardItem] = SampleData.board
    var bonusCents: Int = 300
    var adhoc: [RuleItem] = SampleData.adhoc
    var changes: [RuleChange] = SampleData.changes
    var wishes: [Wish] = SampleData.wishes
    var pairingCode: String?
    var sundayReminder: Bool = true
    var previewNeedsPIN: Bool = true
    var settledThisWeek: Bool = false
    var devices: [PairedDevice] = []
    var pendingCelebrationCents: Int?
    var lastRecordRejectedReason: String?

    var hasSeenChildWelcome: Bool = false

    init(launchRole: LaunchRole = .unpaired) {
        switch launchRole {
        case .unpaired:
            role = nil
            devices = []
        case .parent:
            bootstrapParent()
        case .child:
            _ = pairChild(code: SampleData.pairingCode)
            hasSeenChildWelcome = true
        }
    }

    var snapshot: WalletSnapshot {
        WalletSnapshot(
            role: role,
            isOnline: isOnline,
            balanceCents: balanceCents,
            goal: goal,
            transactions: transactions,
            board: board,
            bonusCents: bonusCents,
            adhoc: adhoc,
            changes: changes,
            wishes: wishes,
            pairingCode: pairingCode,
            sundayReminder: sundayReminder,
            previewNeedsPIN: previewNeedsPIN,
            settledThisWeek: settledThisWeek,
            devices: devices,
            pendingCelebrationCents: pendingCelebrationCents
        )
    }

    func bootstrapParent() {
        role = .parent
        devices = [
            PairedDevice(id: "iphone", name: "爸爸的 iPhone", roleLabel: "家长 · 可写入（本机）", glyph: .smartphone, isThisDevice: true),
        ]
        pairingCode = nil
        lastRecordRejectedReason = nil
    }

    func generatePairingCode() -> String {
        pairingCode = SampleData.pairingCode
        return SampleData.pairingCode
    }

    func pairChild(code: String) -> Bool {
        let trimmed = code.trimmingCharacters(in: .whitespacesAndNewlines)
        let accepted = trimmed == SampleData.pairingCode || (pairingCode != nil && trimmed == pairingCode)
        guard accepted else { return false }
        role = .child
        pairingCode = nil
        hasSeenChildWelcome = false
        devices = [
            PairedDevice(id: "ipad", name: "Forrest 的 iPad", roleLabel: "儿童 · 只读（本机）", glyph: .tablet, isThisDevice: true),
            PairedDevice(id: "iphone", name: "爸爸的 iPhone", roleLabel: "家长 · 可写入", glyph: .smartphone, isThisDevice: false),
        ]
        return true
    }

    func resetPairing() {
        role = nil
        pairingCode = nil
        hasSeenChildWelcome = false
        devices = []
        pendingCelebrationCents = nil
    }

    func setOnline(_ online: Bool) {
        isOnline = online
    }

    @discardableResult
    func recordEntry(direction: MoneyDirection, yuan: Int, reason: String, categoryID: String?) -> Bool {
        guard role == .parent else {
            lastRecordRejectedReason = "儿童端不能记账"
            return false
        }
        guard isOnline else {
            lastRecordRejectedReason = "没有写入任何记录 —— 记账必须联网"
            return false
        }
        guard yuan > 0 else {
            lastRecordRejectedReason = "金额不能是 0"
            return false
        }
        lastRecordRejectedReason = nil
        let cents = yuan * 100
        let delta: Int
        switch direction {
        case .spend, .debt: delta = -cents
        default: delta = cents
        }
        balanceCents += delta
        let nextID = (transactions.map(\.id).max() ?? 0) + 1
        let trimmed = reason.trimmingCharacters(in: .whitespacesAndNewlines)
        let entry = LedgerEntry(
            id: nextID,
            reason: trimmed.isEmpty ? "（没写事由）" : trimmed,
            cents: cents,
            direction: direction,
            date: Self.todayLabel,
            categoryID: direction == .spend ? (categoryID ?? "other") : nil,
            balanceAfter: balanceCents,
            reversed: false
        )
        transactions.insert(entry, at: 0)
        if direction == .income {
            pendingCelebrationCents = cents
        }
        return true
    }

    func toggleBoardCell(row: Int, day: Int) {
        guard role == .parent else { return }
        guard board.indices.contains(row), board[row].days.indices.contains(day) else { return }
        let current = board[row].days[day]
        guard current != .future else { return }
        board[row].days[day] = current == .done ? .unlogged : .done
    }

    func confirmSettlement() {
        guard role == .parent, !settledThisWeek else { return }
        let yuan = snapshot.settlementTotalCents / 100
        let ok = recordEntry(direction: .income, yuan: max(yuan, 0) == 0 ? 0 : yuan, reason: "本周基础零花钱", categoryID: nil)
        if ok || yuan == 0 {
            settledThisWeek = true
        }
        if yuan == 0 {
            lastRecordRejectedReason = nil
        }
    }

    func saveBoardItem(at index: Int?, name: String, goal: Int, rewardCents: Int) {
        guard role == .parent else { return }
        let trimmed = String(name.trimmingCharacters(in: .whitespacesAndNewlines).prefix(6))
        guard !trimmed.isEmpty, goal > 0, goal <= 7, rewardCents >= 0 else { return }
        if let index, board.indices.contains(index) {
            board[index].name = trimmed
            board[index].goal = goal
            board[index].rewardCents = rewardCents
            changes.insert(
                RuleChange(text: "改了「\(trimmed)」：每周 \(goal) 次，做到有 \(rewardCents / 100) 元", date: "\(Self.todayLabel) · 和爸爸一起决定的"),
                at: 0
            )
        } else {
            let days: [BoardCellState] = (0..<7).map { $0 <= 3 ? .unlogged : .future }
            board.append(BoardItem(name: trimmed, goal: goal, rewardCents: rewardCents, days: days))
            changes.insert(
                RuleChange(text: "加了新的一项：\(trimmed)，做到有 \(rewardCents / 100) 元", date: "\(Self.todayLabel) · 和爸爸一起决定的"),
                at: 0
            )
        }
    }

    func deleteBoardItem(at index: Int) {
        guard role == .parent, board.indices.contains(index) else { return }
        let name = board[index].name
        board.remove(at: index)
        changes.insert(
            RuleChange(text: "不再打卡「\(name)」", date: "\(Self.todayLabel) · 和爸爸一起决定的"),
            at: 0
        )
    }

    func setBonusCents(_ cents: Int) {
        guard role == .parent, cents >= 0 else { return }
        bonusCents = cents
    }

    func setSundayReminder(_ on: Bool) { sundayReminder = on }
    func setPreviewNeedsPIN(_ on: Bool) { previewNeedsPIN = on }

    func revokeDevice(id: String) {
        guard role == .parent else { return }
        devices.removeAll { $0.id == id && !$0.isThisDevice }
    }

    func dismissCelebration() {
        pendingCelebrationCents = nil
    }

    func acknowledgeChildWelcome() {
        hasSeenChildWelcome = true
    }

    private static var todayLabel: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "zh_CN")
        f.dateFormat = "M月d日"
        return f.string(from: Date())
    }
}

extension SampleWalletStore {
    static func fromLaunchArguments(_ arguments: [String] = ProcessInfo.processInfo.arguments) -> SampleWalletStore {
        var role = LaunchRole.unpaired
        if arguments.contains("-FWRoleParent") {
            role = .parent
        } else if arguments.contains("-FWRoleChild") {
            role = .child
        } else if arguments.contains("-FWUnpaired") {
            role = .unpaired
        }
        let store = SampleWalletStore(launchRole: role)
        if arguments.contains("-FWOffline") {
            store.isOnline = false
        }
        return store
    }
}
