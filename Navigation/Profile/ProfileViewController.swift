import UIKit

class ProfileViewController: UIViewController {
    private let headerView = ProfileHeaderView()
    
    private let additionalButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Дополнительная кнопка", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Profile"
        setupUI()
        setupConstraints()
    }
    
    private func setupUI() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(headerView)
        view.addSubview(additionalButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Header view constraints
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 220),
            
            // Additional button constraints
            additionalButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            additionalButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            additionalButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
