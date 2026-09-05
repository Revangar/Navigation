import Foundation
import StorageService

final class FeedModel {

    private let secretWord: String
    private let posts: [Post]

    init(secretWord: String = "swift") {
        let normalizedSecretWord = secretWord.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !normalizedSecretWord.isEmpty else {
            preconditionFailure("FeedModel requires a non-empty secretWord")
        }

        self.secretWord = normalizedSecretWord
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

    func post(at index: Int) -> Result<Post, NavigationError> {
        guard posts.indices.contains(index) else {
            return .failure(.invalidPostIndex(index))
        }

        return .success(posts[index])
    }
}
