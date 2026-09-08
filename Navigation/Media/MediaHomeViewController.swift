import UIKit

protocol MediaHomeViewControllerCoordinator: AnyObject {
    func showAudioPlayer()
    func showYouTubePlayer()
    func showAudioRecorder()
}

final class MediaHomeViewController: UIViewController {

    weak var coordinator: MediaHomeViewControllerCoordinator?

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Мультимедиа"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Аудио, YouTube и запись с микрофона"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var audioButton = CustomButton(
        title: "Аудиоплеер",
        backgroundColor: .systemBlue
    ) { [weak self] in
        self?.coordinator?.showAudioPlayer()
    }

    private lazy var videoButton = CustomButton(
        title: "YouTube-видео",
        backgroundColor: .systemRed
    ) { [weak self] in
        self?.coordinator?.showYouTubePlayer()
    }

    private lazy var recorderButton = CustomButton(
        title: "Запись голоса",
        backgroundColor: .systemIndigo
    ) { [weak self] in
        self?.coordinator?.showAudioRecorder()
    }

    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            subtitleLabel,
            audioButton,
            videoButton,
            recorderButton
        ])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Media"
        view.backgroundColor = .systemBackground
        setupUI()
    }

    private func setupUI() {
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            audioButton.heightAnchor.constraint(equalToConstant: 52),
            videoButton.heightAnchor.constraint(equalToConstant: 52),
            recorderButton.heightAnchor.constraint(equalToConstant: 52)
        ])
    }
}
