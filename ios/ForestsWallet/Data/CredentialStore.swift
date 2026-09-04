import Foundation
import Security

struct DeviceCredentials: Codable, Equatable, Sendable, CustomDebugStringConvertible, CustomStringConvertible {
    var token: String
    var deviceID: String
    var role: DeviceRole

    var description: String { debugDescription }

    var debugDescription: String {
        "DeviceCredentials(deviceID: \(deviceID), role: \(role.rawValue), token: <redacted>)"
    }
}

enum CredentialStoreError: Error, Equatable {
    case unavailable
    case corrupted
}

protocol CredentialStoring: Sendable {
    func load() throws -> DeviceCredentials?
    func save(_ credentials: DeviceCredentials) throws
    func clear() throws
}

final class InMemoryCredentialStore: CredentialStoring, @unchecked Sendable {
    private let lock = NSLock()
    private var credentials: DeviceCredentials?

    init(credentials: DeviceCredentials? = nil) {
        self.credentials = credentials
    }

    func load() throws -> DeviceCredentials? {
        lock.lock()
        defer { lock.unlock() }
        return credentials
    }

    func save(_ credentials: DeviceCredentials) throws {
        lock.lock()
        defer { lock.unlock() }
        self.credentials = credentials
    }

    func clear() throws {
        lock.lock()
        defer { lock.unlock() }
        credentials = nil
    }
}

struct KeychainCredentialStore: CredentialStoring {
    var service: String
    var account: String

    init(
        service: String = "com.gengdaneng.forrestswallet.credentials",
        account: String = "session"
    ) {
        self.service = service
        self.account = account
    }

    func load() throws -> DeviceCredentials? {
        var query = baseQuery()
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        if status == errSecItemNotFound {
            return nil
        }
        guard status == errSecSuccess else {
            throw CredentialStoreError.unavailable
        }
        guard let data = item as? Data else {
            try clear()
            throw CredentialStoreError.corrupted
        }
        do {
            return try JSONDecoder().decode(DeviceCredentials.self, from: data)
        } catch {
            try clear()
            throw CredentialStoreError.corrupted
        }
    }

    func save(_ credentials: DeviceCredentials) throws {
        let data: Data
        do {
            data = try JSONEncoder().encode(credentials)
        } catch {
            throw CredentialStoreError.corrupted
        }
        try clear()
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
            kSecValueData as String: data,
        ]
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw CredentialStoreError.unavailable
        }
    }

    func clear() throws {
        let status = SecItemDelete(baseQuery() as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw CredentialStoreError.unavailable
        }
    }

    private func baseQuery() -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
    }
}
