//
//  PhotosViewController.swift
//  Navigation
//
//  Created by Revangar on 05.07.2025.
//

import UIKit
import iOSIntPackage

final class PhotosViewController: UIViewController {

    private struct BenchmarkCase {
        let name: String
        let sourceImages: [UIImage]
        let filter: ColorFilter
        let qos: QualityOfService
    }

    // MARK: - Data
    private let sourcePhotos: [UIImage] = (1...20).compactMap { UIImage(named: "photo\($0)") }
    private var photos: [UIImage] = []
    private var benchmarkResults: [String] = []

    // MARK: - Dependencies
    private let imageProcessor = ImageProcessor()

    // MARK: - UI
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(
            PhotosCollectionViewCell.self,
            forCellWithReuseIdentifier: PhotosCollectionViewCell.identifier
        )
        return collectionView
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Photo Gallery"
        photos = sourcePhotos
        setupCollectionView()
        runBenchmarks()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    // MARK: - Setup
    private func setupCollectionView() {
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - Multithreading benchmark
    private func runBenchmarks() {
        benchmarkResults.removeAll()
        processBenchmarkCase(at: 0, cases: makeBenchmarkCases())
    }

    private func makeBenchmarkCases() -> [BenchmarkCase] {
        [
            BenchmarkCase(
                name: "userInteractive / chrome / 20 images",
                sourceImages: sourcePhotos,
                filter: .chrome,
                qos: .userInteractive
            ),
            BenchmarkCase(
                name: "userInitiated / noir / 12 images",
                sourceImages: Array(sourcePhotos.prefix(12)),
                filter: .noir,
                qos: .userInitiated
            ),
            BenchmarkCase(
                name: "utility / sepia / 16 images",
                sourceImages: Array(sourcePhotos.prefix(16)),
                filter: .sepia(intensity: 0.8),
                qos: .utility
            ),
            BenchmarkCase(
                name: "background / colorInvert / 20 images",
                sourceImages: sourcePhotos,
                filter: .colorInvert,
                qos: .background
            )
        ]
    }

    private func processBenchmarkCase(at index: Int, cases: [BenchmarkCase]) {
        guard index < cases.count else {
            print("\n=== ImageProcessor benchmark summary ===")
            benchmarkResults.forEach { print($0) }
            print("========================================\n")
            return
        }

        let benchmarkCase = cases[index]
        let startedAt = Date()

        imageProcessor.processImagesOnThread(
            sourceImages: benchmarkCase.sourceImages,
            filter: benchmarkCase.filter,
            qos: benchmarkCase.qos
        ) { [weak self] processedCGImages in
            let elapsed = Date().timeIntervalSince(startedAt)
            let result = String(
                format: "%@ — %.4f s",
                benchmarkCase.name,
                elapsed
            )

            print("[ImageProcessor benchmark] \(result)")

            let processedImages = processedCGImages.compactMap { cgImage -> UIImage? in
                guard let cgImage else { return nil }
                return UIImage(cgImage: cgImage)
            }

            DispatchQueue.main.async { [weak self] in
                guard let self else { return }

                self.benchmarkResults.append(result)
                self.photos = processedImages
                self.collectionView.reloadData()
                self.processBenchmarkCase(at: index + 1, cases: cases)
            }
        }
    }

    // Фактическое время зависит от конкретного устройства и нагрузки системы,
    // поэтому результаты не хардкодятся. Каждый замер начинается до вызова
    // processImagesOnThread и заканчивается внутри completion после обработки.
    // Реальные значения для всех QoS печатаются в Xcode Console строками
    // "[ImageProcessor benchmark] ..." и итоговой сводкой после последнего теста.
}

// MARK: - UICollectionViewDataSource
extension PhotosViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        photos.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PhotosCollectionViewCell.identifier,
            for: indexPath
        ) as! PhotosCollectionViewCell

        cell.configure(with: photos[indexPath.item])
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension PhotosViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let insets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        let interSpacing: CGFloat = 8
        let columns: CGFloat = 3

        let availableWidth = collectionView.bounds.width
            - insets.left
            - insets.right
            - interSpacing * (columns - 1)

        let side = floor(availableWidth / columns)
        return CGSize(width: side, height: side)
    }
}
