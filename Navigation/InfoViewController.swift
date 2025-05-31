//
//  InfoViewController.swift
//  Navigation
//
//  Created by Revangar on 15.05.2025.
//


import UIKit

class InfoViewController: UIViewController {

    // 1) Вынесли кнопку в свойство класса, инициализируем через замыкание:
    private let showAlertButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Show Alert", for: .normal)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        // 2) Добавляем ранее созданную кнопку на экран:
        view.addSubview(showAlertButton)
        showAlertButton.frame = CGRect(x: 100, y: 200, width: 200, height: 50)
        showAlertButton.addTarget(self, action: #selector(showAlert), for: .touchUpInside)
    }

    @objc func showAlert() {
        let alert = UIAlertController(title: "Info", message: "Some info here", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            print("OK pressed")
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            print("Cancel pressed")
        })
        present(alert, animated: true)
    }
}
