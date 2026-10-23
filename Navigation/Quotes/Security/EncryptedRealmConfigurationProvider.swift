import Foundation
import RealmSwift

enum EncryptedRealmError: LocalizedError {
    case missingRealmLocation
    case copiedDataDoesNotMatch

    var errorDescription: String? {
        switch self {
        case .missingRealmLocation:
            return "Не удалось определить путь к файлу Realm."
        case .copiedDataDoesNotMatch:
            return "Проверка переноса Realm не пройдена. Исходная база сохранена."
        }
    }
}

/// Opens only explicitly configured, encrypted Realms. Existing plaintext
/// databases from IOSDT 2.3 are copied and verified before the source is removed.
final class EncryptedRealmConfigurationProvider {
    private let lock = NSLock()
    private let fileManager: FileManager
    private let keyStore: RealmEncryptionKeyStore

    init(
        fileManager: FileManager = .default,
        keyStore: RealmEncryptionKeyStore = RealmEncryptionKeyStore()
    ) {
        self.fileManager = fileManager
        self.keyStore = keyStore
    }

    func configuration() throws -> Realm.Configuration {
        lock.lock()
        defer { lock.unlock() }

        guard let legacyURL = Realm.Configuration.defaultConfiguration.fileURL else {
            throw EncryptedRealmError.missingRealmLocation
        }

        let encryptedURL = legacyURL.deletingLastPathComponent()
            .appendingPathComponent("chuck-norris-quotes.realm")

        let encryptedExists = fileManager.fileExists(atPath: encryptedURL.path)
        let key = try keyStore.key(encryptedDatabaseExists: encryptedExists)

        let configuration = Realm.Configuration(
            fileURL: encryptedURL,
            encryptionKey: key
        )

        if encryptedExists {
            // Key loss, corruption, or a wrong key must be surfaced as an error.
            // Never silently create a blank replacement database.
            _ = try Realm(configuration: configuration)
        } else if fileManager.fileExists(atPath: legacyURL.path) {
            try migratePlaintextRealm(
                from: legacyURL,
                to: encryptedURL,
                key: key
            )
        }

        // Cleanup may be retried after a crash. Never touch the plaintext
        // database or its sidecars unless the encrypted file is installed.
        if fileManager.fileExists(atPath: encryptedURL.path) {
            try removeLegacyRealmFiles(at: legacyURL)
        }

        return configuration
    }

    private func migratePlaintextRealm(
        from legacyURL: URL,
        to encryptedURL: URL,
        key: Data
    ) throws {
        let stagingURL = encryptedURL.deletingLastPathComponent()
            .appendingPathComponent("encrypted-\(UUID().uuidString).realm")

        do {
            let counts = try copyAndGetCounts(
                from: legacyURL,
                to: stagingURL,
                key: key
            )

            let stagingConfiguration = Realm.Configuration(
                fileURL: stagingURL,
                encryptionKey: key
            )

            let copiedCounts = try objectCounts(
                configuration: stagingConfiguration
            )

            guard counts == copiedCounts else {
                throw EncryptedRealmError.copiedDataDoesNotMatch
            }

            // Same filesystem: the final encrypted file is installed only
            // after it has been decrypted and its objects checked.
            try fileManager.moveItem(at: stagingURL, to: encryptedURL)
        } catch {
            try? fileManager.removeItem(at: stagingURL)
            throw error
        }
    }

    private func copyAndGetCounts(
        from legacyURL: URL,
        to stagingURL: URL,
        key: Data
    ) throws -> [Int] {
        var config = Realm.Configuration.defaultConfiguration
        config.fileURL = legacyURL
        config.encryptionKey = nil

        let original = try Realm(configuration: config)

        let counts = [
            original.objects(QuoteObject.self).count,
            original.objects(QuoteCategoryObject.self).count
        ]

        try original.writeCopy(
            toFile: stagingURL,
            encryptionKey: key
        )

        return counts
    }

    private func objectCounts(
        configuration: Realm.Configuration
    ) throws -> [Int] {
        let realm = try Realm(configuration: configuration)

        return [
            realm.objects(QuoteObject.self).count,
            realm.objects(QuoteCategoryObject.self).count
        ]
    }

    private func removeLegacyRealmFiles(at url: URL) throws {
        // Never delete the old database until the new encrypted file opens.
        if fileManager.fileExists(atPath: url.path) {
            try fileManager.removeItem(at: url)
        }

        for suffix in [".lock", ".note", ".management"] {
            let auxiliaryURL = URL(fileURLWithPath: url.path + suffix)
            if fileManager.fileExists(atPath: auxiliaryURL.path) {
                try fileManager.removeItem(at: auxiliaryURL)
            }
        }
    }
}
