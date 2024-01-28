import UIKit
import Kingfisher
import WebKit

final class ProfileViewController: UIViewController {
    
    //MARK: - Private Properties
    private let profileImageService = ProfileImageService.shared
    private let profileService = ProfileService.shared
//    private let splashViewController = SplashViewController.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    
    private lazy var avatarImage: UIImageView = {
        let avatarImage = UIImageView()
        avatarImage.image = UIImage(named: "userPick")
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
    
    private lazy var logoutButton: UIButton = {
        let logoutButton = UIButton.systemButton(
            with: UIImage(named: "exit")!,
            target: self,
            action: #selector(Self.didTapButton)
        )
        logoutButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        logoutButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        logoutButton.tintColor = .ypRed
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        return logoutButton
    }()
    
    private lazy var nameLabel: UILabel = {
        createLabel(size: 23, weight: .bold, text: "Name", color: .ypWhite)
    }()
    
    private lazy var loginNameLabel: UILabel = {
        createLabel(size: 13, weight: .regular, text: "login", color: .ypGray)
    }()
    
    private lazy var descriptionLabel: UILabel = {
        createLabel(size: 13, weight: .regular, text: "Description", color: .ypWhite)
    }()
    
    //MARK: - UIViewController
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return.lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        setImage()
        setText()
        setButton()
        
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            self.updateAvatar()
        }
        updateAvatar()
    }
    
    private func updateAvatar() {
        guard let profileImageURL = ProfileImageService.shared.avatarURL
        else { return }
        
        let processor = RoundCornerImageProcessor(cornerRadius: 50)
        avatarImage.kf.indicatorType = .activity
        avatarImage.kf.setImage(with: profileImageURL, options: [.processor(processor)])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let profile = ProfileService.shared.profile else {
            assertionFailure("No saved profile")
            return
        }
        
        nameLabel.text = profile.name
        descriptionLabel.text = profile.bio
        loginNameLabel.text = profile.loginName
        
        profileImageService.fetchProfileImageURL(userName: profile.username) { _ in
        }
    }
    
    //MARK: - Private Functions
    private func setImage () {
        view.addSubview(avatarImage)
        NSLayoutConstraint.activate([
            avatarImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            avatarImage.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)
        ])
    }
    
    private func createLabel(size: CGFloat, weight: UIFont.Weight, text: String, color: UIColor) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.numberOfLines = 0
        label.textColor = color
        label.font = UIFont.systemFont(ofSize: size, weight: weight)
        return label
    }
    
    private func setText() {
        view.addSubview(textStack)
        textStack.addArrangedSubview(nameLabel)
        textStack.addArrangedSubview(loginNameLabel)
        textStack.addArrangedSubview(descriptionLabel)
        NSLayoutConstraint.activate([
            textStack.topAnchor.constraint(equalTo: avatarImage.bottomAnchor, constant: 8),
            textStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            textStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
    
    private func setButton() {
        view.addSubview(logoutButton)
        NSLayoutConstraint.activate([
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            logoutButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 45),
            logoutButton.leadingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: avatarImage.trailingAnchor, multiplier: 1)
        ])
    }
    
    @objc
    private func didTapButton() {
        print("logout")
        
        OAuth2TokenStorage.shared.token = nil
        // Очищаем все куки из хранилища.
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        // Запрашиваем все данные из локального хранилища.
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            // Массив полученных записей удаляем из хранилища.
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
//        showAuthController()// После выполнения логаута нужно перейти на начальный экран приложения, так как без авторизационных данных невозможно выполнить запросы API.
//        rootViewController заменяется на SplashViewController (выполняется по аналогии со switchToTabBarController, только нужно перейти не на TabBarController, а на SplashViewController).
    }
}

extension Notification {
    static let userInfoImageURLKey: String = "URL"
    var userInfoImageURL: String? {
        userInfo?[Notification.userInfoImageURLKey] as? String
    }
}
