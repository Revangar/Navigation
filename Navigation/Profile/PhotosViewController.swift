//
//  PhotosViewController.swift
//  Navigation
//
//  Created by Revangar on 05.07.2025.
//

import UIKit
import iOSIntPackage

final class PhotosViewController: UIViewController {

    // MARK: - Data
    private let sourcePhotos: [UIImage] = (1...20).compactMap { UIImage(named: "photo\($0)") }
    private var photos: [UIImage] = []

    // MARK: - Dependencies
    private var imagePublisherFacade: ImagePublisherFacade?

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
        setupCollectionView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        startImagePublishing()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        imagePublisherFacade?.removeSubscription(for: self)
        imagePublisherFacade = nil
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

    private func startImagePublishing() {
        photos.removeAll()
        collectionView.reloadData()

        let facade = ImagePublisherFacade()
        imagePublisherFacade = facade
        facade.subscribe(self)
        facade.addImagesWithTimer(
            time: 0.5,
            repeat: 20,
            userImages: sourcePhotos
        )
    }
}

// MARK: - ImageLibrarySubscriber
extension PhotosViewController: ImageLibrarySubscriber {
    func receive(images: [UIImage]) {
        DispatchQueue.main.async { [weak self] in
            self?.photos = images
            self?.collectionView.reloadData()
        }
    }
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
