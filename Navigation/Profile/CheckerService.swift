import Foundation
import FirebaseAuth
import FirebaseCore

protocol CheckerServiceProtocol: AnyObject {
    func checkCredentials(
        email: String,
        password: String,
        completion: @escaping (Result<Void, Error>) -> Void
    )

    func signUp(
        email: String,
        password: String,
        completion: @escaping (Result<Void, Error>) -> Void
    )
}

enum CheckerServiceError: LocalizedError {
    case firebaseNotConfigured

    var errorDescription: String? {
        switch self {
        case .firebaseNotConfigured:
            return "Firebase не настроен. Добавьте GoogleService-Info.plist в target приложения."
        }
    }
}

final class CheckerService: CheckerServiceProtocol {

    func checkCredentials(
        email: String,
        password: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard FirebaseApp.app() != nil else {
            completion(.failure(CheckerServiceError.firebaseNotConfigured))
            return
        }

        Auth.auth().signIn(withEmail: email, password: password) { _, error in
            if let error {
                completion(.failure(error))
                return
            }

            completion(.success(()))
        }
    }

    func signUp(
        email: String,
        password: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard FirebaseApp.app() != nil else {
            completion(.failure(CheckerServiceError.firebaseNotConfigured))
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { _, error in
            if let error {
                completion(.failure(error))
                return
            }

            completion(.success(()))
        }
    }

    func signOut() throws {
        guard FirebaseApp.app() != nil else { return }
        try Auth.auth().signOut()
    }
}
