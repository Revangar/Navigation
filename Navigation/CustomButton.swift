import UIKit

final class CustomButton: UIButton {

    typealias Action = () -> Void

    private let action: Action

    init(
        title: String? = nil,
        titleColor: UIColor = .white,
        backgroundColor: UIColor = .systemBlue,
        cornerRadius: CGFloat = 10,
        font: UIFont = .systemFont(ofSize: 16, weight: .medium),
        backgroundImage: UIImage? = nil,
        image: UIImage? = nil,
        tintColor: UIColor? = nil,
        clipsToBounds: Bool = false,
        action: @escaping Action
    ) {
        self.action = action
        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false
        setTitle(title, for: .normal)
        setTitleColor(titleColor, for: .normal)
        self.backgroundColor = backgroundColor
        layer.cornerRadius = cornerRadius
        titleLabel?.font = font
        self.clipsToBounds = clipsToBounds

        if let backgroundImage {
            setBackgroundImage(backgroundImage, for: .normal)
        }

        if let image {
            setImage(image, for: .normal)
        }

        if let tintColor {
            self.tintColor = tintColor
        }

        addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func buttonTapped() {
        action()
    }
}
