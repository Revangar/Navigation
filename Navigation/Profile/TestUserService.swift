import UIKit

final class TestUserService: UserService {
    var user: User

    init(user: User? = nil) {
        if let user {
            self.user = user
            return
        }

        let avatar = UIImage(named: "photo1") ?? UIImage(named: "avatar") ?? UIImage()
        self.user = User(
            login: "test",
            fullName: "Test User",
            avatar: avatar,
            status: "Debug profile"
        )
    }
}
