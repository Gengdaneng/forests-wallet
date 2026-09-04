import Foundation

enum AuthAPIError: Error, Equatable, Sendable {
    case rejectedBaseURL
    case closedBootstrap
    case parentAlreadyRegistered
    case invalidOrExpiredCode
    case unauthorized
    case forbidden
    case invalidRequest
    case notFound
    case conflict
    case rateLimited
    case offline
    case serverFailure

    var userMessage: String {
        switch self {
        case .closedBootstrap:
            "现在还不能注册，请让运维打开注册窗口"
        case .parentAlreadyRegistered:
            "已经有家长设备了"
        case .invalidOrExpiredCode:
            "数字不对，再问爸爸一次"
        case .unauthorized:
            "这台设备已失效，请重新注册"
        case .forbidden:
            "儿童端不能记账"
        case .invalidRequest, .conflict:
            "请检查后再试"
        case .notFound:
            "找不到这台设备"
        case .rateLimited:
            "试得太多次了，稍后再试"
        case .offline:
            "现在连不上网络"
        case .rejectedBaseURL, .serverFailure:
            "暂时连不上，稍后再试"
        }
    }

    var isOffline: Bool { self == .offline }
}

struct AuthSessionResponse: Decodable, Equatable, Sendable {
    var token: String
    var deviceID: String
    var role: DeviceRole

    enum CodingKeys: String, CodingKey {
        case token
        case deviceID = "device_id"
        case role
    }
}

struct PairingCodeResponse: Decodable, Equatable, Sendable {
    var code: String
    var expiresInSeconds: Int

    enum CodingKeys: String, CodingKey {
        case code
        case expiresInSeconds = "expires_in_seconds"
    }
}

struct RemoteDevice: Decodable, Equatable, Sendable {
    var id: String
    var role: DeviceRole
    var status: String
    var label: String
    var revokedAt: String?
    var lastSeenAt: String?
    var createdAt: String

    enum CodingKeys: String, CodingKey {
        case id, role, status, label
        case revokedAt = "revoked_at"
        case lastSeenAt = "last_seen_at"
        case createdAt = "created_at"
    }

    var isActive: Bool { status == "active" }
}

struct DeviceListResponse: Decodable, Equatable, Sendable {
    var devices: [RemoteDevice]
}

struct BootstrapRequest: Encodable, Equatable, Sendable {
    var deviceLabel: String

    enum CodingKeys: String, CodingKey {
        case deviceLabel = "device_label"
    }
}

struct CreatePairingRequest: Encodable, Equatable, Sendable {
    var deviceLabel: String

    enum CodingKeys: String, CodingKey {
        case deviceLabel = "device_label"
    }
}

struct ClaimPairingRequest: Encodable, Equatable, Sendable {
    var code: String
}

struct AuthClient: Sendable {
    static let productionOrigin = URL(string: "https://wallet.gengdaneng.com")!
    static let requestTimeout: TimeInterval = 15
    static let resourceTimeout: TimeInterval = 30

    let baseURL: URL
    let session: URLSession

    static func production(session: URLSession = AuthClient.makeSession()) -> AuthClient {
        AuthClient(validatedBaseURL: productionOrigin, session: session)
    }

    static func makeSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = requestTimeout
        configuration.timeoutIntervalForResource = resourceTimeout
        configuration.waitsForConnectivity = false
        configuration.httpCookieAcceptPolicy = .never
        configuration.httpShouldSetCookies = false
        configuration.urlCache = nil
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        return URLSession(configuration: configuration)
    }

    init(baseURL: URL, session: URLSession) throws {
        self.init(validatedBaseURL: try Self.validatedBaseURL(baseURL), session: session)
    }

    private init(validatedBaseURL: URL, session: URLSession) {
        self.baseURL = validatedBaseURL
        self.session = session
    }

    static func validatedBaseURL(_ url: URL) throws -> URL {
        guard url.scheme?.lowercased() == "https" else {
            throw AuthAPIError.rejectedBaseURL
        }
        guard let host = url.host, !host.isEmpty else {
            throw AuthAPIError.rejectedBaseURL
        }
        guard url.user == nil, url.password == nil else {
            throw AuthAPIError.rejectedBaseURL
        }
        var components = URLComponents()
        components.scheme = "https"
        components.host = host
        components.port = url.port
        guard let normalized = components.url else {
            throw AuthAPIError.rejectedBaseURL
        }
        return normalized
    }

    func bootstrap(deviceLabel: String) async throws -> AuthSessionResponse {
        try await send(
            method: "POST",
            path: "/v1/bootstrap",
            body: BootstrapRequest(deviceLabel: deviceLabel),
            token: nil,
            mapError: { status, _ in
                switch status {
                case 403: return .closedBootstrap
                case 409: return .parentAlreadyRegistered
                default: return nil
                }
            }
        )
    }

    func createPairing(token: String, deviceLabel: String) async throws -> PairingCodeResponse {
        let response: PairingCodeResponse = try await send(
            method: "POST",
            path: "/v1/pairings",
            body: CreatePairingRequest(deviceLabel: deviceLabel),
            token: token,
            mapError: { _, _ in nil }
        )
        guard response.code.count == 6, response.code.allSatisfy(\.isNumber) else {
            throw AuthAPIError.serverFailure
        }
        return response
    }

    func claimPairing(code: String) async throws -> AuthSessionResponse {
        try await send(
            method: "POST",
            path: "/v1/pairings/claim",
            body: ClaimPairingRequest(code: code),
            token: nil,
            mapError: { status, _ in
                status == 401 ? .invalidOrExpiredCode : nil
            }
        )
    }

    func listDevices(token: String) async throws -> [RemoteDevice] {
        let response: DeviceListResponse = try await send(
            method: "GET",
            path: "/v1/devices",
            body: Optional<BootstrapRequest>.none,
            token: token,
            mapError: { _, _ in nil }
        )
        return response.devices
    }

    func revokeDevice(token: String, id: String) async throws {
        let encodedID = id.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? id
        let _: RevokeResponse = try await send(
            method: "POST",
            path: "/v1/devices/\(encodedID)/revoke",
            body: EmptyJSON(),
            token: token,
            mapError: { status, _ in
                status == 404 ? .notFound : nil
            }
        )
    }

    func snapshot(token: String) async throws -> RemoteSnapshot {
        try await send(
            method: "GET",
            path: "/v1/snapshot",
            body: Optional<EmptyJSON>.none,
            token: token,
            mapError: { _, _ in nil }
        )
    }

    func createTransaction(
        token: String,
        idempotencyKey: String,
        request: CreateTransactionRequest
    ) async throws -> CreateTransactionResponse {
        try await send(
            method: "POST",
            path: "/v1/transactions",
            body: request,
            token: token,
            headers: ["Idempotency-Key": idempotencyKey],
            mapError: Self.mapLedgerWriteError
        )
    }

    func correctTransaction(
        token: String,
        id: String,
        idempotencyKey: String,
        request: CorrectionRequest
    ) async throws -> CorrectionResponse {
        let encodedID = id.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? id
        return try await send(
            method: "POST",
            path: "/v1/transactions/\(encodedID)/correct",
            body: request,
            token: token,
            headers: ["Idempotency-Key": idempotencyKey],
            mapError: Self.mapLedgerWriteError
        )
    }

    func createCheckinItem(
        token: String,
        idempotencyKey: String,
        request: CreateCheckinItemRequest
    ) async throws -> CheckinItemResponse {
        try await send(
            method: "POST",
            path: "/v1/checkin-items",
            body: request,
            token: token,
            headers: ["Idempotency-Key": idempotencyKey],
            mapError: Self.mapBoardWriteError
        )
    }

    func updateCheckinItem(
        token: String,
        id: String,
        idempotencyKey: String,
        request: UpdateCheckinItemRequest
    ) async throws -> CheckinItemResponse {
        try await send(
            method: "POST",
            path: "/v1/checkin-items/\(Self.pathID(id))",
            body: request,
            token: token,
            headers: ["Idempotency-Key": idempotencyKey],
            mapError: Self.mapBoardWriteError
        )
    }

    func archiveCheckinItem(
        token: String,
        id: String,
        idempotencyKey: String
    ) async throws {
        let _: OkResponse = try await send(
            method: "POST",
            path: "/v1/checkin-items/\(Self.pathID(id))/archive",
            body: EmptyJSON(),
            token: token,
            headers: ["Idempotency-Key": idempotencyKey],
            mapError: Self.mapBoardWriteError
        )
    }

    func setCheckinTick(
        token: String,
        id: String,
        idempotencyKey: String,
        request: TickRequest
    ) async throws -> TickResponse {
        try await send(
            method: "POST",
            path: "/v1/checkin-items/\(Self.pathID(id))/ticks",
            body: request,
            token: token,
            headers: ["Idempotency-Key": idempotencyKey],
            mapError: Self.mapBoardWriteError
        )
    }

    func createSettlement(
        token: String,
        idempotencyKey: String,
        request: SettlementRequest
    ) async throws -> CreateTransactionResponse {
        try await send(
            method: "POST",
            path: "/v1/settlements",
            body: request,
            token: token,
            headers: ["Idempotency-Key": idempotencyKey],
            mapError: Self.mapBoardWriteError
        )
    }

    func createGoal(
        token: String,
        idempotencyKey: String,
        request: CreateGoalRequest
    ) async throws -> GoalMutationResponse {
        try await send(
            method: "POST",
            path: "/v1/goals",
            body: request,
            token: token,
            headers: ["Idempotency-Key": idempotencyKey],
            mapError: Self.mapBoardWriteError
        )
    }

    func archiveGoal(
        token: String,
        id: String,
        idempotencyKey: String
    ) async throws -> GoalArchiveResponse {
        try await send(
            method: "POST",
            path: "/v1/goals/\(Self.pathID(id))/archive",
            body: EmptyJSON(),
            token: token,
            headers: ["Idempotency-Key": idempotencyKey],
            mapError: Self.mapBoardWriteError
        )
    }

    private static func pathID(_ id: String) -> String {
        id.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? id
    }

    private static func mapLedgerWriteError(_ status: Int, _ code: String?) -> AuthAPIError? {
        switch status {
        case 403: return .forbidden
        case 409: return .conflict
        case 422: return .invalidRequest
        default: return nil
        }
    }

    private static func mapBoardWriteError(_ status: Int, _ code: String?) -> AuthAPIError? {
        switch status {
        case 400, 422: return .invalidRequest
        case 403: return .forbidden
        case 404: return .notFound
        case 409: return .conflict
        default: return nil
        }
    }

    private struct EmptyJSON: Encodable {}
    private struct RevokeResponse: Decodable {
        var ok: Bool?
    }

    private struct ErrorBody: Decodable {
        var error: String?
    }

    private func send<Body: Encodable, Response: Decodable>(
        method: String,
        path: String,
        body: Body?,
        token: String?,
        headers: [String: String] = [:],
        mapError: (Int, String?) -> AuthAPIError?
    ) async throws -> Response {
        let request = try makeRequest(method: method, path: path, body: body, token: token, headers: headers)
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw mapTransportError(error)
        }
        guard let http = response as? HTTPURLResponse else {
            throw AuthAPIError.serverFailure
        }
        if (200..<300).contains(http.statusCode) {
            if Response.self == RevokeResponse.self {
                return RevokeResponse(ok: true) as! Response
            }
            do {
                let decoded = try JSONDecoder().decode(Response.self, from: data)
                if let session = decoded as? AuthSessionResponse {
                    guard !session.token.isEmpty, !session.deviceID.isEmpty else {
                        throw AuthAPIError.serverFailure
                    }
                }
                return decoded
            } catch let error as AuthAPIError {
                throw error
            } catch {
                throw AuthAPIError.serverFailure
            }
        }
        let serverCode = try? JSONDecoder().decode(ErrorBody.self, from: data).error
        if let mapped = mapError(http.statusCode, serverCode) {
            throw mapped
        }
        throw mapStatus(http.statusCode)
    }

    private func makeRequest<Body: Encodable>(
        method: String,
        path: String,
        body: Body?,
        token: String?,
        headers: [String: String] = [:]
    ) throws -> URLRequest {
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            throw AuthAPIError.rejectedBaseURL
        }
        components.path = path
        guard let url = components.url else {
            throw AuthAPIError.rejectedBaseURL
        }
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: Self.requestTimeout)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        for (header, value) in headers {
            request.setValue(value, forHTTPHeaderField: header)
        }
        if method != "GET" {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            if let body {
                do {
                    request.httpBody = try JSONEncoder().encode(body)
                } catch {
                    throw AuthAPIError.invalidRequest
                }
            } else {
                request.httpBody = Data("{}".utf8)
            }
        }
        return request
    }

    private func mapTransportError(_ error: Error) -> AuthAPIError {
        let urlError = error as? URLError
        switch urlError?.code {
        case .notConnectedToInternet, .networkConnectionLost, .timedOut, .cannotFindHost,
             .cannotConnectToHost, .dnsLookupFailed, .dataNotAllowed, .internationalRoamingOff:
            return .offline
        default:
            return .serverFailure
        }
    }

    private func mapStatus(_ status: Int) -> AuthAPIError {
        switch status {
        case 400, 413, 415, 422:
            return .invalidRequest
        case 401:
            return .unauthorized
        case 403:
            return .forbidden
        case 404:
            return .notFound
        case 409:
            return .conflict
        case 429:
            return .rateLimited
        default:
            return .serverFailure
        }
    }
}
