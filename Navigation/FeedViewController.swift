//
//  FeedViewController.swift
//  Navigation
//
//  Created by Revangar on 15.05.2025.
//


import UIKit

class FeedViewController: UIViewController {

    // 1) Вынесли кнопку в свойство класса, инициализируем через замыкание:
    private let openPostButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Open Post", for: .normal)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Feed"

        // 2) Добавляем ранее созданную кнопку на экран:
        view.addSubview(openPostButton)
        openPostButton.frame = CGRect(x: 100, y: 200, width: 200, height: 50)
        openPostButton.addTarget(self, action: #selector(openPost), for: .touchUpInside)
    }

    @objc func openPost() {
        let post = Post(title: "My Post Title")
        let vc = PostViewController(post: post)
        navigationController?.pushViewController(vc, animated: true)
    }
}
