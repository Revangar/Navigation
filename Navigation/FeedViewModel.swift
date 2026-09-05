import Foundation
import StorageService

final class FeedViewModel {

    enum GuessState {
        case idle
        case empty
        case correct
        case incorrect
    }

    private let model: FeedModel

    private(set) var state: GuessState = .idle {
        didSet {
            onStateChanged?(state)
        }
    }

    var onStateChanged: ((GuessState) -> Void)?

    init(model: FeedModel) {
        self.model = model
    }

    func checkGuess(_ word: String?) {
        let normalizedWord = word?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !normalizedWord.isEmpty else {
            state = .empty
            return
        }

        state = model.check(word: normalizedWord) ? .correct : .incorrect
    }

    func post(at index: Int) -> Post? {
        switch model.post(at: index) {
        case .success(let post):
            return post
        case .failure(let error):
            print("[Feed] \(error.localizedDescription)")
            return nil
        }
    }
}
