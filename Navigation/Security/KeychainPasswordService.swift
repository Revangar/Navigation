import Foundation
import Security

protocol PasswordStorage: AnyObject {
    var hasPassword: Bool { get }
    func save(password: String) throws
    func matches(password: String) -> Bool
}

enum KeychainPasswordError: LocalizedError {
    case encodingFailed
    case unexpectedStatus(OSStatus)

    var errorDescription: String? {
        switch self {
        case .encodingFailed:
            return "Не удалось подготовить пароль для сохранения."
        case .unexpectedStatus(let status):
            return "Ошибка Keychain: \(status)."
        }
    }
}

final class KeychainPasswordService: PasswordStorage {

    private let service: String
    private let account = "documents.access.password"

    init(service: String = Bundle.main.bundleIdentifier ?? "Navigation") {
        self.service = service
    }

    var hasPassword: Bool {
        password() != nil
    }

    func save(password: String) throws {
        guard let data = password.data(using: .utf8) else {
            throw KeychainPasswordError.encodingFailed
        }

        let baseQuery = query()
        let attributesToUpdate: [String: Any] = [
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        let updateStatus = SecItemUpdate(
            baseQuery as CFDictionary,
            attributesToUpdate as CFDictionary
        )

        if updateStatus == errSecSuccess {
            return
        }

        guard updateStatus == errSecItemNotFound else {
            throw KeychainPasswordError.unexpectedStatus(updateStatus)
        }

        var addQuery = baseQuery
        addQuery.merge(attributesToUpdate) { _, newValue in newValue }

        let addStatus = SecItemAdd(addQuery as CFDictionary, nil)

        guard addStatus == errSecSuccess else {
            throw KeychainPasswordError.unexpectedStatus(addStatus)
        }
    }

    func matches(password: String) -> Bool {
        self.password() == password
    }

    private func password() -> String? {
        var lookupQuery = query()
        lookupQuery[kSecReturnData as String] = true
        lookupQuery[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: CFTypeRef?
        let status = SecItemCopyMatching(
            lookupQuery as CFDictionary,
            &result
        )

        guard
            status == errSecSuccess,
            let data = result as? Data
        else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    private func query() -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
    }
}
