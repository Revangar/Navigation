import UIKit

final class QuotesCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []

    let tabBarController = UITabBarController()

    private let apiService: ChuckNorrisAPIServiceProtocol
    private let repository: QuoteRepository

    init(
        apiService: ChuckNorrisAPIServiceProtocol = ChuckNorrisAPIService(),
        repository: QuoteRepository = RealmQuoteRepository()
    ) {
        self.apiService = apiService
        self.repository = repository
    }

    func start() {
        let randomNavigationController = UINavigationController()
        randomNavigationController.tabBarItem = UITabBarItem(
            title: "Загрузить",
            image: UIImage(systemName: "arrow.down.circle"),
            tag: 0
        )

        let quotesNavigationController = UINavigationController()
        quotesNavigationController.tabBarItem = UITabBarItem(
            title: "Цитаты",
            image: UIImage(systemName: "quote.bubble"),
            tag: 1
        )

        let categoriesNavigationController = UINavigationController()
        categoriesNavigationController.tabBarItem = UITabBarItem(
            title: "Категории",
            image: UIImage(systemName: "square.grid.2x2"),
            tag: 2
        )

        let randomViewController = RandomQuoteViewController(
            apiService: apiService,
            repository: repository
        )

        let quotesViewController = QuotesListViewController(
            repository: repository
        )

        let categoriesViewController = CategoriesViewController(
            repository: repository
        )
        categoriesViewController.onSelectCategory = {
            [weak categoriesNavigationController, repository] category in

            let viewController = CategoryQuotesViewController(
                category: category,
                repository: repository
            )
            categoriesNavigationController?.pushViewController(
                viewController,
                animated: true
            )
        }

        randomNavigationController.setViewControllers(
            [randomViewController],
            animated: false
        )
        quotesNavigationController.setViewControllers(
            [quotesViewController],
            animated: false
        )
        categoriesNavigationController.setViewControllers(
            [categoriesViewController],
            animated: false
        )

        tabBarController.viewControllers = [
            randomNavigationController,
            quotesNavigationController,
            categoriesNavigationController
        ]
        tabBarController.selectedIndex = 0
    }
}
