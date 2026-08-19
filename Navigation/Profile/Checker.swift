final class Checker {
    static let shared = Checker()

    private let login: String
    private let password = "12345"

    private init() {
#if DEBUG
        login = "test"
#else
        login = "hipster"
#endif
    }

    func check(login: String, password: String) -> Bool {
        login == self.login && password == self.password
    }
}
