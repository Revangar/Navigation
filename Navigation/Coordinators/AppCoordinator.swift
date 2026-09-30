import UIKit

final class AppCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []

    private let window: UIWindow

    init(window: UIWindow) {
        self.window = window
    }

    func start() {
        let likedPostsRepository = CoreDataPostRepository()

        let postsCoordinator = CoreDataPostsCoordinator(
            repository: likedPostsRepository
        )

        let profileNavigationController = UINavigationController()
        profileNavigationController.tabBarItem = UITabBarItem(
            title: "Профиль",
            image: UIImage(systemName: "person.crop.circle"),
            tag: 1
        )

        let profileCoordinator = ProfileCoordinator(
            navigationController: profileNavigationController
        )

        childCoordinators = [
            postsCoordinator,
            profileCoordinator
        ]

        postsCoordinator.start()
        profileCoordinator.start()

        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [
            postsCoordinator.feedNavigationController,
            profileNavigationController,
            postsCoordinator.favoritesNavigationController
        ]
        tabBarController.selectedIndex = 0

        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
}
