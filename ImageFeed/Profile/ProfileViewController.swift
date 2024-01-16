import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    //MARK: - Private Properties
    private let profileImageService = ProfileImageService.shared
    private let profileService = ProfileService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    
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
        createLabel(size: 23, weight: .bold, text: "", color: .ypWhite)
    }()
    
    private lazy var loginNameLabel: UILabel = {
        createLabel(size: 13, weight: .regular, text: "", color: .ypGray)
    }()
    
    private lazy var descriptionLabel: UILabel = {
        createLabel(size: 13, weight: .regular, text: "", color: .ypWhite)
    }()
    
    //MARK: - UIViewController
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return.lightContent
    }
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        setImage()
        setText()
        setButton()
        
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification, // 3
            object: nil,                                        // 4
            queue: .main                                        // 5
        ) { [weak self] _ in
            guard let self = self else { return }
            self.updateAvatar()                                 // 6
        }
        
        updateAvatar()                                              // 7
    }
    
    private func updateAvatar() {
        guard let profileImageURL = ProfileImageService.shared.avatarURL
//            let url = URL(string: profileImageURL)
//                let profileImageURL = userInfo["URL"] as? String
//                let profileImageURL = notification.userInfoImageURL,
//                       let url = profileImageURL as? String
        else { return }

        print("profileImageURL", profileImageURL)
        
        let processor = RoundCornerImageProcessor(cornerRadius: 61)
        avatarImage.kf.indicatorType = .activity
        avatarImage.kf.setImage(with: profileImageURL, options: [.processor(processor)])
    }                                  // 8
            
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
            //no completion???
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
//        let nameLabel = createLabel(size: 23, weight: .bold, text: "\\name", color: .ypWhite)
//        let loginNameLabel = createLabel(size: 13, weight: .regular, text: "@\\login", color: .ypGray)
//        let descriptionLabel = createLabel(size: 13, weight: .regular, text: "\\description", color: .ypWhite)
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
    }
}

//@objc
//private func updateAvatar(notification: Notification) {
//    guard
//        isViewLoaded,
//        let userInfo = notification.userInfo,
//        //        let profileImageURL = userInfo["URL"] as? String,
//        let profileImageURL = notification.userInfoImageURL,
//        let url = URL(string: profileImageURL)
//    else { return }
//
//    updateAvatar(url: url)
//}

//private func updateAvatar(url: URL) {
//    profileImage.kf.indicatorType = .activity
//    ley processor = RoundCornerImageProcessor(cornerRadius: 61)
//    profileImage.kf.setImage(with: url, options: [.processor(processor)])
//}


extension Notification {
    static let userInfoImageURLKey: String = "URL"
    
    var userInfoImageURL: String? {
        userInfo?[Notification.userInfoImageURLKey] as? String
    }
}


//Notification
//    override init(nibName:String?, bundle: Bundle?) {
//        super.init(nibName: nibName, bundle: bundle)
//        addObserver()
//    }
//
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        addObserver()
//    }
//
//    deinit {
//        removeObserver()
//    }
//
//    private func addObserver() {
//        NotificationCenter.default.addObserver(                 // 1
//            self,                                               // 2
//            selector: #selector(updateAvatar(notification:)),   // 3
//            name: ProfileImageService.didChangeNotification,    // 4
//            object: nil)                                        // 5
//    }
//
//    private func removeObserver() {
//        NotificationCenter.default.removeObserver(              // 6
//            self,                                               // 7
//            name: ProfileImageService.didChangeNotification,    // 8
//            object: nil)                                        // 9
//    }
//
//    @objc                                                       // 10
//    private func updateAvatar(notification: Notification) {     // 11
//        guard
//            isViewLoaded,                                       // 12
//            let userInfo = notification.userInfo,               // 13
//            let profileImageURL =  notification.userInfoImageURL,  // 14
//            let url = URL(string: profileImageURL)              // 15
//        else { return }
//
//    }


