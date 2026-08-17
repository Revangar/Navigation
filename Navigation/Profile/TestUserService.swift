import UIKit

final class TestUserService: UserService {
    private let testUser: User

    init() {
        let avatar = UIImage(named: "photo1") ?? UIImage(named: "avatar") ?? UIImage()

        self.testUser = User(
            login: "test",
            fullName: "Test User",
            avatar: avatar,
            status: "Debug profile"
        )
    }

    func user(for login: String) -> User? {
        let normalizedLogin = login.trimmingCharacters(in: .whitespacesAndNewlines)
        return normalizedLogin == testUser.login ? testUser : nil
    }
}
