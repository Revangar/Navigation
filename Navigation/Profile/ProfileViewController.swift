import UIKit

class ProfileViewController: UIViewController {
    private let headerView = ProfileHeaderView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightGray
        title = "Profile"
        setupUI()
    }
    
    private func setupUI() {
        view.addSubview(headerView)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        headerView.frame = view.bounds
    }
}
