import UIKit
import AVFoundation

final class AudioRecorderViewController: UIViewController {

    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?

    private lazy var recordingURL: URL = {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documents.appendingPathComponent("NavigationVoiceRecording.m4a")
    }()

    private let instructionLabel: UILabel = {
        let label = UILabel()
        label.text = "Запишите фразу:\n«Поздравляем, вы завершили модуль промышленной разработки!»"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        return label
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Готово к записи"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        return label
    }()

    private lazy var recordButton = CustomButton(
        title: "Запись",
        backgroundColor: .systemRed
    ) { [weak self] in
        self?.recordButtonTapped()
    }

    private lazy var playbackButton = CustomButton(
        title: "Воспроизведение",
        backgroundColor: .systemBlue
    ) { [weak self] in
        self?.playRecording()
    }

    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            instructionLabel,
            statusLabel,
            recordButton,
            playbackButton
        ])
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Recorder"
        view.backgroundColor = .systemBackground
        setupUI()
        playbackButton.isEnabled = FileManager.default.fileExists(atPath: recordingURL.path)
        playbackButton.alpha = playbackButton.isEnabled ? 1 : 0.45
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        audioRecorder?.stop()
        audioPlayer?.stop()
    }

    private func setupUI() {
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            recordButton.heightAnchor.constraint(equalToConstant: 52),
            playbackButton.heightAnchor.constraint(equalToConstant: 52)
        ])
    }

    private func recordButtonTapped() {
        if audioRecorder?.isRecording == true {
            stopRecording()
            return
        }

        requestMicrophonePermission { [weak self] granted in
            guard let self else { return }

            DispatchQueue.main.async {
                if granted {
                    self.startRecording()
                } else {
                    self.presentMicrophoneDeniedAlert()
                }
            }
        }
    }

    private func requestMicrophonePermission(completion: @escaping (Bool) -> Void) {
        if #available(iOS 17.0, *) {
            switch AVAudioApplication.shared.recordPermission {
            case .granted:
                completion(true)
            case .denied:
                completion(false)
            case .undetermined:
                AVAudioApplication.requestRecordPermission(completionHandler: completion)
            @unknown default:
                completion(false)
            }
        } else {
            let session = AVAudioSession.sharedInstance()
            switch session.recordPermission {
            case .granted:
                completion(true)
            case .denied:
                completion(false)
            case .undetermined:
                session.requestRecordPermission(completion)
            @unknown default:
                completion(false)
            }
        }
    }

    private func startRecording() {
        do {
            audioPlayer?.stop()

            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try session.setActive(true)

            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44_100.0,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]

            let recorder = try AVAudioRecorder(url: recordingURL, settings: settings)
            recorder.delegate = self
            recorder.prepareToRecord()
            recorder.record()
            audioRecorder = recorder

            recordButton.setTitle("Стоп записи", for: .normal)
            recordButton.backgroundColor = .systemOrange
            playbackButton.isEnabled = false
            playbackButton.alpha = 0.45
            statusLabel.text = "Идёт запись…"
        } catch {
            statusLabel.text = "Не удалось начать запись: \(error.localizedDescription)"
        }
    }

    private func stopRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
        recordButton.setTitle("Запись", for: .normal)
        recordButton.backgroundColor = .systemRed

        let exists = FileManager.default.fileExists(atPath: recordingURL.path)
        playbackButton.isEnabled = exists
        playbackButton.alpha = exists ? 1 : 0.45
        statusLabel.text = exists ? "Запись сохранена" : "Файл записи не создан"
    }

    private func playRecording() {
        guard FileManager.default.fileExists(atPath: recordingURL.path) else {
            statusLabel.text = "Сначала сделайте запись"
            return
        }

        do {
            audioRecorder?.stop()

            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try session.setActive(true)

            let player = try AVAudioPlayer(contentsOf: recordingURL)
            player.delegate = self
            player.prepareToPlay()
            player.play()
            audioPlayer = player
            statusLabel.text = "Воспроизведение записи"
        } catch {
            statusLabel.text = "Не удалось воспроизвести запись: \(error.localizedDescription)"
        }
    }

    private func presentMicrophoneDeniedAlert() {
        let alert = UIAlertController(
            title: "Нет доступа к микрофону",
            message: "Разрешите доступ к микрофону в настройках, чтобы записать аудио.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Настройки", style: .default) { _ in
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(url)
        })
        present(alert, animated: true)
    }
}

extension AudioRecorderViewController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            statusLabel.text = "Запись завершилась с ошибкой"
        }
    }
}

extension AudioRecorderViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        statusLabel.text = flag ? "Воспроизведение завершено" : "Воспроизведение прервано"
    }
}
