import UIKit
//import ProgressHUD

final class SplashViewController: UIViewController {
    
    //MARK: - Private Properties
    private let ShowAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    private let oauth2Service = OAuth2Service()
    //    private let oauth2TokenStorage = OAuth2TokenStorage()
    private var alertPresenter = AlertPresenter()
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
//    private var wasChecked: Bool = false // ????
    
    private lazy var splashScreenImage: UIImageView = {
        let splashScreenImage = UIImageView()
        splashScreenImage.image = UIImage(named: "splashScreenIcon")
        splashScreenImage.contentMode = .scaleToFill
        splashScreenImage.translatesAutoresizingMaskIntoConstraints = false
        splashScreenImage.heightAnchor.constraint(equalToConstant: 78).isActive = true
        splashScreenImage.widthAnchor.constraint(equalToConstant: 75).isActive = true
        return splashScreenImage
    } ()
    
    //    override func viewDidAppear(_ animated: Bool) {
    //        super.viewDidAppear(animated)
    //
    //        //        if oauth2TokenStorage.token != nil { } else {}
    //        //          if let token = oauth2TokenStorage.token {
    //        if oauth2TokenStorage.token != nil {
    //            switchToTabBarController()
    //        } else {
    //            performSegue(withIdentifier: ShowAuthenticationScreenSegueIdentifier, sender: nil)
    //        }
    //    }
    //
    //    override func viewWillAppear(_ animated: Bool) {
    //        super.viewWillAppear(animated)
    //        setNeedsStatusBarAppearanceUpdate()
    //    }
    
    //MARK: - UIViewController
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return.lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alertPresenter.delegate = self
        view.backgroundColor = .ypRed // CHANGE COLOR
        setSplashScreenImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkAuthStatus()
    }
    
    //MARK: - Private Functions
    private func setSplashScreenImage(){
        view.addSubview(splashScreenImage)
        NSLayoutConstraint.activate([
            splashScreenImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            splashScreenImage.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func checkAuthStatus() {
//        guard wasChecked else {return}
//        wasChecked = true //проверка входа
        
        if  oauth2Service.isAuthenticated {
            UIBlockingProgressHUD.show()
            
            fetchProfile { [weak self] in
                UIBlockingProgressHUD.dismiss()
                self?.switchToTabBarController()
            }
            
        } else {
            showAuthController()
        }
        
    }
    
    private func showAuthController() {
        let viewController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: "AuthViewControllerID")
        guard let authViewController = viewController as? AuthViewController else { return }
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true)
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
}



//MARK: - Extensions
extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowAuthenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else { fatalError("Failed to prepare for \(ShowAuthenticationScreenSegueIdentifier)") }
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}
//MARK: - AuthViewControllerDelegate
extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        UIBlockingProgressHUD.show()
        
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.fetchOAuthToken(code)
        }
    }
    
    private func fetchOAuthToken(_ code: String) {
        UIBlockingProgressHUD.show()
        
        oauth2Service.fetchOAuthToken(code) { [weak self] authResult in
            switch authResult {
            case.success(_):
                self?.fetchProfile(completion: {
                    UIBlockingProgressHUD.dismiss()
                })
            case.failure(let error):
                self?.showLoginAlert(error: error)
                UIBlockingProgressHUD.dismiss()
            }
        }
    }
    
    private func fetchProfile(completion: @escaping () -> Void) {
        profileService.fetchProfile { [weak self] profileResult in
            switch profileResult {
            case.success(_):
//            case.success(let profile):
//                print("\(profile.username)")
//                print("\(profile.loginName)")
//                print("\(profile.name)")
//                print("\(profile.bio)")
                
                self?.switchToTabBarController()
            case.failure(let error):
                self?.showLoginAlert(error: error)
            }
            completion()
        }
    }
    
    //    БЫЛО private func fetchOAuthToken(_ code: String) {
    //            guard let self = self else { return }
    //            switch result {
    //            case .success:
    //                self.switchToTabBarController()
    //                ProgressHUD.dismiss()
    //            case .failure:
    //                ProgressHUD.dismiss()
    //            }
    //        }
    //    }
    
    private func showLoginAlert(error: Error) {
        alertPresenter.showAlert(title: "Что-то пошло не так :(",
                                 message: "Не удалось войти в систему, \(error.localizedDescription)") {
            self.performSegue(withIdentifier: self.ShowAuthenticationScreenSegueIdentifier, sender: nil)
        } //проверить идентификатор сети Добавить кнопку
    }
    
    private func presentAuthScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        //        storyboard.instantiateInitialViewController()
        let viewController = storyboard.instantiateViewController(identifier: "AuthViewControllerID")
        guard let authViewController = viewController as? AuthViewController else { return }
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true)
    }
}

