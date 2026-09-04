import XCTest
@testable import ForestsWallet

private func requestPath(_ request: URLRequest) -> String {
    request.url?.path ?? ""
}

final class BoardSettleGoalClientTests: XCTestCase {
    private func makeClient(_ stub: HTTPStub) throws -> AuthClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubURLProtocol.self]
        configuration.timeoutIntervalForRequest = 2
        configuration.waitsForConnectivity = false
        configuration.urlCache = nil
        let session = URLSession(configuration: configuration)
        return try AuthClient(baseURL: URL(string: "https://\(stub.host)")!, session: session)
    }

    func testBoardMappingThreeStateAndItemIDs() {
        let items = [
            RemoteCheckinItem(id: "item-jump", name: "跳绳", weeklyTarget: 5, amountFen: 500, sort: 1),
        ]
        let checkins = [
            RemoteCheckin(itemId: "item-jump", localDate: "2026-08-31"),
            RemoteCheckin(itemId: "item-jump", localDate: "2026-09-01"),
        ]
        let week = RemoteWeek(start: "2026-08-31", end: "2026-09-06")
        let board = LedgerMapping.board(items: items, checkins: checkins, week: week, todayISO: "2026-09-02")
        XCTAssertEqual(board.count, 1)
        XCTAssertEqual(board[0].id, "item-jump")
        XCTAssertEqual(board[0].days, [.done, .done, .unlogged, .future, .future, .future, .future])
    }

    func testAllowanceWeeklyEmptyMemoIsWeeklyPocketMoney() {
        let row = RemoteTransaction(
            id: "s1",
            amountFen: 1000,
            occurredOn: "2026-08-31",
            recordedAt: nil,
            memo: "",
            category: RemoteCategoryRef(slug: "other", label: "其他"),
            kind: "allowance_weekly",
            reversesId: nil,
            replacesId: nil,
            balanceAfterFen: 1000,
            settlementWeekStart: "2026-08-31",
            ruleSnapshot: "跳绳 5/5 → +5\n合计 +5"
        )
        let entries = LedgerMapping.entries(from: [row])
        XCTAssertEqual(entries[0].reason, "本周基础零花钱")
        XCTAssertEqual(entries[0].direction, .income)
        XCTAssertTrue(LedgerMapping.settledThisWeek(transactions: [row], weekStart: "2026-08-31"))
        XCTAssertFalse(LedgerMapping.settledThisWeek(transactions: [row], weekStart: "2026-09-07"))
    }

    func testTickPostsIdempotencyKeyAndDoesNotSendFuture() async throws {
        let stub = HTTPStub()
        stub.on { _ in
            (200, Data(#"{"item_id":"item-jump","local_date":"2026-09-01","ticked":true}"#.utf8))
        }
        let client = try makeClient(stub)
        let key = UUID().uuidString
        let response = try await client.setCheckinTick(
            token: "parent-token",
            id: "item-jump",
            idempotencyKey: key,
            request: TickRequest(localDate: "2026-09-01", ticked: true)
        )
        XCTAssertEqual(response.ticked, true)
        let recorded = try XCTUnwrap(stub.requests.first)
        XCTAssertEqual(recorded.request.httpMethod, "POST")
        XCTAssertEqual(recorded.request.url?.path, "/v1/checkin-items/item-jump/ticks")
        XCTAssertEqual(recorded.request.value(forHTTPHeaderField: "Authorization"), "Bearer parent-token")
        XCTAssertEqual(recorded.request.value(forHTTPHeaderField: "Idempotency-Key"), key)
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: try XCTUnwrap(recorded.body)) as? [String: Any])
        XCTAssertEqual(json["local_date"] as? String, "2026-09-01")
        XCTAssertEqual(json["ticked"] as? Bool, true)
    }

    func testCheckinItemMutationsEncodeFields() async throws {
        let stub = HTTPStub()
        stub.on { request in
            if requestPath(request).hasSuffix("/archive") {
                return (200, Data(#"{"ok":true}"#.utf8))
            }
            if requestPath(request) == "/v1/checkin-items" {
                return (201, Data(#"{"item":{"id":"item-new","name":"练琴","weekly_target":4,"amount_fen":300,"sort":2}}"#.utf8))
            }
            return (200, Data(#"{"item":{"id":"item-jump","name":"跳绳","weekly_target":5,"amount_fen":300,"sort":1}}"#.utf8))
        }
        let client = try makeClient(stub)
        let created = try await client.createCheckinItem(
            token: "parent-token",
            idempotencyKey: UUID().uuidString,
            request: CreateCheckinItemRequest(name: "练琴", weeklyTarget: 4, amountFen: 300)
        )
        XCTAssertEqual(created.item.id, "item-new")
        let createJSON = try XCTUnwrap(JSONSerialization.jsonObject(with: try XCTUnwrap(stub.requests[0].body)) as? [String: Any])
        XCTAssertEqual(createJSON["name"] as? String, "练琴")
        XCTAssertEqual(createJSON["weekly_target"] as? Int, 4)
        XCTAssertEqual(createJSON["amount_fen"] as? Int, 300)

        _ = try await client.updateCheckinItem(
            token: "parent-token",
            id: "item-jump",
            idempotencyKey: UUID().uuidString,
            request: UpdateCheckinItemRequest(name: "跳绳", weeklyTarget: 5, amountFen: 300)
        )
        XCTAssertEqual(stub.requests[1].request.url?.path, "/v1/checkin-items/item-jump")

        try await client.archiveCheckinItem(
            token: "parent-token",
            id: "item-jump",
            idempotencyKey: UUID().uuidString
        )
        XCTAssertEqual(stub.requests[2].request.url?.path, "/v1/checkin-items/item-jump/archive")
        XCTAssertNotNil(stub.requests[2].request.value(forHTTPHeaderField: "Idempotency-Key"))
    }

    func testSettlement201And409() async throws {
        let created = HTTPStub()
        created.on { _ in
            (201, Data(#"{"transaction":{"id":"tx-w","amount_fen":1000,"occurred_on":"2026-08-31","memo":"","kind":"allowance_weekly","reverses_id":null,"replaces_id":null,"settlement_week_start":"2026-08-31","rule_snapshot":"合计 +10"},"balance_fen":9700}"#.utf8))
        }
        let client = try makeClient(created)
        let key = UUID().uuidString
        let response = try await client.createSettlement(
            token: "parent-token",
            idempotencyKey: key,
            request: SettlementRequest(weekStart: "2026-08-31")
        )
        XCTAssertEqual(response.transaction.kind, "allowance_weekly")
        XCTAssertEqual(response.transaction.amountFen, 1000)
        XCTAssertEqual(created.requests.first?.request.url?.path, "/v1/settlements")
        XCTAssertEqual(created.requests.first?.request.value(forHTTPHeaderField: "Idempotency-Key"), key)
        let body = try XCTUnwrap(JSONSerialization.jsonObject(with: try XCTUnwrap(created.requests.first?.body)) as? [String: Any])
        XCTAssertEqual(body["week_start"] as? String, "2026-08-31")

        let conflicted = HTTPStub()
        conflicted.on { _ in
            (409, Data(#"{"error":"conflict"}"#.utf8))
        }
        let conflictClient = try makeClient(conflicted)
        await assertThrows({
            try await conflictClient.createSettlement(
                token: "parent-token",
                idempotencyKey: UUID().uuidString,
                request: SettlementRequest(weekStart: "2026-08-31")
            )
        }) { error in
            XCTAssertEqual(error as? AuthAPIError, .conflict)
        }
    }

    func testGoalReplaceAndArchive() async throws {
        let stub = HTTPStub()
        stub.on { request in
            if requestPath(request).hasSuffix("/archive") {
                return (200, Data(#"{"goal":{"id":"g1","name":"乐高赛车","target_amount_fen":40000,"status":"archived"}}"#.utf8))
            }
            return (201, Data(#"{"goal":{"id":"g2","name":"恐龙拼图","target_amount_fen":6800,"status":"active"},"archived":{"id":"g1","name":"乐高赛车","target_amount_fen":40000,"status":"archived"}}"#.utf8))
        }
        let client = try makeClient(stub)
        let created = try await client.createGoal(
            token: "parent-token",
            idempotencyKey: UUID().uuidString,
            request: CreateGoalRequest(name: "恐龙拼图", targetAmountFen: 6800)
        )
        XCTAssertEqual(created.goal.name, "恐龙拼图")
        XCTAssertEqual(created.archived?.status, "archived")
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: try XCTUnwrap(stub.requests[0].body)) as? [String: Any])
        XCTAssertEqual(json["name"] as? String, "恐龙拼图")
        XCTAssertEqual(json["target_amount_fen"] as? Int, 6800)
        XCTAssertEqual(stub.requests[0].request.url?.path, "/v1/goals")

        let archived = try await client.archiveGoal(
            token: "parent-token",
            id: "g1",
            idempotencyKey: UUID().uuidString
        )
        XCTAssertEqual(archived.goal.status, "archived")
        XCTAssertEqual(stub.requests[1].request.url?.path, "/v1/goals/g1/archive")
        XCTAssertNotNil(stub.requests[1].request.value(forHTTPHeaderField: "Idempotency-Key"))
    }

    func testChildCannotWriteBoardSettleOrGoals() async throws {
        let stub = HTTPStub()
        stub.on { _ in
            (403, Data(#"{"error":"forbidden"}"#.utf8))
        }
        let client = try makeClient(stub)
        await assertThrows({
            try await client.setCheckinTick(
                token: "child-token",
                id: "item-jump",
                idempotencyKey: UUID().uuidString,
                request: TickRequest(localDate: "2026-09-01", ticked: true)
            )
        }) { error in
            XCTAssertEqual(error as? AuthAPIError, .forbidden)
        }
        await assertThrows({
            try await client.createSettlement(
                token: "child-token",
                idempotencyKey: UUID().uuidString,
                request: SettlementRequest(weekStart: "2026-08-31")
            )
        }) { error in
            XCTAssertEqual(error as? AuthAPIError, .forbidden)
        }
        await assertThrows({
            try await client.createGoal(
                token: "child-token",
                idempotencyKey: UUID().uuidString,
                request: CreateGoalRequest(name: "小车", targetAmountFen: 40000)
            )
        }) { error in
            XCTAssertEqual(error as? AuthAPIError, .forbidden)
        }
        XCTAssertEqual(stub.requests.count, 3)
        for recorded in stub.requests {
            XCTAssertNotNil(recorded.request.value(forHTTPHeaderField: "Idempotency-Key"))
        }
    }
}

private final class Box<T>: @unchecked Sendable {
    var value: T
    init(_ value: T) { self.value = value }
}

@MainActor
private func makeBoardLiveStore(
    stub: HTTPStub,
    credentials: InMemoryCredentialStore
) throws -> SampleWalletStore {
    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [StubURLProtocol.self]
    configuration.timeoutIntervalForRequest = 2
    configuration.waitsForConnectivity = false
    let session = URLSession(configuration: configuration)
    let client = try AuthClient(baseURL: URL(string: "https://\(stub.host)")!, session: session)
    return SampleWalletStore(
        launchRole: .unpaired,
        authClient: client,
        credentials: credentials,
        deviceLabel: "爸爸的 iPhone",
        childDeviceLabel: "Forrest 的 iPad"
    )
}

private func boardSnapshotJSON(
    weekStart: String,
    checkins: String = "[]",
    items: String? = nil,
    transactions: String = "[]",
    goal: String = "null",
    ruleChanges: String = "[]",
    balance: Int = 0
) -> Data {
    let end = LedgerDate.addDays(weekStart, days: 6) ?? weekStart
    let itemJSON = items ?? #"[{"id":"item-jump","name":"跳绳","weekly_target":5,"amount_fen":500,"sort":1}]"#
    return Data("""
    {"balance_fen":\(balance),"week":{"start":"\(weekStart)","end":"\(end)"},"checkin_items":\(itemJSON),"checkins":\(checkins),"rule_changes":\(ruleChanges),"recent_transactions":\(transactions),"goal":\(goal),"categories":[]}
    """.utf8)
}

@MainActor
final class LiveBoardSettleGoalStoreTests: XCTestCase {
    private func makeLiveStore(
        stub: HTTPStub,
        credentials: InMemoryCredentialStore
    ) throws -> SampleWalletStore {
        try makeBoardLiveStore(stub: stub, credentials: credentials)
    }

    private func weekStart() -> String { LedgerDate.weekStartISO() }

    func testParentToggleHitsTickThenRefreshes() async throws {
        let credentials = InMemoryCredentialStore(
            credentials: DeviceCredentials(token: "tok", deviceID: "dev-1", role: .parent)
        )
        let monday = weekStart()
        let ticked = Box(false)
        let stub = HTTPStub()
        stub.on { request in
            if requestPath(request).hasSuffix("/ticks") {
                ticked.value = true
                return (200, Data(#"{"item_id":"item-jump","local_date":"\#(monday)","ticked":true}"#.utf8))
            }
            if request.url?.path == "/v1/snapshot" {
                let checkins = ticked.value
                    ? #"[{"item_id":"item-jump","local_date":"\#(monday)"}]"#
                    : "[]"
                return (200, boardSnapshotJSON(weekStart: monday, checkins: checkins))
            }
            return (404, Data(#"{"error":"not_found"}"#.utf8))
        }
        let store = try makeLiveStore(stub: stub, credentials: credentials)
        await store.refreshLedger()
        XCTAssertEqual(store.board.count, 1)
        XCTAssertEqual(store.board[0].days[0], .unlogged)

        await store.toggleBoardCell(row: 0, day: 0)
        XCTAssertEqual(store.board[0].days[0], .done)

        let ticks = stub.requests.filter { requestPath($0.request).hasSuffix("/ticks") }
        XCTAssertEqual(ticks.count, 1)
        let key = try XCTUnwrap(ticks[0].request.value(forHTTPHeaderField: "Idempotency-Key"))
        XCTAssertNotNil(UUID(uuidString: key))
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: try XCTUnwrap(ticks[0].body)) as? [String: Any])
        XCTAssertEqual(json["local_date"] as? String, monday)
        XCTAssertEqual(json["ticked"] as? Bool, true)
        XCTAssertLessThanOrEqual(monday, LedgerDate.todayISO())
    }

    func testParentToggleDoesNotSendFutureDates() async throws {
        let credentials = InMemoryCredentialStore(
            credentials: DeviceCredentials(token: "tok", deviceID: "dev-1", role: .parent)
        )
        let monday = weekStart()
        let stub = HTTPStub()
        stub.on { request in
            if request.url?.path == "/v1/snapshot" {
                return (200, boardSnapshotJSON(weekStart: monday))
            }
            XCTFail("future cells must not hit the tick API")
            return (500, Data(#"{}"#.utf8))
        }
        let store = try makeLiveStore(stub: stub, credentials: credentials)
        await store.refreshLedger()
        let before = stub.requests.count
        if let future = store.board.first?.days.firstIndex(of: .future) {
            await store.toggleBoardCell(row: 0, day: future)
            XCTAssertEqual(store.board[0].days[future], .future)
            XCTAssertEqual(stub.requests.count, before)
        }
    }

    func testParentItemCreateUpdateArchiveRefresh() async throws {
        let credentials = InMemoryCredentialStore(
            credentials: DeviceCredentials(token: "tok", deviceID: "dev-1", role: .parent)
        )
        let monday = weekStart()
        let items = Box(#"[{"id":"item-jump","name":"跳绳","weekly_target":5,"amount_fen":500,"sort":1}]"#)
        let changes = Box("[]")
        let stub = HTTPStub()
        stub.on { request in
            let path = request.url?.path ?? ""
            if path == "/v1/checkin-items" {
                items.value = #"[{"id":"item-jump","name":"跳绳","weekly_target":5,"amount_fen":500,"sort":1},{"id":"item-piano","name":"练琴","weekly_target":4,"amount_fen":300,"sort":2}]"#
                changes.value = #"[{"id":"rc1","occurred_on":"\#(monday)","summary":"加了新的一项：练琴"}]"#
                return (201, Data(#"{"item":{"id":"item-piano","name":"练琴","weekly_target":4,"amount_fen":300,"sort":2}}"#.utf8))
            }
            if path == "/v1/checkin-items/item-jump" {
                items.value = #"[{"id":"item-jump","name":"跳绳","weekly_target":5,"amount_fen":300,"sort":1},{"id":"item-piano","name":"练琴","weekly_target":4,"amount_fen":300,"sort":2}]"#
                return (200, Data(#"{"item":{"id":"item-jump","name":"跳绳","weekly_target":5,"amount_fen":300,"sort":1}}"#.utf8))
            }
            if path.hasSuffix("/archive") {
                items.value = #"[{"id":"item-piano","name":"练琴","weekly_target":4,"amount_fen":300,"sort":2}]"#
                return (200, Data(#"{"ok":true}"#.utf8))
            }
            if path == "/v1/snapshot" {
                return (200, boardSnapshotJSON(weekStart: monday, items: items.value, ruleChanges: changes.value))
            }
            return (404, Data(#"{"error":"not_found"}"#.utf8))
        }
        let store = try makeLiveStore(stub: stub, credentials: credentials)
        await store.refreshLedger()
        await store.saveBoardItem(at: nil, name: "练琴", goal: 4, rewardCents: 300)
        XCTAssertEqual(store.board.map(\.name), ["跳绳", "练琴"])
        XCTAssertEqual(store.changes.first?.text, "加了新的一项：练琴")

        await store.saveBoardItem(at: 0, name: "跳绳", goal: 5, rewardCents: 300)
        XCTAssertEqual(store.board[0].rewardCents, 300)

        await store.deleteBoardItem(at: 0)
        XCTAssertEqual(store.board.map(\.name), ["练琴"])

        let writes = stub.requests.filter { ($0.request.url?.path ?? "").contains("checkin-items") && $0.request.httpMethod == "POST" }
        XCTAssertEqual(writes.count, 3)
        let keys = writes.compactMap { $0.request.value(forHTTPHeaderField: "Idempotency-Key") }
        XCTAssertEqual(Set(keys).count, 3)
    }

    func testSettlement201UpdatesHistoryAnd409ShowsChineseBanner() async throws {
        let credentials = InMemoryCredentialStore(
            credentials: DeviceCredentials(token: "tok", deviceID: "dev-1", role: .parent)
        )
        let monday = weekStart()
        let weekly = """
        [{"id":"tx-w","amount_fen":500,"occurred_on":"\(monday)","memo":"","kind":"allowance_weekly","reverses_id":null,"replaces_id":null,"settlement_week_start":"\(monday)","balance_after_fen":500}]
        """
        let settled = Box(false)
        let stub = HTTPStub()
        stub.on { request in
            if request.url?.path == "/v1/settlements" {
                settled.value = true
                return (201, Data(#"{"transaction":{"id":"tx-w","amount_fen":500,"occurred_on":"\#(monday)","memo":"","kind":"allowance_weekly","reverses_id":null,"replaces_id":null,"settlement_week_start":"\#(monday)"},"balance_fen":500}"#.utf8))
            }
            if request.url?.path == "/v1/snapshot" {
                return (200, boardSnapshotJSON(
                    weekStart: monday,
                    transactions: settled.value ? weekly : "[]",
                    balance: settled.value ? 500 : 0
                ))
            }
            return (404, Data(#"{}"#.utf8))
        }
        let store = try makeLiveStore(stub: stub, credentials: credentials)
        await store.refreshLedger()
        XCTAssertFalse(store.settledThisWeek)
        await store.confirmSettlement()
        XCTAssertTrue(store.settledThisWeek)
        XCTAssertEqual(store.balanceCents, 500)
        XCTAssertEqual(store.transactions.first?.reason, "本周基础零花钱")
        XCTAssertEqual(store.transactions.first?.kind, "allowance_weekly")
        XCTAssertEqual(store.pendingCelebrationCents, 500)
        let settleJSON = try XCTUnwrap(
            JSONSerialization.jsonObject(with: try XCTUnwrap(stub.requests.first(where: { $0.request.url?.path == "/v1/settlements" })?.body)) as? [String: Any]
        )
        XCTAssertEqual(settleJSON["week_start"] as? String, monday)

        let conflictStub = HTTPStub()
        conflictStub.on { request in
            if request.url?.path == "/v1/settlements" {
                return (409, Data(#"{"error":"conflict"}"#.utf8))
            }
            return (200, boardSnapshotJSON(weekStart: monday, transactions: weekly, balance: 500))
        }
        let conflicted = try makeLiveStore(stub: conflictStub, credentials: credentials)
        await conflicted.refreshLedger()
        conflicted.settledThisWeek = false
        await conflicted.confirmSettlement()
        XCTAssertEqual(conflicted.lastRecordRejectedReason, "这一周已经结算过了")
        XCTAssertTrue(conflicted.settledThisWeek)
        XCTAssertEqual(conflicted.role, .parent)
    }

    func testSettlementEmptyWeekBanner() async throws {
        let credentials = InMemoryCredentialStore(
            credentials: DeviceCredentials(token: "tok", deviceID: "dev-1", role: .parent)
        )
        let monday = weekStart()
        let stub = HTTPStub()
        stub.on { request in
            if request.url?.path == "/v1/settlements" {
                return (400, Data(#"{"error":"invalid"}"#.utf8))
            }
            return (200, boardSnapshotJSON(weekStart: monday, items: "[]"))
        }
        let store = try makeLiveStore(stub: stub, credentials: credentials)
        await store.refreshLedger()
        await store.confirmSettlement()
        XCTAssertEqual(store.lastRecordRejectedReason, "本周没有达成的项目，还不能结算")
        XCTAssertFalse(store.settledThisWeek)
    }

    func testGoalReplaceAndArchiveHitEndpoints() async throws {
        let credentials = InMemoryCredentialStore(
            credentials: DeviceCredentials(token: "tok", deviceID: "dev-1", role: .parent)
        )
        let monday = weekStart()
        let goalJSON = Box(#"{"id":"g1","name":"乐高赛车","target_amount_fen":40000,"status":"active"}"#)
        let stub = HTTPStub()
        stub.on { request in
            let path = request.url?.path ?? ""
            if path == "/v1/goals" {
                goalJSON.value = #"{"id":"g2","name":"恐龙拼图","target_amount_fen":6800,"status":"active"}"#
                return (201, Data(#"{"goal":{"id":"g2","name":"恐龙拼图","target_amount_fen":6800,"status":"active"},"archived":{"id":"g1","name":"乐高赛车","target_amount_fen":40000,"status":"archived"}}"#.utf8))
            }
            if path.hasSuffix("/archive") {
                goalJSON.value = "null"
                return (200, Data(#"{"goal":{"id":"g2","name":"恐龙拼图","target_amount_fen":6800,"status":"archived"}}"#.utf8))
            }
            if path == "/v1/snapshot" {
                return (200, boardSnapshotJSON(weekStart: monday, goal: goalJSON.value))
            }
            return (404, Data(#"{}"#.utf8))
        }
        let store = try makeLiveStore(stub: stub, credentials: credentials)
        await store.refreshLedger()
        XCTAssertEqual(store.goal?.title, "乐高赛车")
        XCTAssertEqual(store.goal?.id, "g1")

        await store.saveGoal(title: "恐龙拼图", targetCents: 6800)
        XCTAssertEqual(store.goal?.title, "恐龙拼图")
        XCTAssertEqual(store.goal?.targetCents, 6800)

        await store.archiveGoal()
        XCTAssertNil(store.goal)
        XCTAssertTrue(store.wishes.isEmpty)

        let goalWrites = stub.requests.filter { ($0.request.url?.path ?? "").hasPrefix("/v1/goals") }
        XCTAssertEqual(goalWrites.count, 2)
        XCTAssertEqual(goalWrites[0].request.url?.path, "/v1/goals")
        XCTAssertEqual(goalWrites[1].request.url?.path, "/v1/goals/g2/archive")
        let keys = goalWrites.compactMap { $0.request.value(forHTTPHeaderField: "Idempotency-Key") }
        XCTAssertEqual(Set(keys).count, 2)
    }

    func testChildMapsSnapshotAndCannotWriteBoardSettleOrGoals() async throws {
        let credentials = InMemoryCredentialStore(
            credentials: DeviceCredentials(token: "child-tok", deviceID: "dev-c", role: .child)
        )
        let monday = weekStart()
        let stub = HTTPStub()
        stub.on { request in
            XCTAssertEqual(request.url?.path, "/v1/snapshot", "child must not call write APIs")
            XCTAssertEqual(request.httpMethod, "GET")
            return (200, boardSnapshotJSON(
                weekStart: monday,
                checkins: #"[{"item_id":"item-jump","local_date":"\#(monday)"}]"#,
                goal: #"{"id":"g1","name":"乐高赛车","target_amount_fen":40000,"status":"active"}"#,
                ruleChanges: #"[{"id":"rc1","occurred_on":"\#(monday)","summary":"加了新的一项：跳绳"}]"#
            ))
        }
        let store = try makeLiveStore(stub: stub, credentials: credentials)
        XCTAssertEqual(store.role, .child)
        await store.refreshLedger()
        XCTAssertEqual(store.board.first?.name, "跳绳")
        XCTAssertEqual(store.board.first?.days[0], .done)
        XCTAssertEqual(store.changes.first?.text, "加了新的一项：跳绳")
        XCTAssertEqual(store.goal?.title, "乐高赛车")
        XCTAssertTrue(store.wishes.isEmpty)
        XCTAssertEqual(store.bonusCents, 0)

        let before = stub.requests.count
        await store.toggleBoardCell(row: 0, day: 0)
        await store.saveBoardItem(at: nil, name: "练琴", goal: 3, rewardCents: 200)
        await store.deleteBoardItem(at: 0)
        await store.confirmSettlement()
        await store.saveGoal(title: "不该成功", targetCents: 1000)
        await store.archiveGoal()
        XCTAssertEqual(stub.requests.count, before)
        XCTAssertEqual(store.lastRecordRejectedReason, "儿童端不能记账")
        XCTAssertEqual(store.goal?.title, "乐高赛车")
    }

    func testTick401ClearsSession() async throws {
        let credentials = InMemoryCredentialStore(
            credentials: DeviceCredentials(token: "stale", deviceID: "dev-1", role: .parent)
        )
        let monday = weekStart()
        let stub = HTTPStub()
        stub.on { request in
            if request.url?.path == "/v1/snapshot" {
                return (200, boardSnapshotJSON(weekStart: monday))
            }
            return (401, Data(#"{"error":"unauthorized"}"#.utf8))
        }
        let store = try makeLiveStore(stub: stub, credentials: credentials)
        await store.refreshLedger()
        XCTAssertEqual(store.role, .parent)
        await store.toggleBoardCell(row: 0, day: 0)
        XCTAssertNil(store.role)
        XCTAssertNil(try credentials.load())
        XCTAssertEqual(store.lastRecordRejectedReason, AuthAPIError.unauthorized.userMessage)
    }
}
