import XCTest
@testable import ForestsWallet

final class LedgerClientTests: XCTestCase {
    private func makeClient(_ stub: HTTPStub) throws -> AuthClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubURLProtocol.self]
        configuration.timeoutIntervalForRequest = 2
        configuration.waitsForConnectivity = false
        configuration.urlCache = nil
        let session = URLSession(configuration: configuration)
        return try AuthClient(baseURL: URL(string: "https://\(stub.host)")!, session: session)
    }

    func testEmptySnapshotDecodesWithoutError() throws {
        let data = Data(#"{"child":{"id":"11111111-1111-1111-1111-111111111111","display_name":"child"},"timezone":"Asia/Shanghai","week":{"start":"2026-08-31","end":"2026-09-06"},"balance_fen":0,"categories":[],"recent_transactions":[],"checkin_items":[],"checkins":[],"rule_changes":[],"goal":null}"#.utf8)
        let snapshot = try JSONDecoder().decode(RemoteSnapshot.self, from: data)
        XCTAssertEqual(snapshot.balanceFen, 0)
        XCTAssertEqual(snapshot.recentTransactions, [])
        XCTAssertEqual(snapshot.checkinItems, [])
        XCTAssertEqual(snapshot.ruleChanges, [])
        XCTAssertNil(snapshot.goal)
        XCTAssertEqual(snapshot.week?.start, "2026-08-31")
        XCTAssertEqual(LedgerMapping.weekLabel(from: snapshot.week), "8月31日 – 9月6日")
        XCTAssertEqual(LedgerMapping.entries(from: snapshot.recentTransactions), [])
        XCTAssertNil(LedgerMapping.goal(from: snapshot.goal))
    }

    func testBareObjectSnapshotIsEmptySafe() throws {
        let snapshot = try JSONDecoder().decode(RemoteSnapshot.self, from: Data(#"{}"#.utf8))
        XCTAssertEqual(snapshot.balanceFen, 0)
        XCTAssertEqual(snapshot.recentTransactions, [])
        XCTAssertEqual(snapshot.categories, [])
        XCTAssertNil(snapshot.goal)
    }

    func testSnapshotDecodeMapsSignedFenAndStruckReverse() throws {
        let data = Data("""
        {
          "balance_fen": -1100,
          "week": {"start": "2026-09-01", "end": "2026-09-07"},
          "goal": {"id": "g1", "name": "乐高赛车", "target_amount_fen": 40000, "status": "active"},
          "categories": [{"id": "c1", "slug": "toys", "label": "玩具", "sort": 2}],
          "recent_transactions": [
            {
              "id": "rep-1",
              "amount_fen": -1100,
              "occurred_on": "2026-09-02",
              "recorded_at": "2026-09-02T10:05:00.000Z",
              "memo": "买书",
              "category": {"slug": "books", "label": "书和文具"},
              "kind": "replacement",
              "reverses_id": null,
              "replaces_id": "orig-1",
              "balance_after_fen": -1100
            },
            {
              "id": "rev-1",
              "amount_fen": 1400,
              "occurred_on": "2026-09-02",
              "recorded_at": "2026-09-02T10:05:00.000Z",
              "memo": "乐高小车",
              "category": {"slug": "toys", "label": "玩具"},
              "kind": "reverse",
              "reverses_id": "orig-1",
              "replaces_id": null,
              "balance_after_fen": 300
            },
            {
              "id": "orig-1",
              "amount_fen": -1400,
              "occurred_on": "2026-09-02",
              "recorded_at": "2026-09-02T10:00:00.000Z",
              "memo": "乐高小车",
              "category": {"slug": "toys", "label": "玩具"},
              "kind": "spend",
              "reverses_id": null,
              "replaces_id": null,
              "balance_after_fen": -1400
            }
          ]
        }
        """.utf8)
        let snapshot = try JSONDecoder().decode(RemoteSnapshot.self, from: data)
        XCTAssertEqual(snapshot.balanceFen, -1100)
        XCTAssertEqual(LedgerMapping.goal(from: snapshot.goal)?.title, "乐高赛车")
        XCTAssertEqual(LedgerMapping.goal(from: snapshot.goal)?.targetCents, 40_000)
        XCTAssertEqual(LedgerMapping.categories(from: snapshot.categories).map(\.id), ["toy"])

        let entries = LedgerMapping.entries(from: snapshot.recentTransactions)
        XCTAssertEqual(entries.count, 3)
        XCTAssertEqual(entries[0].direction, .spend)
        XCTAssertEqual(entries[0].cents, 1100)
        XCTAssertEqual(entries[0].categoryID, "book")
        XCTAssertFalse(entries[0].reversed)
        XCTAssertTrue(entries[0].isCorrectable)

        XCTAssertEqual(entries[1].direction, .correction)
        XCTAssertEqual(entries[1].cents, 1400)
        XCTAssertFalse(entries[1].isCorrectable)

        XCTAssertEqual(entries[2].id, "orig-1")
        XCTAssertTrue(entries[2].reversed)
        XCTAssertFalse(entries[2].isCorrectable)
        XCTAssertEqual(entries[2].categoryID, "toy")
    }

    func testSnapshotFetchSendsBearerAndOmitsIdempotencyKey() async throws {
        let stub = HTTPStub()
        stub.on { _ in
            (200, Data(#"{"balance_fen":0,"recent_transactions":[],"goal":null}"#.utf8))
        }
        let client = try makeClient(stub)
        let snapshot = try await client.snapshot(token: "parent-token")
        XCTAssertEqual(snapshot.balanceFen, 0)
        XCTAssertEqual(stub.requests.count, 1)
        let recorded = try XCTUnwrap(stub.requests.first)
        XCTAssertEqual(recorded.request.httpMethod, "GET")
        XCTAssertEqual(recorded.request.url?.path, "/v1/snapshot")
        XCTAssertEqual(recorded.request.value(forHTTPHeaderField: "Authorization"), "Bearer parent-token")
        XCTAssertNil(recorded.request.value(forHTTPHeaderField: "Idempotency-Key"))
    }

    func testCreateTransactionEncodesSignedFenAndIdempotencyHeader() async throws {
        let stub = HTTPStub()
        stub.on { _ in
            (201, Data(#"{"transaction":{"id":"tx-1","amount_fen":-1500,"occurred_on":"2026-09-02","memo":"冰淇淋","category":{"slug":"food","label":"吃的"},"kind":"spend","reverses_id":null,"replaces_id":null},"balance_fen":7200}"#.utf8))
        }
        let client = try makeClient(stub)
        let key = "22222222-2222-4222-8222-222222222222"
        let response = try await client.createTransaction(
            token: "parent-token",
            idempotencyKey: key,
            request: CreateTransactionRequest(
                kind: "spend",
                amountFen: -1500,
                occurredOn: "2026-09-02",
                memo: "冰淇淋",
                category: "food"
            )
        )
        XCTAssertEqual(response.balanceFen, 7200)
        XCTAssertEqual(response.transaction.amountFen, -1500)

        let recorded = try XCTUnwrap(stub.requests.first)
        XCTAssertEqual(recorded.request.httpMethod, "POST")
        XCTAssertEqual(recorded.request.url?.path, "/v1/transactions")
        XCTAssertEqual(recorded.request.value(forHTTPHeaderField: "Authorization"), "Bearer parent-token")
        XCTAssertEqual(recorded.request.value(forHTTPHeaderField: "Idempotency-Key"), key)
        let body = try XCTUnwrap(recorded.body)
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: body) as? [String: Any])
        XCTAssertEqual(json["kind"] as? String, "spend")
        XCTAssertEqual(json["amount_fen"] as? Int, -1500)
        XCTAssertEqual(json["occurred_on"] as? String, "2026-09-02")
        XCTAssertEqual(json["memo"] as? String, "冰淇淋")
        XCTAssertEqual(json["category"] as? String, "food")
    }

    func testIncomeTempOmitsNilCategoryAndUsesPositiveFen() async throws {
        let stub = HTTPStub()
        stub.on { _ in
            (201, Data(#"{"transaction":{"id":"tx-2","amount_fen":1000,"occurred_on":"2026-09-03","memo":"帮忙","kind":"income_temp","reverses_id":null,"replaces_id":null},"balance_fen":1000}"#.utf8))
        }
        let client = try makeClient(stub)
        _ = try await client.createTransaction(
            token: "parent-token",
            idempotencyKey: UUID().uuidString,
            request: CreateTransactionRequest(
                kind: "income_temp",
                amountFen: 1000,
                occurredOn: "2026-09-03",
                memo: "帮忙",
                category: nil
            )
        )
        let body = try XCTUnwrap(stub.requests.first?.body)
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: body) as? [String: Any])
        XCTAssertEqual(json["kind"] as? String, "income_temp")
        XCTAssertEqual(json["amount_fen"] as? Int, 1000)
        XCTAssertNil(json["category"])
    }

    func testDistinctWritesUseDistinctIdempotencyKeys() async throws {
        let stub = HTTPStub()
        stub.on { _ in
            (201, Data(#"{"transaction":{"id":"tx","amount_fen":1000,"occurred_on":"2026-09-01","kind":"income_temp","reverses_id":null,"replaces_id":null},"balance_fen":1000}"#.utf8))
        }
        let client = try makeClient(stub)
        let first = UUID().uuidString
        let second = UUID().uuidString
        XCTAssertNotEqual(first, second)
        _ = try await client.createTransaction(
            token: "t",
            idempotencyKey: first,
            request: CreateTransactionRequest(kind: "income_temp", amountFen: 1000, occurredOn: "2026-09-01")
        )
        _ = try await client.createTransaction(
            token: "t",
            idempotencyKey: second,
            request: CreateTransactionRequest(kind: "income_temp", amountFen: 1000, occurredOn: "2026-09-01")
        )
        XCTAssertEqual(stub.requests.count, 2)
        XCTAssertEqual(stub.requests[0].request.value(forHTTPHeaderField: "Idempotency-Key"), first)
        XCTAssertEqual(stub.requests[1].request.value(forHTTPHeaderField: "Idempotency-Key"), second)
    }

    func testChildCannotWrite() async throws {
        let stub = HTTPStub()
        stub.on { _ in
            (403, Data(#"{"error":"forbidden"}"#.utf8))
        }
        let client = try makeClient(stub)
        await assertThrows({
            try await client.createTransaction(
                token: "child-token",
                idempotencyKey: UUID().uuidString,
                request: CreateTransactionRequest(kind: "income_temp", amountFen: 1000, occurredOn: "2026-09-01")
            )
        }) { error in
            XCTAssertEqual(error as? AuthAPIError, .forbidden)
            XCTAssertEqual((error as? AuthAPIError)?.userMessage, "儿童端不能记账")
        }
        XCTAssertEqual(stub.requests.count, 1)
        XCTAssertNotNil(stub.requests.first?.request.value(forHTTPHeaderField: "Idempotency-Key"))
    }

    func testCorrectionPathAndIdempotencyHeader() async throws {
        let stub = HTTPStub()
        stub.on { _ in
            (201, Data(#"{"original":{"id":"orig-1","amount_fen":-1400,"occurred_on":"2026-09-02","kind":"spend","reverses_id":null,"replaces_id":null},"reverse":{"id":"rev-1","amount_fen":1400,"occurred_on":"2026-09-02","kind":"reverse","reverses_id":"orig-1","replaces_id":null},"replacement":{"id":"rep-1","amount_fen":-1100,"occurred_on":"2026-09-02","kind":"replacement","reverses_id":null,"replaces_id":"orig-1"},"balance_fen":-1100}"#.utf8))
        }
        let client = try makeClient(stub)
        let key = UUID().uuidString
        _ = try await client.correctTransaction(
            token: "parent-token",
            id: "orig-1",
            idempotencyKey: key,
            request: CorrectionRequest(amountFen: -1100, occurredOn: "2026-09-02", memo: "买书", category: "books")
        )
        let recorded = try XCTUnwrap(stub.requests.first)
        XCTAssertEqual(recorded.request.url?.path, "/v1/transactions/orig-1/correct")
        XCTAssertEqual(recorded.request.value(forHTTPHeaderField: "Idempotency-Key"), key)
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: try XCTUnwrap(recorded.body)) as? [String: Any])
        XCTAssertEqual(json["amount_fen"] as? Int, -1100)
        XCTAssertEqual(json["category"] as? String, "books")
    }

    func testLedgerErrorMapping() async throws {
        let cases: [(Int, AuthAPIError)] = [
            (401, .unauthorized),
            (403, .forbidden),
            (409, .conflict),
            (422, .invalidRequest),
            (500, .serverFailure),
        ]
        for (status, expected) in cases {
            let stub = HTTPStub()
            stub.on { _ in
                (status, Data(#"{"error":"x"}"#.utf8))
            }
            let client = try makeClient(stub)
            await assertThrows({
                try await client.createTransaction(
                    token: "t",
                    idempotencyKey: UUID().uuidString,
                    request: CreateTransactionRequest(kind: "income_temp", amountFen: 1000, occurredOn: "2026-09-01")
                )
            }) { error in
                XCTAssertEqual(error as? AuthAPIError, expected, "status \(status)")
            }
            XCTAssertEqual(stub.requests.count, 1)
        }

        let offline = HTTPStub()
        offline.on { _ in
            throw URLError(.notConnectedToInternet)
        }
        let offlineClient = try makeClient(offline)
        await assertThrows({
            try await offlineClient.createTransaction(
                token: "t",
                idempotencyKey: UUID().uuidString,
                request: CreateTransactionRequest(kind: "income_temp", amountFen: 1000, occurredOn: "2026-09-01")
            )
        }) { error in
            XCTAssertEqual(error as? AuthAPIError, .offline)
        }
        XCTAssertEqual(offline.requests.count, 1)
    }

    func testTransportErrorDoesNotRetrySameRequest() async throws {
        let stub = HTTPStub()
        stub.on { _ in
            throw URLError(.timedOut)
        }
        let client = try makeClient(stub)
        let key = UUID().uuidString
        await assertThrows({
            try await client.createTransaction(
                token: "t",
                idempotencyKey: key,
                request: CreateTransactionRequest(kind: "income_temp", amountFen: 1000, occurredOn: "2026-09-01")
            )
        }) { error in
            XCTAssertEqual(error as? AuthAPIError, .offline)
        }
        XCTAssertEqual(stub.requests.count, 1)
    }
}

@MainActor
final class LiveLedgerStoreTests: XCTestCase {
    private func makeLiveStore(
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

    func testEmptySnapshotClearsSampleAndHidesGoal() async throws {
        let credentials = InMemoryCredentialStore(
            credentials: DeviceCredentials(token: "tok", deviceID: "dev-1", role: .parent)
        )
        let stub = HTTPStub()
        stub.on { _ in
            (200, Data(#"{"balance_fen":0,"categories":[{"id":"c","slug":"food","label":"吃的","sort":1}],"recent_transactions":[],"checkin_items":[],"checkins":[],"rule_changes":[],"goal":null,"week":{"start":"2026-08-31","end":"2026-09-06"}}"#.utf8))
        }
        let store = try makeLiveStore(stub: stub, credentials: credentials)
        XCTAssertEqual(store.balanceCents, 0)
        XCTAssertNil(store.goal)
        XCTAssertTrue(store.transactions.isEmpty)
        await store.refreshLedger()
        XCTAssertEqual(store.balanceCents, 0)
        XCTAssertNil(store.snapshot.goal)
        XCTAssertTrue(store.snapshot.transactions.isEmpty)
        XCTAssertEqual(store.weekLabel, "8月31日 – 9月6日")
        XCTAssertTrue(store.isOnline)
        XCTAssertEqual(stub.requests.first?.request.url?.path, "/v1/snapshot")
    }

    func testParentWriteUsesIncomeTempAndNewKeyPerAction() async throws {
        let credentials = InMemoryCredentialStore(
            credentials: DeviceCredentials(token: "tok", deviceID: "dev-1", role: .parent)
        )
        let stub = HTTPStub()
        stub.on { request in
            if request.url?.path == "/v1/snapshot" {
                return (200, Data(#"{"balance_fen":500,"recent_transactions":[{"id":"tx-1","amount_fen":500,"occurred_on":"2026-09-01","memo":"帮忙搬水","kind":"income_temp","reverses_id":null,"replaces_id":null,"balance_after_fen":500}],"goal":null}"#.utf8))
            }
            if request.url?.path == "/v1/transactions" {
                return (201, Data(#"{"transaction":{"id":"tx-1","amount_fen":500,"occurred_on":"2026-09-01","memo":"帮忙搬水","kind":"income_temp","reverses_id":null,"replaces_id":null},"balance_fen":500}"#.utf8))
            }
            return (404, Data(#"{"error":"not_found"}"#.utf8))
        }
        let store = try makeLiveStore(stub: stub, credentials: credentials)
        let added = await store.recordEntry(direction: .income, yuan: 5, reason: "帮忙搬水", categoryID: nil)
        XCTAssertTrue(added)
        XCTAssertEqual(store.balanceCents, 500)
        XCTAssertEqual(store.pendingCelebrationCents, 500)

        let writes = stub.requests.filter { $0.request.url?.path == "/v1/transactions" }
        XCTAssertEqual(writes.count, 1)
        let key = try XCTUnwrap(writes[0].request.value(forHTTPHeaderField: "Idempotency-Key"))
        XCTAssertNotNil(UUID(uuidString: key))
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: try XCTUnwrap(writes[0].body)) as? [String: Any])
        XCTAssertEqual(json["kind"] as? String, "income_temp")
        XCTAssertEqual(json["amount_fen"] as? Int, 500)

        let spent = await store.recordEntry(direction: .spend, yuan: 15, reason: "买冰淇淋", categoryID: "toy")
        XCTAssertTrue(spent)
        let spends = stub.requests.filter { $0.request.url?.path == "/v1/transactions" }
        XCTAssertEqual(spends.count, 2)
        let secondKey = try XCTUnwrap(spends[1].request.value(forHTTPHeaderField: "Idempotency-Key"))
        XCTAssertNotEqual(key, secondKey)
        let spendJSON = try XCTUnwrap(JSONSerialization.jsonObject(with: try XCTUnwrap(spends[1].body)) as? [String: Any])
        XCTAssertEqual(spendJSON["kind"] as? String, "spend")
        XCTAssertEqual(spendJSON["amount_fen"] as? Int, -1500)
        XCTAssertEqual(spendJSON["category"] as? String, "toys")
    }

    func testLiveChildDoesNotPostTransactions() async throws {
        let credentials = InMemoryCredentialStore(
            credentials: DeviceCredentials(token: "child-tok", deviceID: "dev-c", role: .child)
        )
        let stub = HTTPStub()
        stub.on { _ in
            XCTFail("child must not call the ledger write API")
            return (500, Data(#"{}"#.utf8))
        }
        let store = try makeLiveStore(stub: stub, credentials: credentials)
        XCTAssertEqual(store.role, .child)
        let childWrite = await store.recordEntry(direction: .income, yuan: 10, reason: "不该成功", categoryID: nil)
        XCTAssertFalse(childWrite)
        XCTAssertEqual(store.lastRecordRejectedReason, "儿童端不能记账")
        XCTAssertTrue(stub.requests.isEmpty)
    }

    func testWrite401ClearsSession() async throws {
        let credentials = InMemoryCredentialStore(
            credentials: DeviceCredentials(token: "stale", deviceID: "dev-1", role: .parent)
        )
        let stub = HTTPStub()
        stub.on { _ in
            (401, Data(#"{"error":"unauthorized"}"#.utf8))
        }
        let store = try makeLiveStore(stub: stub, credentials: credentials)
        XCTAssertEqual(store.role, .parent)
        let revoked = await store.recordEntry(direction: .income, yuan: 5, reason: "x", categoryID: nil)
        XCTAssertFalse(revoked)
        XCTAssertNil(store.role)
        XCTAssertNil(try credentials.load())
        XCTAssertEqual(store.lastRecordRejectedReason, AuthAPIError.unauthorized.userMessage)
    }

    func testSnapshot401ClearsSession() async throws {
        let credentials = InMemoryCredentialStore(
            credentials: DeviceCredentials(token: "stale", deviceID: "dev-1", role: .parent)
        )
        let stub = HTTPStub()
        stub.on { _ in
            (401, Data(#"{"error":"unauthorized"}"#.utf8))
        }
        let store = try makeLiveStore(stub: stub, credentials: credentials)
        await store.refreshLedger()
        XCTAssertNil(store.role)
        XCTAssertNil(try credentials.load())
        XCTAssertEqual(store.lastAuthErrorMessage, AuthAPIError.unauthorized.userMessage)
    }

    func testWriteErrorsMapToBannersWithoutRetry() async throws {
        let credentials = InMemoryCredentialStore(
            credentials: DeviceCredentials(token: "tok", deviceID: "dev-1", role: .parent)
        )
        let offline = HTTPStub()
        offline.on { _ in
            throw URLError(.notConnectedToInternet)
        }
        let store = try makeLiveStore(stub: offline, credentials: credentials)
        let firstOffline = await store.recordEntry(direction: .income, yuan: 5, reason: "x", categoryID: nil)
        XCTAssertFalse(firstOffline)
        XCTAssertEqual(store.lastRecordRejectedReason, "没有写入任何记录 —— 记账必须联网")
        XCTAssertTrue(store.lastAuthErrorIsOffline)
        XCTAssertEqual(store.role, .parent)
        XCTAssertEqual(offline.requests.count, 1)

        store.setOnline(true)
        let secondOffline = await store.recordEntry(direction: .income, yuan: 5, reason: "x", categoryID: nil)
        XCTAssertFalse(secondOffline)
        XCTAssertEqual(offline.requests.count, 2)
        let first = try XCTUnwrap(offline.requests[0].request.value(forHTTPHeaderField: "Idempotency-Key"))
        let second = try XCTUnwrap(offline.requests[1].request.value(forHTTPHeaderField: "Idempotency-Key"))
        XCTAssertNotEqual(first, second)
        XCTAssertNotNil(UUID(uuidString: first))
        XCTAssertNotNil(UUID(uuidString: second))
    }

    func testConflictAndUnprocessableBanners() async throws {
        let credentials = InMemoryCredentialStore(
            credentials: DeviceCredentials(token: "tok", deviceID: "dev-1", role: .parent)
        )
        let stub = HTTPStub()
        stub.on { _ in
            (409, Data(#"{"error":"conflict"}"#.utf8))
        }
        let store = try makeLiveStore(stub: stub, credentials: credentials)
        let conflicted = await store.recordEntry(direction: .income, yuan: 5, reason: "x", categoryID: nil)
        XCTAssertFalse(conflicted)
        XCTAssertEqual(store.lastRecordRejectedReason, AuthAPIError.conflict.userMessage)
        XCTAssertEqual(store.role, .parent)

        let unprocessable = HTTPStub()
        unprocessable.on { _ in
            (422, Data(#"{"error":"invalid"}"#.utf8))
        }
        let store422 = try makeLiveStore(stub: unprocessable, credentials: credentials)
        let invalid = await store422.recordEntry(direction: .spend, yuan: 3, reason: "x", categoryID: "food")
        XCTAssertFalse(invalid)
        XCTAssertEqual(store422.lastRecordRejectedReason, AuthAPIError.invalidRequest.userMessage)
    }

    func testSampleModeStillIgnoresRemoteClient() async {
        let store = SampleWalletStore.fromLaunchArguments(["-FWRoleParent"])
        XCTAssertFalse(store.isRemoteAuth)
        XCTAssertEqual(store.balanceCents, 8700)
        XCTAssertEqual(store.goal?.title, "乐高赛车")
        await store.refreshLedger()
        XCTAssertEqual(store.balanceCents, 8700)
    }
}
