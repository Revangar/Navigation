import CoreData
import Foundation
import StorageService

enum LikedPostSaveResult {
    case saved
    case alreadySaved
}

protocol LikedPostRepository: AnyObject {
    func save(
        _ post: Post,
        completion: @escaping (Result<LikedPostSaveResult, Error>) -> Void
    )

    func delete(
        _ post: Post,
        completion: @escaping (Result<Bool, Error>) -> Void
    )

    func makeFetchedResultsController(
        author: String?
    ) throws -> NSFetchedResultsController<LikedPostEntity>
}

final class CoreDataPostRepository: LikedPostRepository {

    private let container: NSPersistentContainer
    private let backgroundContext: NSManagedObjectContext
    private let persistentStoreError: Error?

    init(container: NSPersistentContainer = NSPersistentContainer(name: "LikedPosts")) {
        self.container = container

        // Finish store loading before creating a write context.
        container.persistentStoreDescriptions.forEach {
            $0.shouldAddStoreAsynchronously = false
            $0.shouldMigrateStoreAutomatically = true
            $0.shouldInferMappingModelAutomatically = true
        }

        var loadError: Error?
        container.loadPersistentStores { _, error in
            if let error {
                loadError = error
            }
        }

        persistentStoreError = loadError

        let writer = container.newBackgroundContext()
        writer.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        backgroundContext = writer

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
    }

    func save(
        _ post: Post,
        completion: @escaping (Result<LikedPostSaveResult, Error>) -> Void
    ) {
        if let persistentStoreError {
            finish(.failure(persistentStoreError), completion: completion)
            return
        }

        backgroundContext.perform { [self] in
            do {
                let request = request(for: post)
                let isDuplicate = try !backgroundContext.fetch(request).isEmpty

                guard !isDuplicate else {
                    finish(.success(.alreadySaved), completion: completion)
                    return
                }

                let entity = LikedPostEntity(context: backgroundContext)
                entity.identifier = makeIdentifier(for: post)
                entity.author = post.author
                entity.postDescription = post.description
                entity.image = post.image
                entity.likes = Int64(post.likes)
                entity.views = Int64(post.views)
                entity.savedAt = Date()

                try backgroundContext.save()
                finish(.success(.saved), completion: completion)
            } catch {
                backgroundContext.rollback()
                finish(.failure(error), completion: completion)
            }
        }
    }

    func delete(
        _ post: Post,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        if let persistentStoreError {
            finish(.failure(persistentStoreError), completion: completion)
            return
        }

        backgroundContext.perform { [self] in
            do {
                let request = request(for: post)
                request.fetchLimit = 1

                guard let object = try backgroundContext.fetch(request).first else {
                    finish(.success(false), completion: completion)
                    return
                }

                backgroundContext.delete(object)
                try backgroundContext.save()

                finish(.success(true), completion: completion)
            } catch {
                backgroundContext.rollback()
                finish(.failure(error), completion: completion)
            }
        }
    }

    // A fresh controller per filter avoids shared fetch state and cache
    // invalidation. The FRC is tied to viewContext (main queue only).
    func makeFetchedResultsController(
        author: String?
    ) throws -> NSFetchedResultsController<LikedPostEntity> {
        try ensurePersistentStoreLoaded()

        let request = NSFetchRequest<LikedPostEntity>(
            entityName: "LikedPostEntity"
        )
        request.sortDescriptors = [
            NSSortDescriptor(key: "savedAt", ascending: false),
            NSSortDescriptor(key: "identifier", ascending: true)
        ]
        request.fetchBatchSize = 25

        if let author, !author.isEmpty {
            request.predicate = NSPredicate(
                format: "author CONTAINS[c] %@",
                author
            )
        }

        return NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: container.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
    }

    private func request(for post: Post) -> NSFetchRequest<LikedPostEntity> {
        let request = NSFetchRequest<LikedPostEntity>(
            entityName: "LikedPostEntity"
        )
        request.fetchLimit = 1
        request.predicate = NSPredicate(
            format: "identifier == %@",
            makeIdentifier(for: post)
        )
        return request
    }

    private func makeIdentifier(for post: Post) -> String {
        [
            post.author,
            post.description,
            post.image
        ]
        .joined(separator: "|")
    }

    private func ensurePersistentStoreLoaded() throws {
        if let persistentStoreError {
            throw persistentStoreError
        }
    }

    private func finish<T>(
        _ result: Result<T, Error>,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        DispatchQueue.main.async {
            completion(result)
        }
    }
}
