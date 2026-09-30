import CoreData
import Foundation
import StorageService

@objc(LikedPostEntity)
final class LikedPostEntity: NSManagedObject {
    @NSManaged var identifier: String
    @NSManaged var author: String
    @NSManaged var postDescription: String
    @NSManaged var image: String
    @NSManaged var likes: Int64
    @NSManaged var views: Int64
    @NSManaged var savedAt: Date

    func makePost() -> Post {
        Post(
            author: author,
            description: postDescription,
            image: image,
            likes: Int(likes),
            views: Int(views)
        )
    }
}
