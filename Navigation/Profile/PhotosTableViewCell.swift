//
//  PhotosTableViewCell.swift
//  Navigation
//
//  Created by Revangar on 05.07.2025.
//

import Foundation
import UIKit

final class PhotosTableViewCell: UITableViewCell {
    static let identifier = "PhotosTableViewCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Photos"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let arrowImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "arrow.right"))
        imageView.tintColor = .black
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let imagesStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private var imageViews: [UIImageView] = []
    
    private func setupViews() {
        selectionStyle = .none
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(arrowImageView)
        contentView.addSubview(imagesStack)
        
        
        for _ in 0..<4 {
            let iv = UIImageView()
            iv.contentMode = .scaleAspectFill
            iv.clipsToBounds = true
            iv.layer.cornerRadius = 6
            imageViews.append(iv)
            imagesStack.addArrangedSubview(iv)
        }
        
        NSLayoutConstraint.activate([
            // ---------- верхняя часть ----------
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),

            arrowImageView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            arrowImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),

            // ---------- стек с картинками ----------
            imagesStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            imagesStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            imagesStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            imagesStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            imagesStack.heightAnchor.constraint(equalTo: imagesStack.widthAnchor, multiplier: 1.0 / 4.0),
        ])
    }
    
    func configure(with images: [UIImage]) {
        for (index, image) in images.prefix(4).enumerated() {
            imageViews[index].image = image
        }
    }
}
