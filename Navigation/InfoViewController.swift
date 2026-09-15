import UIKit

final class InfoViewController: UIViewController {

    private let dataService = InfoDataService()
    private var residents: [Resident] = []

    private let todoTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Todo title: загрузка…"
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.numberOfLines = 0
        return label
    }()

    private let orbitalPeriodLabel: UILabel = {
        let label = UILabel()
        label.text = "Tatooine orbital period: загрузка…"
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.numberOfLines = 0
        return label
    }()

    private let residentsTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Жители Татуина: загрузка…"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        return label
    }()

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = 48
        return tableView
    }()

    private lazy var showAlertButton = CustomButton(
        title: "Show Alert",
        titleColor: .systemBlue,
        backgroundColor: .clear,
        cornerRadius: 0
    ) { [weak self] in
        self?.showAlert()
    }

    private lazy var headerStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            todoTitleLabel,
            orbitalPeriodLabel,
            residentsTitleLabel
        ])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Info"
        view.backgroundColor = .systemBackground
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Close",
            style: .plain,
            target: self,
            action: #selector(closeVC)
        )

        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ResidentCell")

        setupUI()
        loadRemoteData()
    }

    private func setupUI() {
        view.addSubview(headerStack)
        view.addSubview(tableView)
        view.addSubview(showAlertButton)

        NSLayoutConstraint.activate([
            headerStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            headerStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            headerStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            tableView.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: showAlertButton.topAnchor, constant: -8),

            showAlertButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            showAlertButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            showAlertButton.widthAnchor.constraint(equalToConstant: 200),
            showAlertButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    private func loadRemoteData() {
        loadTodo()
        loadPlanet()
    }

    private func loadTodo() {
        dataService.loadTodo { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }

                switch result {
                case .success(let todo):
                    self.todoTitleLabel.text = "Todo title: \(todo.title)"

                case .failure(let error):
                    self.todoTitleLabel.text = "Todo error: \(error.localizedDescription)"
                }
            }
        }
    }

    private func loadPlanet() {
        dataService.loadPlanet { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let planet):
                DispatchQueue.main.async {
                    self.orbitalPeriodLabel.text = "\(planet.name) orbital period: \(planet.orbitalPeriod) days"
                }
                self.loadResidents(from: planet.residents)

            case .failure(let error):
                DispatchQueue.main.async {
                    self.orbitalPeriodLabel.text = "Planet error: \(error.localizedDescription)"
                    self.residentsTitleLabel.text = "Жители Татуина: недоступны"
                }
            }
        }
    }

    private func loadResidents(from urls: [String]) {
        dataService.loadResidents(from: urls) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }

                switch result {
                case .success(let residents):
                    self.residents = residents
                    self.residentsTitleLabel.text = "Жители Татуина (\(residents.count))"
                    self.tableView.reloadData()

                case .failure(let error):
                    self.residents = []
                    self.residentsTitleLabel.text = "Residents error: \(error.localizedDescription)"
                    self.tableView.reloadData()
                }
            }
        }
    }

    @objc private func closeVC() {
        dismiss(animated: true)
    }

    private func showAlert() {
        let alert = UIAlertController(
            title: "Info",
            message: "Здесь отображаются данные, загруженные через URLSessionDataTask.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alert, animated: true)
    }
}

extension InfoViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        residents.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResidentCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = residents[indexPath.row].name
        content.image = UIImage(systemName: "person.fill")
        cell.contentConfiguration = content
        cell.selectionStyle = .none
        return cell
    }
}
