import Foundation

extension Notification.Name {
    static let feedModelDidCheckWord = Notification.Name("FeedModel.didCheckWord")
}

final class FeedModel {

    enum UserInfoKey {
        static let isCorrect = "isCorrect"
    }

    private let secretWord: String

    init(secretWord: String = "swift") {
        self.secretWord = secretWord
    }

    func check(word: String) {
        let normalizedWord = word.trimmingCharacters(in: .whitespacesAndNewlines)
        let isCorrect = normalizedWord.caseInsensitiveCompare(secretWord) == .orderedSame

        NotificationCenter.default.post(
            name: .feedModelDidCheckWord,
            object: self,
            userInfo: [UserInfoKey.isCorrect: isCorrect]
        )
    }
}
