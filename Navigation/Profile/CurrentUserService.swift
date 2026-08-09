import Foundation

final class CurrentUserService: UserService {
    private let currentUser: User

    init(user: User) {
        self.currentUser = user
    }

    func user(for login: String) -> User? {
        let normalizedLogin = login.trimmingCharacters(in: .whitespacesAndNewlines)
        return normalizedLogin == currentUser.login ? currentUser : nil
    }
}
