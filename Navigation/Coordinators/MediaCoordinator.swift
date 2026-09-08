import UIKit

final class MediaCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []

    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let viewController = MediaHomeViewController()
        viewController.coordinator = self
        navigationController.setViewControllers([viewController], animated: false)
    }
}

extension MediaCoordinator: MediaHomeViewControllerCoordinator {
    func showAudioPlayer() {
        navigationController.pushViewController(AudioPlayerViewController(), animated: true)
    }

    func showYouTubePlayer() {
        navigationController.pushViewController(YouTubeViewController(), animated: true)
    }

    func showAudioRecorder() {
        navigationController.pushViewController(AudioRecorderViewController(), animated: true)
    }
}
