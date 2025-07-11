//
//  PhotosViewController.swift
//  Navigation
//
//  Created by Revangar on 05.07.2025.
//


import UIKit

final class PhotosViewController: UIViewController {
    
    // MARK: – Data
    private let photos: [UIImage] = (1...20).compactMap { UIImage(named: "photo\($0)") }
    
    // MARK: – UI
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 8      // расстояние между ячейками
        layout.minimumLineSpacing      = 8
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .systemBackground
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.dataSource = self
        cv.delegate   = self
        cv.register(PhotosCollectionViewCell.self,
                    forCellWithReuseIdentifier: PhotosCollectionViewCell.identifier)
        return cv
    }()
    
    // MARK: – Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Photo Gallery"
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // Показываем бар
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // Скрываем бар при выходе
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}

// MARK: – UICollectionViewDataSource
extension PhotosViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int { photos.count }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PhotosCollectionViewCell.identifier,
            for: indexPath) as! PhotosCollectionViewCell
        cell.configure(with: photos[indexPath.item])
        return cell
    }
}

// MARK: – UICollectionViewDelegateFlowLayout
extension PhotosViewController: UICollectionViewDelegateFlowLayout {
    // отступы целиком
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
    }
    
    // размер ячейки 3 × в ряд
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let insets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        let interSpacing: CGFloat = 8
        let columns: CGFloat = 3
        
        let availableWidth = collectionView.bounds.width
                           - insets.left
                           - insets.right
                           - interSpacing * (columns - 1)
        
        let side = floor(availableWidth / columns)   // округляем вниз
        return CGSize(width: side, height: side)
    }
}
