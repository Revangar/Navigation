import UIKit

final class SettingsCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []

    let navigationController: UINavigationController

    private let appSettings: AppSettings
    private let passwordStorage: PasswordStorage

    init(
        navigationController: UINavigationController,
        appSettings: AppSettings,
        passwordStorage: PasswordStorage
    ) {
        self.navigationController = navigationController
        self.appSettings = appSettings
        self.passwordStorage = passwordStorage
    }

    func start() {
        let viewController = SettingsViewController(appSettings: appSettings)
        viewController.onChangePassword = { [weak self] in
            self?.showChangePassword()
        }

        navigationController.setViewControllers(
            [viewController],
            animated: false
        )
    }

    private func showChangePassword() {
        let passwordViewController = PasswordViewController(
            passwordStorage: passwordStorage,
            mode: .change
        ) { [weak self] in
            self?.navigationController.dismiss(animated: true)
        }

        let modalNavigationController = UINavigationController(
            rootViewController: passwordViewController
        )

        navigationController.present(
            modalNavigationController,
            animated: true
        )
    }
}
