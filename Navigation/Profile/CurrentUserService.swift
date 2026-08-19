final class CurrentUserService: UserService {
    var user: User

    init(user: User) {
        self.user = user
    }
}
