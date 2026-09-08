import Foundation

enum NavigationError: Error, LocalizedError {
    case emptyLogin
    case emptyPassword
    case authenticationUnavailable
    case invalidCredentials
    case userNotFound(login: String)
    case invalidPostIndex(Int)

    var errorDescription: String? {
        switch self {
        case .emptyLogin:
            return "Введите логин."
        case .emptyPassword:
            return "Введите пароль."
        case .authenticationUnavailable:
            return "Сервис авторизации временно недоступен."
        case .invalidCredentials:
            return "Неверный логин или пароль."
        case .userNotFound(let login):
            return "Пользователь \(login) не найден."
        case .invalidPostIndex:
            return "Не удалось открыть выбранный пост."
        }
    }
}
