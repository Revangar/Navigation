import Foundation
import Security

enum RealmEncryptionKeyError: LocalizedError {
    case invalidStoredKey
    case secureRandomGenerationFailed(OSStatus)
    case keychainFailure(OSStatus)
    case missingKeyForExistingDatabase

    var errorDescription: String? {
        switch self {
        case .invalidStoredKey:
            return "Ключ шифрования Realm в Keychain имеет неверный размер."
        case .secureRandomGenerationFailed(let status):
            return "Не удалось создать криптографически стойкий ключ Realm (\(status))."
        case .keychainFailure(let status):
            return "Keychain недоступен для ключа Realm (\(status))."
        case .missingKeyForExistingDatabase:
            return "Зашифрованная база Realm существует, но её ключ отсутствует в Keychain. Создавать новый ключ нельзя: данные станут недоступны."
        }
    }
}

/// Independent Keychain entry: never reads or changes the app's login password.
final class RealmEncryptionKeyStore {
    private let keyLength = 64
    private let service = (Bundle.main.bundleIdentifier ?? "Navigation") + ".realm.encryption"
    private let account = "chuck-norris-quotes-key"

    func key(encryptedDatabaseExists: Bool) throws -> Data {
        if let existing = try loadKey() {
            guard existing.count == keyLength else {
                throw RealmEncryptionKeyError.invalidStoredKey
            }
            return existing
        }

        guard !encryptedDatabaseExists else {
            throw RealmEncryptionKeyError.missingKeyForExistingDatabase
        }

        var newKey = Data(count: keyLength)
        let status = newKey.withUnsafeMutableBytes { buffer -> OSStatus in
            guard let baseAddress = buffer.baseAddress else {
                return errSecAllocate
            }
            return SecRandomCopyBytes(kSecRandomDefault, keyLength, baseAddress)
        }

        guard status == errSecSuccess else {
            throw RealmEncryptionKeyError.secureRandomGenerationFailed(status)
        }

        var attributes = baseQuery()
        attributes[kSecValueData as String] = newKey
        attributes[kSecAttrAccessible as String] =
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly

        let addStatus = SecItemAdd(attributes as CFDictionary, nil)

        if addStatus == errSecDuplicateItem {
            // Another caller created the key. Never overwrite it with a new one.
            if let existing = try loadKey(), existing.count == keyLength {
                return existing
            }
            throw RealmEncryptionKeyError.invalidStoredKey
        }

        guard addStatus == errSecSuccess else {
            throw RealmEncryptionKeyError.keychainFailure(addStatus)
        }

        return newKey
    }

    private func loadKey() throws -> Data? {
        var query = baseQuery()
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecItemNotFound {
            return nil
        }

        guard status == errSecSuccess else {
            throw RealmEncryptionKeyError.keychainFailure(status)
        }

        guard let data = result as? Data else {
            throw RealmEncryptionKeyError.invalidStoredKey
        }

        return data
    }

    private func baseQuery() -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
    }
}
