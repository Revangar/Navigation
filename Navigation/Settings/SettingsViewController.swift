import UIKit

final class SettingsViewController: UITableViewController {

    private let appSettings: AppSettings
    var onChangePassword: (() -> Void)?

    private lazy var sortingSwitch: UISwitch = {
        let control = UISwitch()
        control.isOn = appSettings.sortAscending
        control.addTarget(
            self,
            action: #selector(sortingValueChanged),
            for: .valueChanged
        )
        return control
    }()

    init(appSettings: AppSettings) {
        self.appSettings = appSettings
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Настройки"
        tableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: "SettingsCell"
        )
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }

    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        1
    }

    override func tableView(
        _ tableView: UITableView,
        titleForHeaderInSection section: Int
    ) -> String? {
        switch section {
        case 0:
            return "Файлы"
        case 1:
            return "Безопасность"
        default:
            return nil
        }
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "SettingsCell",
            for: indexPath
        )

        var configuration = cell.defaultContentConfiguration()

        switch indexPath.section {
        case 0:
            configuration.text = "Сортировка"
            configuration.secondaryText = sortingSwitch.isOn
                ? "По алфавиту"
                : "В обратном порядке"
            cell.accessoryView = sortingSwitch
            cell.accessoryType = .none
            cell.selectionStyle = .none

        case 1:
            configuration.text = "Поменять пароль"
            configuration.secondaryText = nil
            cell.accessoryView = nil
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .default

        default:
            break
        }

        cell.contentConfiguration = configuration
        return cell
    }

    override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard indexPath.section == 1 else {
            return
        }

        onChangePassword?()
    }

    @objc private func sortingValueChanged() {
        appSettings.sortAscending = sortingSwitch.isOn

        let indexPath = IndexPath(row: 0, section: 0)
        tableView.reloadRows(at: [indexPath], with: .none)
    }
}
