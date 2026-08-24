import UIKit

class InfoViewController: UIViewController {

    private lazy var showAlertButton = CustomButton(
        title: "Show Alert",
        titleColor: .systemBlue,
        backgroundColor: .clear,
        cornerRadius: 0
    ) { [weak self] in
        self?.showAlert()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Close",
            style: .plain,
            target: self,
            action: #selector(closeVC)
        )

        view.addSubview(showAlertButton)

        NSLayoutConstraint.activate([
            showAlertButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            showAlertButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            showAlertButton.widthAnchor.constraint(equalToConstant: 200),
            showAlertButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc private func closeVC() {
        dismiss(animated: true)
    }

    private func showAlert() {
        let alert = UIAlertController(
            title: "Info",
            message: "Some info here",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            print("OK pressed")
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            print("Cancel pressed")
        })

        present(alert, animated: true)
    }
}
