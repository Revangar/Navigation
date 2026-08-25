import UIKit

final class ProfileCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []

    let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        showLogin()
    }

    private func showLogin() {
        let userService: UserService

#if DEBUG
        userService = TestUserService()
#else
        let avatar = UIImage(named: "avatar") ?? UIImage()
        let currentUser = User(
            login: "hipster",
            fullName: "Hipster Cat",
            avatar: avatar,
            status: "Waiting for something..."
        )
        userService = CurrentUserService(user: currentUser)
#endif

        let loginFactory: LoginFactory = MyLoginFactory()
        let viewController = LogInViewController(userService: userService)
        viewController.loginDelegate = loginFactory.makeLoginInspector()
        viewController.coordinator = self

        navigationController.setViewControllers([viewController], animated: false)
    }

    func showProfile(for user: User) {
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
