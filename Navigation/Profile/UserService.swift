import Foundation

protocol UserService {
    var user: User { get set }
    func getUser(login: String) -> User?
}

extension UserService {
    func getUser(login: String) -> User? {
        let normalizedLogin = login.trimmingCharacters(in: .whitespacesAndNewlines)
        return normalizedLogin == user.login ? user : nil
    }
}
