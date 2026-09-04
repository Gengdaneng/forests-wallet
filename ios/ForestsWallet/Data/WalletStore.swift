import Foundation
import SwiftUI

enum LaunchRole: String {
    case unpaired, parent, child
}

enum DeviceLabel {
    static let parentFallback = "爸爸的 iPhone"
    static let childFallback = "Forrest 的 iPad"

    static func bounded(_ raw: String, fallback: String) -> String {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        let base = trimmed.isEmpty ? fallback : trimmed
        if base.utf16.count <= 64 { return base }
        var truncated = ""
        truncated.reserveCapacity(64)
        for character in base {
            let next = truncated + String(character)
            if next.utf16.count > 64 { break }
            truncated = next
        }
        return truncated.isEmpty ? fallback : truncated
    }
}

@Observable
@MainActor
final class SampleWalletStore: WalletServing {
    private(set) var role: DeviceRole?
    var isOnline: Bool = true
    var balanceCents: Int = 8700
    var goal: Goal? = SampleData.goal
    var weekLabel: String? = SampleData.weekLabel
    var categories: [SpendCategory] = SpendCategory.all
    var transactions: [LedgerEntry] = SampleData.transactions
    var board: [BoardItem] = SampleData.board
    var bonusCents: Int = 300
    var adhoc: [RuleItem] = SampleData.adhoc
    var changes: [RuleChange] = SampleData.changes
    var wishes: [Wish] = SampleData.wishes
    var pairingCode: String?
    var pairingExpiresInSeconds: Int?
    var sundayReminder: Bool = true
    var previewNeedsPIN: Bool = true
    var settledThisWeek: Bool = false
    var devices: [PairedDevice] = []
    var pendingCelebrationCents: Int?
    var lastRecordRejectedReason: String?
    var lastAuthErrorMessage: String?
    var lastAuthErrorIsOffline: Bool = false
    var isAuthBusy: Bool = false
    var hasSeenChildWelcome: Bool = false

    private let authClient: AuthClient?
    private let credentials: any CredentialStoring
    private let deviceLabel: String
    private let childDeviceLabel: String

    var isRemoteAuth: Bool { authClient != nil }

    var pairingHint: String {
        if let seconds = pairingExpiresInSeconds {
            let minutes = max(1, Int((Double(seconds) / 60.0).rounded()))
            return "6 位数字 · \(minutes) 分钟过期 · 用一次即作废"
        }
        return "6 位数字 · 10 分钟过期 · 用一次即作废"
    }

    init(
        launchRole: LaunchRole = .unpaired,
        authClient: AuthClient? = nil,
        credentials: (any CredentialStoring)? = nil,
        deviceLabel: String? = nil,
        childDeviceLabel: String? = nil
    ) {
        self.authClient = authClient
        self.credentials = credentials ?? InMemoryCredentialStore()
        self.deviceLabel = DeviceLabel.bounded(deviceLabel ?? UIDevice.current.name, fallback: DeviceLabel.parentFallback)
        self.childDeviceLabel = DeviceLabel.bounded(childDeviceLabel ?? DeviceLabel.childFallback, fallback: DeviceLabel.childFallback)

        if authClient != nil {
            applyEmptyRemoteLedger()
            if let stored = try? self.credentials.load() {
                applyRestoredCredentials(stored)
            } else {
                role = nil
                devices = []
            }
            return
        }

        switch launchRole {
        case .unpaired:
            role = nil
            devices = []
        case .parent:
            applyLocalParent()
        case .child:
            applyLocalChild(code: SampleData.pairingCode)
            hasSeenChildWelcome = true
        }
    }

    var snapshot: WalletSnapshot {
        WalletSnapshot(
            role: role,
            isOnline: isOnline,
            balanceCents: balanceCents,
            goal: goal,
            weekLabel: weekLabel,
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

    func bootstrapParent() async {
        guard beginAuthWork() else { return }
        defer { isAuthBusy = false }
        guard let authClient else {
            applyLocalParent()
            return
        }
        do {
            let session = try await authClient.bootstrap(deviceLabel: deviceLabel)
            try persist(session)
            applyRemoteSession(session, thisDeviceName: deviceLabel)
            await refreshDevicesLocked()
        } catch {
            presentAuthError(error)
        }
    }

    func generatePairingCode() async -> String? {
        guard beginAuthWork() else { return nil }
        defer { isAuthBusy = false }
        guard let authClient else {
            pairingCode = SampleData.pairingCode
            pairingExpiresInSeconds = 600
            return SampleData.pairingCode
        }
        guard let token = storedToken() else {
            present(.unauthorized)
            return nil
        }
        do {
            let issued = try await authClient.createPairing(token: token, deviceLabel: childDeviceLabel)
            pairingCode = issued.code
            pairingExpiresInSeconds = issued.expiresInSeconds
            return issued.code
        } catch {
            presentAuthError(error)
            return nil
        }
    }

    func pairChild(code: String) async -> Bool {
        guard beginAuthWork() else { return false }
        defer { isAuthBusy = false }
        let trimmed = code.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let authClient else {
            return applyLocalChild(code: trimmed)
        }
        do {
            let session = try await authClient.claimPairing(code: trimmed)
            try persist(session)
            applyRemoteSession(session, thisDeviceName: childDeviceLabel)
            return true
        } catch {
            presentAuthError(error)
            return false
        }
    }

    func resetPairing() {
        try? credentials.clear()
        role = nil
        pairingCode = nil
        pairingExpiresInSeconds = nil
        hasSeenChildWelcome = false
        devices = []
        pendingCelebrationCents = nil
        lastAuthErrorMessage = nil
        lastAuthErrorIsOffline = false
        lastRecordRejectedReason = nil
        if authClient != nil {
            applyEmptyRemoteLedger()
        }
    }

    func refreshDevices() async {
        await refreshDevicesLocked()
    }

    func refreshLedger() async {
        guard let authClient, role != nil else { return }
        guard let token = storedToken() else { return }
        do {
            let remote = try await authClient.snapshot(token: token)
            applyRemoteSnapshot(remote)
            isOnline = true
            lastAuthErrorMessage = nil
            lastAuthErrorIsOffline = false
        } catch {
            presentAuthError(error)
            if let mapped = error as? AuthAPIError, mapped != .unauthorized {
                isOnline = false
            }
        }
    }

    func setOnline(_ online: Bool) {
        isOnline = online
    }

    @discardableResult
    func recordEntry(direction: MoneyDirection, yuan: Int, reason: String, categoryID: String?) async -> Bool {
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
        if authClient != nil {
            return await recordRemoteEntry(direction: direction, yuan: yuan, reason: reason, categoryID: categoryID)
        }
        return applyLocalEntry(direction: direction, yuan: yuan, reason: reason, categoryID: categoryID)
    }

    func toggleBoardCell(row: Int, day: Int) {
        guard authClient == nil else { return }
        guard role == .parent else { return }
        guard board.indices.contains(row), board[row].days.indices.contains(day) else { return }
        let current = board[row].days[day]
        guard current != .future else { return }
        board[row].days[day] = current == .done ? .unlogged : .done
    }

    func confirmSettlement() {
        guard authClient == nil else { return }
        guard role == .parent, !settledThisWeek else { return }
        let yuan = snapshot.settlementTotalCents / 100
        let ok = applyLocalEntry(direction: .income, yuan: max(yuan, 0) == 0 ? 0 : yuan, reason: "本周基础零花钱", categoryID: nil)
        if ok || yuan == 0 {
            settledThisWeek = true
        }
        if yuan == 0 {
            lastRecordRejectedReason = nil
        }
    }

    func saveBoardItem(at index: Int?, name: String, goal: Int, rewardCents: Int) {
        guard authClient == nil else { return }
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
        guard authClient == nil else { return }
        guard role == .parent, board.indices.contains(index) else { return }
        let name = board[index].name
        board.remove(at: index)
        changes.insert(
            RuleChange(text: "不再打卡「\(name)」", date: "\(Self.todayLabel) · 和爸爸一起决定的"),
            at: 0
        )
    }

    func setBonusCents(_ cents: Int) {
        guard authClient == nil else { return }
        guard role == .parent, cents >= 0 else { return }
        bonusCents = cents
    }

    func setSundayReminder(_ on: Bool) { sundayReminder = on }
    func setPreviewNeedsPIN(_ on: Bool) { previewNeedsPIN = on }

    func revokeDevice(id: String) async {
        guard beginAuthWork() else { return }
        defer { isAuthBusy = false }
        guard role == .parent else { return }
        guard let authClient else {
            devices.removeAll { $0.id == id && !$0.isThisDevice }
            return
        }
        guard let token = storedToken() else {
            present(.unauthorized)
            return
        }
        do {
            try await authClient.revokeDevice(token: token, id: id)
            devices.removeAll { $0.id == id && !$0.isThisDevice }
            await refreshDevicesLocked()
        } catch {
            presentAuthError(error)
        }
    }

    func dismissCelebration() {
        pendingCelebrationCents = nil
    }

    func acknowledgeChildWelcome() {
        hasSeenChildWelcome = true
    }

    @discardableResult
    private func applyLocalEntry(direction: MoneyDirection, yuan: Int, reason: String, categoryID: String?) -> Bool {
        guard yuan > 0 else { return false }
        let cents = yuan * 100
        let delta: Int
        switch direction {
        case .spend, .debt: delta = -cents
        default: delta = cents
        }
        balanceCents += delta
        let nextID = String((transactions.compactMap { Int($0.id) }.max() ?? 0) + 1)
        let trimmed = reason.trimmingCharacters(in: .whitespacesAndNewlines)
        let entry = LedgerEntry(
            id: nextID,
            reason: trimmed.isEmpty ? "（没写事由）" : trimmed,
            cents: cents,
            direction: direction,
            date: Self.todayLabel,
            categoryID: direction == .spend ? (categoryID ?? "other") : nil,
            balanceAfter: balanceCents,
            reversed: false,
            isCorrectable: direction != .correction
        )
        transactions.insert(entry, at: 0)
        if direction == .income {
            pendingCelebrationCents = cents
        }
        return true
    }

    private func recordRemoteEntry(
        direction: MoneyDirection,
        yuan: Int,
        reason: String,
        categoryID: String?
    ) async -> Bool {
        guard beginWriteWork() else { return false }
        defer { isAuthBusy = false }
        guard let authClient, let token = storedToken() else {
            present(.unauthorized)
            lastRecordRejectedReason = AuthAPIError.unauthorized.userMessage
            return false
        }
        let key = UUID().uuidString
        let trimmed = reason.trimmingCharacters(in: .whitespacesAndNewlines)
        let memo = trimmed.isEmpty ? nil : trimmed
        do {
            if direction == .correction {
                guard let target = transactions.first(where: \.isCorrectable) else {
                    lastRecordRejectedReason = AuthAPIError.invalidRequest.userMessage
                    return false
                }
                let request = CorrectionRequest(
                    amountFen: LedgerMapping.signedFenForCorrection(target: target, yuan: yuan),
                    occurredOn: target.occurredOnISO ?? LedgerDate.todayISO(),
                    memo: memo,
                    category: LedgerMapping.apiCategory(fromUI: categoryID ?? target.categoryID)
                )
                let response = try await authClient.correctTransaction(
                    token: token,
                    id: target.id,
                    idempotencyKey: key,
                    request: request
                )
                applyCorrection(response)
            } else {
                guard let kind = LedgerMapping.writeKind(for: direction) else {
                    lastRecordRejectedReason = AuthAPIError.invalidRequest.userMessage
                    return false
                }
                let request = CreateTransactionRequest(
                    kind: kind,
                    amountFen: LedgerMapping.signedFen(direction: direction, yuan: yuan),
                    occurredOn: LedgerDate.todayISO(),
                    memo: memo,
                    category: direction == .spend ? (LedgerMapping.apiCategory(fromUI: categoryID) ?? "other") : nil
                )
                let response = try await authClient.createTransaction(
                    token: token,
                    idempotencyKey: key,
                    request: request
                )
                applyCreated(response)
                if direction == .income {
                    pendingCelebrationCents = yuan * 100
                }
            }
            isOnline = true
            await refreshLedger()
            return true
        } catch {
            presentWriteError(error)
            return false
        }
    }

    private func applyCreated(_ response: CreateTransactionResponse) {
        balanceCents = response.balanceFen
        var rows = LedgerMapping.entries(from: [response.transaction])
        if !rows.isEmpty {
            rows[0].balanceAfter = response.balanceFen
            transactions.insert(rows[0], at: 0)
        }
    }

    private func applyCorrection(_ response: CorrectionResponse) {
        balanceCents = response.balanceFen
        if let index = transactions.firstIndex(where: { $0.id == response.original.id }) {
            transactions[index].reversed = true
            transactions[index].isCorrectable = false
        }
        let extras = LedgerMapping.entries(from: [response.replacement, response.reverse])
        transactions.insert(contentsOf: extras, at: 0)
    }

    private func applyEmptyRemoteLedger() {
        balanceCents = 0
        goal = nil
        weekLabel = nil
        categories = SpendCategory.all
        transactions = []
        board = []
        bonusCents = 0
        adhoc = []
        changes = []
        wishes = []
        settledThisWeek = false
        pendingCelebrationCents = nil
    }

    private func applyRemoteSnapshot(_ remote: RemoteSnapshot) {
        balanceCents = remote.balanceFen
        goal = LedgerMapping.goal(from: remote.goal)
        weekLabel = LedgerMapping.weekLabel(from: remote.week)
        categories = LedgerMapping.categories(from: remote.categories)
        transactions = LedgerMapping.entries(from: remote.recentTransactions)
        board = LedgerMapping.board(
            items: remote.checkinItems,
            checkins: remote.checkins,
            week: remote.week,
            todayISO: LedgerDate.todayISO()
        )
        changes = LedgerMapping.changes(from: remote.ruleChanges)
        adhoc = []
        wishes = []
    }

    private func beginWriteWork() -> Bool {
        guard !isAuthBusy else { return false }
        isAuthBusy = true
        lastRecordRejectedReason = nil
        lastAuthErrorMessage = nil
        lastAuthErrorIsOffline = false
        return true
    }

    private func presentWriteError(_ error: Error) {
        let mapped = (error as? AuthAPIError) ?? .serverFailure
        lastAuthErrorIsOffline = mapped.isOffline
        switch mapped {
        case .unauthorized:
            present(mapped)
            lastRecordRejectedReason = mapped.userMessage
        case .offline:
            isOnline = false
            lastAuthErrorMessage = mapped.userMessage
            lastRecordRejectedReason = "没有写入任何记录 —— 记账必须联网"
        case .forbidden:
            lastAuthErrorMessage = mapped.userMessage
            lastRecordRejectedReason = "儿童端不能记账"
        default:
            lastAuthErrorMessage = mapped.userMessage
            lastRecordRejectedReason = mapped.userMessage
        }
    }

    private func applyLocalParent() {
        role = .parent
        devices = [
            PairedDevice(id: "iphone", name: DeviceLabel.parentFallback, roleLabel: "家长 · 可写入（本机）", glyph: .smartphone, isThisDevice: true),
        ]
        pairingCode = nil
        pairingExpiresInSeconds = nil
        lastRecordRejectedReason = nil
        lastAuthErrorMessage = nil
        lastAuthErrorIsOffline = false
    }

    @discardableResult
    private func applyLocalChild(code: String) -> Bool {
        let accepted = code == SampleData.pairingCode || (pairingCode != nil && code == pairingCode)
        guard accepted else {
            lastAuthErrorMessage = AuthAPIError.invalidOrExpiredCode.userMessage
            lastAuthErrorIsOffline = false
            return false
        }
        role = .child
        pairingCode = nil
        pairingExpiresInSeconds = nil
        hasSeenChildWelcome = false
        lastAuthErrorMessage = nil
        lastAuthErrorIsOffline = false
        devices = [
            PairedDevice(id: "ipad", name: DeviceLabel.childFallback, roleLabel: "儿童 · 只读（本机）", glyph: .tablet, isThisDevice: true),
            PairedDevice(id: "iphone", name: DeviceLabel.parentFallback, roleLabel: "家长 · 可写入", glyph: .smartphone, isThisDevice: false),
        ]
        return true
    }

    private func applyRestoredCredentials(_ stored: DeviceCredentials) {
        role = stored.role
        pairingCode = nil
        pairingExpiresInSeconds = nil
        lastAuthErrorMessage = nil
        lastAuthErrorIsOffline = false
        if stored.role == .parent {
            hasSeenChildWelcome = false
            devices = [
                PairedDevice(
                    id: stored.deviceID,
                    name: deviceLabel,
                    roleLabel: "家长 · 可写入（本机）",
                    glyph: .smartphone,
                    isThisDevice: true
                ),
            ]
        } else {
            hasSeenChildWelcome = true
            devices = [
                PairedDevice(
                    id: stored.deviceID,
                    name: childDeviceLabel,
                    roleLabel: "儿童 · 只读（本机）",
                    glyph: .tablet,
                    isThisDevice: true
                ),
            ]
        }
    }

    private func applyRemoteSession(_ session: AuthSessionResponse, thisDeviceName: String) {
        role = session.role
        pairingCode = nil
        pairingExpiresInSeconds = nil
        lastAuthErrorMessage = nil
        lastAuthErrorIsOffline = false
        lastRecordRejectedReason = nil
        if session.role == .parent {
            hasSeenChildWelcome = false
            devices = [
                PairedDevice(
                    id: session.deviceID,
                    name: thisDeviceName,
                    roleLabel: "家长 · 可写入（本机）",
                    glyph: .smartphone,
                    isThisDevice: true
                ),
            ]
        } else {
            hasSeenChildWelcome = false
            devices = [
                PairedDevice(
                    id: session.deviceID,
                    name: thisDeviceName,
                    roleLabel: "儿童 · 只读（本机）",
                    glyph: .tablet,
                    isThisDevice: true
                ),
            ]
        }
    }

    private func persist(_ session: AuthSessionResponse) throws {
        try credentials.save(
            DeviceCredentials(token: session.token, deviceID: session.deviceID, role: session.role)
        )
    }

    private func storedToken() -> String? {
        (try? credentials.load())?.token
    }

    private func storedDeviceID() -> String? {
        (try? credentials.load())?.deviceID
    }

    private func beginAuthWork() -> Bool {
        guard !isAuthBusy else { return false }
        isAuthBusy = true
        lastAuthErrorMessage = nil
        lastAuthErrorIsOffline = false
        return true
    }

    private func presentAuthError(_ error: Error) {
        let mapped = (error as? AuthAPIError) ?? .serverFailure
        present(mapped)
    }

    private func present(_ error: AuthAPIError) {
        lastAuthErrorMessage = error.userMessage
        lastAuthErrorIsOffline = error.isOffline
        if error == .unauthorized {
            try? credentials.clear()
            role = nil
            pairingCode = nil
            pairingExpiresInSeconds = nil
            hasSeenChildWelcome = false
            devices = []
        }
    }

    private func refreshDevicesLocked() async {
        guard let authClient, role == .parent else { return }
        guard let token = storedToken() else { return }
        do {
            let remote = try await authClient.listDevices(token: token)
            let thisID = storedDeviceID()
            devices = remote.compactMap { Self.mapDevice($0, thisDeviceID: thisID) }
        } catch {
            presentAuthError(error)
        }
    }

    private static func mapDevice(_ remote: RemoteDevice, thisDeviceID: String?) -> PairedDevice? {
        guard remote.isActive else { return nil }
        let isThis = remote.id == thisDeviceID
        let isParent = remote.role == .parent
        let roleLabel: String
        if isParent {
            roleLabel = isThis ? "家长 · 可写入（本机）" : "家长 · 可写入"
        } else {
            roleLabel = isThis ? "儿童 · 只读（本机）" : "儿童 · 只读"
        }
        let fallback = isParent ? DeviceLabel.parentFallback : DeviceLabel.childFallback
        let name = remote.label.trimmingCharacters(in: .whitespacesAndNewlines)
        return PairedDevice(
            id: remote.id,
            name: name.isEmpty ? fallback : name,
            roleLabel: roleLabel,
            glyph: isParent ? .smartphone : .tablet,
            isThisDevice: isThis
        )
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

    static func live(
        client: AuthClient = .production(),
        credentials: any CredentialStoring = KeychainCredentialStore()
    ) -> SampleWalletStore {
        SampleWalletStore(launchRole: .unpaired, authClient: client, credentials: credentials)
    }

    static func makeLaunchStore(_ arguments: [String] = ProcessInfo.processInfo.arguments) -> SampleWalletStore {
        if arguments.contains(where: { $0.hasPrefix("-FW") }) {
            return fromLaunchArguments(arguments)
        }
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
            || ProcessInfo.processInfo.environment["XCTestBundlePath"] != nil {
            return SampleWalletStore(launchRole: .unpaired)
        }
        return live()
    }
}
