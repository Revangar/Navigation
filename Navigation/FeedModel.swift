import Foundation
import StorageService

final class FeedModel {

    private let secretWord: String
    private let posts: [Post]

    init(secretWord: String = "swift") {
        self.secretWord = secretWord
        self.posts = [
            Post(
                author: "Первый автор",
                description: "Описание первого поста",
                image: "post1",
                likes: 100,
                views: 150
            ),
            Post(
                author: "Второй автор",
                description: "Описание второго поста",
                image: "post2",
                likes: 200,
                views: 250
            )
        ]
    }

    func check(word: String) -> Bool {
        word.caseInsensitiveCompare(secretWord) == .orderedSame
    }

    func post(at index: Int) -> Post? {
        guard posts.indices.contains(index) else { return nil }
        return posts[index]
    }
}
