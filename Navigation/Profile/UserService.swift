protocol UserService {
    func user(for login: String) -> User?
}
