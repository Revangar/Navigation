import CoreData
import Foundation
import StorageService

enum LikedPostSaveResult {
    case saved
    case alreadySaved
}

protocol LikedPostRepository {
    func save(_ post: Post) throws -> LikedPostSaveResult
    func fetchLikedPosts() throws -> [Post]
}

final class CoreDataPostRepository: LikedPostRepository {

    private let container: NSPersistentContainer
    private var persistentStoreError: Error?

    init(container: NSPersistentContainer = NSPersistentContainer(name: "LikedPosts")) {
        self.container = container

        container.persistentStoreDescriptions.first?
            .shouldAddStoreAsynchronously = false

        container.loadPersistentStores { [weak self] _, error in
            self?.persistentStoreError = error
        }

        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    func save(_ post: Post) throws -> LikedPostSaveResult {
        try ensurePersistentStoreLoaded()

        let context = container.viewContext
        let identifier = makeIdentifier(for: post)

        let request = NSFetchRequest<LikedPostEntity>(
            entityName: "LikedPostEntity"
        )
        request.fetchLimit = 1
        request.predicate = NSPredicate(
            format: "identifier == %@",
            identifier
        )

        if try context.fetch(request).first != nil {
            return .alreadySaved
        }

        let entity = LikedPostEntity(context: context)
        entity.identifier = identifier
        entity.author = post.author
        entity.postDescription = post.description
        entity.image = post.image
        entity.likes = Int64(post.likes)
        entity.views = Int64(post.views)
        entity.savedAt = Date()

        try context.save()

        return .saved
    }

    func fetchLikedPosts() throws -> [Post] {
        try ensurePersistentStoreLoaded()

        let request = NSFetchRequest<LikedPostEntity>(
            entityName: "LikedPostEntity"
        )
        request.sortDescriptors = [
            NSSortDescriptor(
                key: "savedAt",
                ascending: false
            )
        ]

        return try container.viewContext
            .fetch(request)
            .map { $0.makePost() }
    }

    private func ensurePersistentStoreLoaded() throws {
        if let persistentStoreError {
            throw persistentStoreError
        }
    }

    private func makeIdentifier(for post: Post) -> String {
        [
            post.author,
            post.description,
            post.image
        ]
        .joined(separator: "|")
    }
}
