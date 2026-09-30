import UIKit

final class CoreDataPostsCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []

    let feedNavigationController = UINavigationController()
    let favoritesNavigationController = UINavigationController()

    private let repository: LikedPostRepository

    init(repository: LikedPostRepository) {
        self.repository = repository
    }

    func start() {
        feedNavigationController.tabBarItem = UITabBarItem(
            title: "Лента",
            image: UIImage(systemName: "list.bullet.rectangle"),
            tag: 0
        )

        favoritesNavigationController.tabBarItem = UITabBarItem(
            title: "Избранное",
            image: UIImage(systemName: "heart.fill"),
            tag: 2
        )

        let feedViewController = PostsListViewController(
            mode: .feed,
            repository: repository
        )

        let favoritesViewController = PostsListViewController(
            mode: .favorites,
            repository: repository
        )

        feedNavigationController.setViewControllers(
            [feedViewController],
            animated: false
        )

        favoritesNavigationController.setViewControllers(
            [favoritesViewController],
            animated: false
        )
    }
}
