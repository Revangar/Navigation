import Foundation

public struct Post {
    public let author: String      // никнейм автора публикации
    public let description: String // текст публикации
    public let image: String       // имя картинки из каталога Assets.xcassets
    public let likes: Int          // количество лайков
    public let views: Int          // количество просмотров
    public init(author: String, description: String, image: String, likes: Int, views: Int) {
        self.author = author
        self.description = description
        self.image = image
        self.likes = likes
        self.views = views
    }
}
