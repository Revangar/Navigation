import UIKit
import AVFoundation

final class AudioPlayerViewController: UIViewController {

    private struct Track {
        let title: String
        let resourceName: String
    }

    private let tracks: [Track] = [
        Track(title: "Aurora", resourceName: "MediaTrack1"),
        Track(title: "Pulse", resourceName: "MediaTrack2"),
        Track(title: "Orbit", resourceName: "MediaTrack3"),
        Track(title: "Neon", resourceName: "MediaTrack4"),
        Track(title: "Horizon", resourceName: "MediaTrack5")
    ]

    private var player: AVAudioPlayer?
    private var currentTrackIndex = 0
    private var trackButtons: [CustomButton] = []

    private let trackTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let stateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 15)
        return label
    }()

    private lazy var playPauseButton = CustomButton(
        title: "Play",
        backgroundColor: .systemGreen
    ) { [weak self] in
        self?.togglePlayPause()
    }

    private lazy var stopButton = CustomButton(
        title: "Stop",
        backgroundColor: .systemRed
    ) { [weak self] in
        self?.stopPlayback()
    }

    private let trackButtonsStack = UIStackView()

    private lazy var controlsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [playPauseButton, stopButton])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 12
        return stack
    }()

    private lazy var mainStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            trackTitleLabel,
            stateLabel,
            controlsStack,
            trackButtonsStack
        ])
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Audio"
        view.backgroundColor = .systemBackground

        configureTrackButtons()
        setupUI()
        configureAudioSession()
        loadTrack(at: 0)
    }

    private func configureTrackButtons() {
        trackButtonsStack.axis = .vertical
        trackButtonsStack.spacing = 8
        trackButtonsStack.distribution = .fillEqually

        for index in tracks.indices {
            let button = CustomButton(
                title: "\(index + 1). \(tracks[index].title)",
                backgroundColor: .systemGray
            ) { [weak self] in
                self?.selectTrack(at: index)
            }
            trackButtons.append(button)
            trackButtonsStack.addArrangedSubview(button)
        }
    }

    private func setupUI() {
        view.addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            mainStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            playPauseButton.heightAnchor.constraint(equalToConstant: 52),
            stopButton.heightAnchor.constraint(equalToConstant: 52)
        ])

        trackButtons.forEach {
            $0.heightAnchor.constraint(equalToConstant: 44).isActive = true
        }
    }

    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
        } catch {
            stateLabel.text = "Не удалось настроить аудиосессию: \(error.localizedDescription)"
        }
    }

    private func loadTrack(at index: Int) {
        guard tracks.indices.contains(index) else { return }

        let track = tracks[index]
        guard let url = Bundle.main.url(forResource: track.resourceName, withExtension: "wav") else {
            stateLabel.text = "Файл \(track.resourceName).wav не найден"
            player = nil
            updateUI()
            return
        }

        do {
            let newPlayer = try AVAudioPlayer(contentsOf: url)
            newPlayer.delegate = self
            newPlayer.prepareToPlay()
            player = newPlayer
            currentTrackIndex = index
            stateLabel.text = "Готово к воспроизведению"
            updateUI()
        } catch {
            player = nil
            stateLabel.text = "Ошибка аудио: \(error.localizedDescription)"
            updateUI()
        }
    }

    private func selectTrack(at index: Int) {
        let shouldContinuePlaying = player?.isPlaying == true
        player?.stop()
        loadTrack(at: index)

        if shouldContinuePlaying {
            player?.play()
            stateLabel.text = "Воспроизведение"
            updateUI()
        }
    }

    private func togglePlayPause() {
        guard let player else { return }

        if player.isPlaying {
            player.pause()
            stateLabel.text = "Пауза"
        } else {
            if player.currentTime >= player.duration {
                player.currentTime = 0
            }
            player.play()
            stateLabel.text = "Воспроизведение"
        }

        updateUI()
    }

    private func stopPlayback() {
        guard let player else { return }
        player.stop()
        player.currentTime = 0
        player.prepareToPlay()
        stateLabel.text = "Остановлено, позиция 00:00"
        updateUI()
    }

    private func updateUI() {
        trackTitleLabel.text = "Сейчас: \(tracks[currentTrackIndex].title)"
        playPauseButton.setTitle(player?.isPlaying == true ? "Pause" : "Play", for: .normal)

        for (index, button) in trackButtons.enumerated() {
            button.backgroundColor = index == currentTrackIndex ? .systemBlue : .systemGray
        }
    }
}

extension AudioPlayerViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        player.currentTime = 0
        stateLabel.text = flag ? "Трек завершён" : "Воспроизведение прервано"
        updateUI()
    }
}
