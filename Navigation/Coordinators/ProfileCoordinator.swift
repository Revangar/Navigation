import UIKit

final class ProfileCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []

    let navigationController: UINavigationController

    private var loginInspector: LoginInspector?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        showLogin()
    }

    private func showLogin() {
        let loginFactory: LoginFactory = MyLoginFactory()
        let inspector = loginFactory.makeLoginInspector()
        loginInspector = inspector

        let viewController = LogInViewController(delegate: inspector)
        viewController.coordinator = self

        navigationController.setViewControllers([viewController], animated: false)
    }

    func showProfile(email: String) {
        let avatar = UIImage(named: "avatar") ?? UIImage()
        let displayName = email
            .split(separator: "@")
            .first
            .map(String.init) ?? email

        let user = User(
            login: email,
            fullName: displayName,
            avatar: avatar,
            status: "Firebase user"
        )

        let viewController = ProfileViewController(user: user)
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: true)
    }

    func showPhotos() {
        let viewController = PhotosViewController()
        navigationController.pushViewController(viewController, animated: true)
    }
}

extension ProfileCoordinator: LogInViewControllerCoordinator {}
extension ProfileCoordinator: ProfileViewControllerCoordinator {}
