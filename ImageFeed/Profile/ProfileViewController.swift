import UIKit

final class ProfileViewController: UIViewController {
    
    private lazy var avatarImage: UIImageView = {
        let avatarImage = UIImageView()
        avatarImage.image = UIImage(named: "userPhoto")
        avatarImage.contentMode = .scaleToFill
        avatarImage.translatesAutoresizingMaskIntoConstraints = false
        avatarImage.heightAnchor.constraint(equalToConstant: 70).isActive = true
        avatarImage.widthAnchor.constraint(equalToConstant: 70).isActive = true
        return avatarImage
    } ()
    
    private lazy var textStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return.lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setImage()
        setText()
    }
    
    private func setImage () {
        view.addSubview(avatarImage)
        avatarImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32).isActive = true
        avatarImage.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
    }
    
    private func setText() {
        view.addSubview(textStack)
        let nameLabel = createLabel(size: 23, weight: .bold, text: "Екатерина Новикова", color: .ypWhite)
        let loginNameLabel = createLabel(size: 13, weight: .regular, text: "@ekaterina_nov", color: .ypGray)
        let descriptionLabel = createLabel(size: 13, weight: .regular, text: "Hello, world!", color: .ypWhite)
        
        textStack.addArrangedSubview(nameLabel)
        textStack.addArrangedSubview(loginNameLabel)
        textStack.addArrangedSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            textStack.topAnchor.constraint(equalTo: avatarImage.bottomAnchor, constant: 8),
            textStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            textStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
    
    private func createLabel(size: CGFloat, weight: UIFont.Weight, text: String, color: UIColor) -> UILabel{
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.numberOfLines = 0
        label.textColor = color
        label.font = UIFont.systemFont(ofSize: size, weight: weight)
        return label
    }
}

