import Foundation
import UniformTypeIdentifiers

struct DocumentItem {
    let url: URL
    let name: String
    let fileSize: Int64
    let modificationDate: Date?

    var isImage: Bool {
        guard let type = UTType(filenameExtension: url.pathExtension) else {
            return false
        }

        return type.conforms(to: .image)
    }
}

enum DocumentsStorageError: LocalizedError {
    case documentsDirectoryUnavailable

    var errorDescription: String? {
        switch self {
        case .documentsDirectoryUnavailable:
            return "Не удалось получить доступ к директории Documents."
        }
    }
}

final class DocumentsStorageService {

    private let fileManager: FileManager

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    func loadItems(sortAscending: Bool) throws -> [DocumentItem] {
        let documentsURL = try documentsDirectoryURL()

        let resourceKeys: Set<URLResourceKey> = [
            .fileSizeKey,
            .contentModificationDateKey,
            .isRegularFileKey
        ]

        let urls = try fileManager.contentsOfDirectory(
            at: documentsURL,
            includingPropertiesForKeys: Array(resourceKeys),
            options: [.skipsHiddenFiles]
        )

        return try urls.compactMap { url in
            let values = try url.resourceValues(forKeys: resourceKeys)

            guard values.isRegularFile == true else {
                return nil
            }

            return DocumentItem(
                url: url,
                name: url.lastPathComponent,
                fileSize: Int64(values.fileSize ?? 0),
                modificationDate: values.contentModificationDate
            )
        }
        .sorted { left, right in
            let comparison = left.name.localizedCaseInsensitiveCompare(right.name)

            if sortAscending {
                return comparison == .orderedAscending
            } else {
                return comparison == .orderedDescending
            }
        }
    }

    @discardableResult
    func savePhoto(
        from temporaryURL: URL,
        preferredFileExtension: String?
    ) throws -> URL {
        let documentsURL = try documentsDirectoryURL()

        let sourceExtension = temporaryURL.pathExtension
        let fileExtension = preferredFileExtension
            ?? (sourceExtension.isEmpty ? "img" : sourceExtension.lowercased())

        let fileName = "photo_\(UUID().uuidString).\(fileExtension)"
        let destinationURL = documentsURL.appendingPathComponent(fileName)

        try fileManager.copyItem(at: temporaryURL, to: destinationURL)

        return destinationURL
    }

    func delete(_ item: DocumentItem) throws {
        guard fileManager.fileExists(atPath: item.url.path) else {
            return
        }

        try fileManager.removeItem(at: item.url)
    }

    private func documentsDirectoryURL() throws -> URL {
        guard let url = fileManager.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first else {
            throw DocumentsStorageError.documentsDirectoryUnavailable
        }

        return url
    }
}
