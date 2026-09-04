import XCTest
@testable import ForestsWallet

struct RecordedHTTPRequest {
    var request: URLRequest
    var body: Data?
}

final class HTTPStub: @unchecked Sendable {
    let host: String
    private let lock = NSLock()
    private var handler: (@Sendable (URLRequest) throws -> (Int, Data))?
    private var recorded: [RecordedHTTPRequest] = []

    init(host: String = "fw-\(UUID().uuidString).test") {
        self.host = host
        HTTPStubCenter.register(self)
    }

    deinit {
        HTTPStubCenter.unregister(host)
    }

    func on(_ handler: @escaping @Sendable (URLRequest) throws -> (Int, Data)) {
        lock.lock()
        self.handler = handler
        lock.unlock()
    }

    func handle(_ request: URLRequest) throws -> (Int, Data) {
        lock.lock()
        let handler = self.handler
        lock.unlock()
        guard let handler else {
            throw URLError(.cannotFindHost)
        }
        return try handler(request)
    }

    func record(_ request: URLRequest, body: Data?) {
        lock.lock()
        recorded.append(RecordedHTTPRequest(request: request, body: body))
        lock.unlock()
    }

    var requests: [RecordedHTTPRequest] {
        lock.lock()
        defer { lock.unlock() }
        return recorded
    }
}

enum HTTPStubCenter {
    private static let lock = NSLock()
    nonisolated(unsafe) private static var stubs: [String: HTTPStub] = [:]

    static func register(_ stub: HTTPStub) {
        lock.lock()
        stubs[stub.host] = stub
        lock.unlock()
    }

    static func unregister(_ host: String) {
        lock.lock()
        stubs.removeValue(forKey: host)
        lock.unlock()
    }

    static func stub(for host: String) -> HTTPStub? {
        lock.lock()
        defer { lock.unlock() }
        return stubs[host]
    }
}

final class StubURLProtocol: URLProtocol {
    override class func canInit(with request: URLRequest) -> Bool { true }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let url = request.url, let host = url.host, let stub = HTTPStubCenter.stub(for: host) else {
            client?.urlProtocol(self, didFailWithError: URLError(.cannotFindHost))
            return
        }
        stub.record(request, body: Self.body(from: request))
        do {
            let (status, data) = try stub.handle(request)
            let response = HTTPURLResponse(
                url: url,
                statusCode: status,
                httpVersion: "HTTP/1.1",
                headerFields: ["Content-Type": "application/json"]
            )!
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}

    private static func body(from request: URLRequest) -> Data? {
        if let body = request.httpBody {
            return body
        }
        guard let stream = request.httpBodyStream else {
            return nil
        }
        stream.open()
        defer { stream.close() }
        var data = Data()
        let bufferSize = 1024
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        defer { buffer.deallocate() }
        while stream.hasBytesAvailable {
            let read = stream.read(buffer, maxLength: bufferSize)
            if read <= 0 { break }
            data.append(buffer, count: read)
        }
        return data
    }
}

final class AuthClientTests: XCTestCase {
    private func makeClient(_ stub: HTTPStub) throws -> AuthClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubURLProtocol.self]
        configuration.timeoutIntervalForRequest = 2
        configuration.waitsForConnectivity = false
        configuration.urlCache = nil
        let session = URLSession(configuration: configuration)
        return try AuthClient(baseURL: URL(string: "https://\(stub.host)")!, session: session)
    }

    func testProductionOriginIsHTTPSWalletHost() {
        XCTAssertEqual(AuthClient.productionOrigin.absoluteString, "https://wallet.gengdaneng.com")
        XCTAssertEqual(AuthClient.productionOrigin.scheme, "https")
        XCTAssertEqual(AuthClient.productionOrigin.host, "wallet.gengdaneng.com")
        let client = AuthClient.production()
        XCTAssertEqual(client.baseURL, AuthClient.productionOrigin)
        XCTAssertEqual(client.session.configuration.timeoutIntervalForRequest, AuthClient.requestTimeout)
        XCTAssertEqual(client.session.configuration.timeoutIntervalForResource, AuthClient.resourceTimeout)
        XCTAssertFalse(client.session.configuration.waitsForConnectivity)
        XCTAssertLessThanOrEqual(AuthClient.requestTimeout, 20)
        XCTAssertLessThanOrEqual(AuthClient.resourceTimeout, 30)
    }

    func testBaseURLPolicyRejectsHTTPAndEmbeddedCredentials() {
        let session = AuthClient.makeSession()
        XCTAssertThrowsError(try AuthClient(baseURL: URL(string: "http://wallet.gengdaneng.com")!, session: session)) { error in
            XCTAssertEqual(error as? AuthAPIError, .rejectedBaseURL)
        }
        XCTAssertThrowsError(try AuthClient(baseURL: URL(string: "https://user:pass@wallet.gengdaneng.com")!, session: session)) { error in
            XCTAssertEqual(error as? AuthAPIError, .rejectedBaseURL)
        }
        XCTAssertNoThrow(try AuthClient(baseURL: URL(string: "https://wallet.test")!, session: session))
    }

    func testBootstrapEncodesDeviceLabelAndOmitsAuthorization() async throws {
        let stub = HTTPStub()
        stub.on { request in
            (201, Data(#"{"token":"tok-parent","device_id":"dev-1","role":"parent"}"#.utf8))
        }
        let client = try makeClient(stub)
        let session = try await client.bootstrap(deviceLabel: "爸爸的 iPhone")
        XCTAssertEqual(session.role, .parent)
        XCTAssertEqual(session.deviceID, "dev-1")
        XCTAssertEqual(session.token, "tok-parent")

        XCTAssertEqual(stub.requests.count, 1)
        let recorded = try XCTUnwrap(stub.requests.first)
        XCTAssertEqual(recorded.request.httpMethod, "POST")
        XCTAssertEqual(recorded.request.url?.path, "/v1/bootstrap")
        XCTAssertEqual(recorded.request.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertNil(recorded.request.value(forHTTPHeaderField: "Authorization"))
        let body = try XCTUnwrap(recorded.body)
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: body) as? [String: String])
        XCTAssertEqual(json, ["device_label": "爸爸的 iPhone"])
    }

    func testAuthenticatedRequestsSendBearerHeader() async throws {
        let stub = HTTPStub()
        stub.on { request in
            if request.url?.path == "/v1/pairings" {
                return (201, Data(#"{"code":"482917","expires_in_seconds":600}"#.utf8))
            }
            if request.url?.path == "/v1/devices" {
                return (200, Data(#"{"devices":[]}"#.utf8))
            }
            if request.url?.path.hasSuffix("/revoke") == true {
                return (200, Data(#"{"ok":true}"#.utf8))
            }
            return (404, Data(#"{"error":"not_found"}"#.utf8))
        }
        let client = try makeClient(stub)
        _ = try await client.createPairing(token: "parent-token", deviceLabel: "Forrest 的 iPad")
        _ = try await client.listDevices(token: "parent-token")
        try await client.revokeDevice(token: "parent-token", id: "dev-9")

        XCTAssertEqual(stub.requests.count, 3)
        for recorded in stub.requests {
            XCTAssertEqual(recorded.request.value(forHTTPHeaderField: "Authorization"), "Bearer parent-token")
        }
        XCTAssertEqual(stub.requests[0].request.httpMethod, "POST")
        XCTAssertEqual(stub.requests[0].request.url?.path, "/v1/pairings")
        XCTAssertEqual(stub.requests[1].request.httpMethod, "GET")
        XCTAssertEqual(stub.requests[1].request.url?.path, "/v1/devices")
        XCTAssertTrue(stub.requests[1].body == nil || stub.requests[1].body?.isEmpty == true)
        XCTAssertEqual(stub.requests[2].request.httpMethod, "POST")
        XCTAssertEqual(stub.requests[2].request.url?.path, "/v1/devices/dev-9/revoke")
    }

    func testClosedBootstrapInvalidCodeOfflineAndNoMutationRetry() async throws {
        let stub = HTTPStub()
        stub.on { request in
            if request.url?.path == "/v1/bootstrap" {
                return (403, Data(#"{"error":"forbidden"}"#.utf8))
            }
            if request.url?.path == "/v1/pairings/claim" {
                return (401, Data(#"{"error":"unauthorized"}"#.utf8))
            }
            return (500, Data(#"{"error":"internal"}"#.utf8))
        }
        let client = try makeClient(stub)

        await assertThrows({ try await client.bootstrap(deviceLabel: "papa-iphone") }) { error in
            XCTAssertEqual(error as? AuthAPIError, .closedBootstrap)
        }
        XCTAssertEqual(stub.requests.filter { $0.request.url?.path == "/v1/bootstrap" }.count, 1)

        await assertThrows({ try await client.claimPairing(code: "000000") }) { error in
            XCTAssertEqual(error as? AuthAPIError, .invalidOrExpiredCode)
        }

        let offline = HTTPStub()
        offline.on { _ in
            throw URLError(.notConnectedToInternet)
        }
        let offlineClient = try makeClient(offline)
        await assertThrows({ try await offlineClient.bootstrap(deviceLabel: "papa-iphone") }) { error in
            XCTAssertEqual(error as? AuthAPIError, .offline)
        }

        let failing = HTTPStub()
        failing.on { _ in
            (500, Data(#"{"error":"internal"}"#.utf8))
        }
        let failingClient = try makeClient(failing)
        await assertThrows({ try await failingClient.bootstrap(deviceLabel: "papa-iphone") }) { error in
            XCTAssertEqual(error as? AuthAPIError, .serverFailure)
        }
        XCTAssertEqual(failing.requests.count, 1)
    }

    func testConflictMapsToParentAlreadyRegistered() async throws {
        let stub = HTTPStub()
        stub.on { _ in
            (409, Data(#"{"error":"conflict"}"#.utf8))
        }
        let client = try makeClient(stub)
        await assertThrows({ try await client.bootstrap(deviceLabel: "second") }) { error in
            XCTAssertEqual(error as? AuthAPIError, .parentAlreadyRegistered)
        }
        XCTAssertEqual(stub.requests.count, 1)
    }
}

final class CredentialStoreTests: XCTestCase {
    func testInMemorySaveLoadAndClear() throws {
        let store = InMemoryCredentialStore()
        XCTAssertNil(try store.load())
        let credentials = DeviceCredentials(token: "secret-token", deviceID: "dev-1", role: .parent)
        try store.save(credentials)
        XCTAssertEqual(try store.load(), credentials)
        XCTAssertEqual(String(describing: credentials), "DeviceCredentials(deviceID: dev-1, role: parent, token: <redacted>)")
        XCTAssertFalse(String(describing: credentials).contains("secret-token"))
        try store.clear()
        XCTAssertNil(try store.load())
    }

    func testKeychainSaveLoadAndClear() throws {
        let store = KeychainCredentialStore(service: "fw.tests.\(UUID().uuidString)")
        do {
            try store.clear()
            let credentials = DeviceCredentials(token: "keychain-token", deviceID: "dev-k", role: .child)
            try store.save(credentials)
            XCTAssertEqual(try store.load(), credentials)
            try store.clear()
            XCTAssertNil(try store.load())
        } catch CredentialStoreError.unavailable {
            throw XCTSkip("Keychain unavailable in this environment")
        }
    }
}

@MainActor
final class AuthSessionStoreTests: XCTestCase {
    private func makeLiveStore(
        stub: HTTPStub,
        credentials: InMemoryCredentialStore = InMemoryCredentialStore()
    ) throws -> (SampleWalletStore, InMemoryCredentialStore) {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubURLProtocol.self]
        configuration.timeoutIntervalForRequest = 2
        configuration.waitsForConnectivity = false
        let session = URLSession(configuration: configuration)
        let client = try AuthClient(baseURL: URL(string: "https://\(stub.host)")!, session: session)
        let store = SampleWalletStore(
            launchRole: .parent,
            authClient: client,
            credentials: credentials,
            deviceLabel: "爸爸的 iPhone",
            childDeviceLabel: "Forrest 的 iPad"
        )
        return (store, credentials)
    }

    func testLaunchStoreStaysSampleDuringUnitTests() {
        let store = SampleWalletStore.makeLaunchStore([])
        XCTAssertFalse(store.isRemoteAuth)
        XCTAssertNil(store.role)
        XCTAssertFalse(SampleWalletStore.fromLaunchArguments(["-FWRoleParent"]).isRemoteAuth)
    }

    func testRestoredCredentialsRouteToRole() throws {
        let credentials = InMemoryCredentialStore(
            credentials: DeviceCredentials(token: "tok", deviceID: "dev-1", role: .parent)
        )
        let stub = HTTPStub()
        let (store, _) = try makeLiveStore(stub: stub, credentials: credentials)
        XCTAssertTrue(store.isRemoteAuth)
        XCTAssertEqual(store.role, .parent)
        XCTAssertEqual(store.devices.first?.id, "dev-1")
        XCTAssertTrue(store.devices.first?.isThisDevice ?? false)
    }

    func testBootstrapPersistsAndRoutesParent() async throws {
        let stub = HTTPStub()
        stub.on { request in
            if request.url?.path == "/v1/bootstrap" {
                return (201, Data(#"{"token":"tok-parent","device_id":"dev-p","role":"parent"}"#.utf8))
            }
            if request.url?.path == "/v1/devices" {
                let body = """
                {"devices":[{"id":"dev-p","role":"parent","status":"active","label":"爸爸的 iPhone","revoked_at":null,"last_seen_at":null,"created_at":"2026-01-01T00:00:00.000Z"}]}
                """
                return (200, Data(body.utf8))
            }
            return (500, Data(#"{"error":"internal"}"#.utf8))
        }
        let (store, credentials) = try makeLiveStore(stub: stub)
        XCTAssertNil(store.role)
        await store.bootstrapParent()
        XCTAssertEqual(store.role, .parent)
        XCTAssertEqual(try credentials.load()?.deviceID, "dev-p")
        XCTAssertEqual(try credentials.load()?.role, .parent)
        XCTAssertEqual(try credentials.load()?.token, "tok-parent")
        XCTAssertNil(store.lastAuthErrorMessage)
        XCTAssertEqual(store.devices.first?.id, "dev-p")
    }

    func testClosedBootstrapDoesNotPersist() async throws {
        let stub = HTTPStub()
        stub.on { _ in
            (403, Data(#"{"error":"forbidden"}"#.utf8))
        }
        let (store, credentials) = try makeLiveStore(stub: stub)
        await store.bootstrapParent()
        XCTAssertNil(store.role)
        XCTAssertNil(try credentials.load())
        XCTAssertEqual(store.lastAuthErrorMessage, AuthAPIError.closedBootstrap.userMessage)
        XCTAssertFalse(store.lastAuthErrorIsOffline)
    }

    func testInvalidCodeDoesNotPersist() async throws {
        let stub = HTTPStub()
        stub.on { _ in
            (401, Data(#"{"error":"unauthorized"}"#.utf8))
        }
        let (store, credentials) = try makeLiveStore(stub: stub)
        let rejected = await store.pairChild(code: "000000")
        XCTAssertFalse(rejected)
        XCTAssertNil(store.role)
        XCTAssertNil(try credentials.load())
        XCTAssertEqual(store.lastAuthErrorMessage, AuthAPIError.invalidOrExpiredCode.userMessage)
    }

    func testTokenRejectionClearsCredentials() async throws {
        let credentials = InMemoryCredentialStore(
            credentials: DeviceCredentials(token: "stale", deviceID: "dev-1", role: .parent)
        )
        let stub = HTTPStub()
        stub.on { _ in
            (401, Data(#"{"error":"unauthorized"}"#.utf8))
        }
        let (store, stored) = try makeLiveStore(stub: stub, credentials: credentials)
        XCTAssertEqual(store.role, .parent)
        await store.refreshDevices()
        XCTAssertNil(store.role)
        XCTAssertNil(try stored.load())
        XCTAssertEqual(store.lastAuthErrorMessage, AuthAPIError.unauthorized.userMessage)
    }

    func testOfflineErrorKeepsCredentials() async throws {
        let credentials = InMemoryCredentialStore(
            credentials: DeviceCredentials(token: "tok", deviceID: "dev-1", role: .parent)
        )
        let stub = HTTPStub()
        stub.on { _ in
            throw URLError(.notConnectedToInternet)
        }
        let (store, stored) = try makeLiveStore(stub: stub, credentials: credentials)
        await store.refreshDevices()
        XCTAssertEqual(store.role, .parent)
        XCTAssertEqual(try stored.load()?.token, "tok")
        XCTAssertEqual(store.lastAuthErrorMessage, AuthAPIError.offline.userMessage)
        XCTAssertTrue(store.lastAuthErrorIsOffline)
    }

    func testSuccessfulChildClaimRoutesAndStores() async throws {
        let stub = HTTPStub()
        stub.on { _ in
            (201, Data(#"{"token":"tok-child","device_id":"dev-c","role":"child"}"#.utf8))
        }
        let (store, credentials) = try makeLiveStore(stub: stub)
        let claimed = await store.pairChild(code: "482917")
        XCTAssertTrue(claimed)
        XCTAssertEqual(store.role, .child)
        XCTAssertFalse(store.hasSeenChildWelcome)
        XCTAssertEqual(try credentials.load()?.role, .child)
        XCTAssertEqual(try credentials.load()?.deviceID, "dev-c")
        XCTAssertEqual(stub.requests.first?.request.url?.path, "/v1/pairings/claim")
        let claimBody = try XCTUnwrap(stub.requests.first?.body)
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: claimBody) as? [String: String])
        XCTAssertEqual(json["code"], "482917")
    }

    func testSampleModeDoesNotUseRemoteClient() async {
        let store = SampleWalletStore(launchRole: .unpaired)
        XCTAssertFalse(store.isRemoteAuth)
        await store.bootstrapParent()
        XCTAssertEqual(store.role, .parent)
        let code = await store.generatePairingCode()
        XCTAssertEqual(code, SampleData.pairingCode)
    }

    func testDeviceLabelStaysWithinSixtyFourUnits() {
        let long = String(repeating: "啊", count: 80)
        let bounded = DeviceLabel.bounded(long, fallback: DeviceLabel.parentFallback)
        XCTAssertEqual(bounded.utf16.count, 64)
        XCTAssertEqual(DeviceLabel.bounded("  ", fallback: "爸爸的 iPhone"), "爸爸的 iPhone")
    }
}

extension XCTestCase {
    func assertThrows<T>(
        _ expression: () async throws -> T,
        file: StaticString = #filePath,
        line: UInt = #line,
        _ errorHandler: (Error) -> Void
    ) async {
        do {
            _ = try await expression()
            XCTFail("Expected error", file: file, line: line)
        } catch {
            errorHandler(error)
        }
    }
}
