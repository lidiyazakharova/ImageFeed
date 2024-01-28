import UIKit

final class SplashViewController: UIViewController {
    
    //MARK: - Private Properties
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    private let oauth2Service = OAuth2Service()
    private var alertPresenter = AlertPresenter()
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private var authIsChecked: Bool = false
    
    private lazy var splashScreenImage: UIImageView = {
        let splashScreenImage = UIImageView()
        splashScreenImage.image = UIImage(named: "splashScreenIcon")
        splashScreenImage.contentMode = .scaleToFill
        splashScreenImage.translatesAutoresizingMaskIntoConstraints = false
        splashScreenImage.heightAnchor.constraint(equalToConstant: 78).isActive = true
        splashScreenImage.widthAnchor.constraint(equalToConstant: 75).isActive = true
        return splashScreenImage
    } ()
    
    
    //MARK: - UIViewController
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return.lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alertPresenter.delegate = self
        view.backgroundColor = .ypBlack
        setSplashScreenImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard UIBlockingProgressHUD.isShowing == false else { return }
        
        if !authIsChecked {
            checkAuthStatus()
            authIsChecked = true
        }
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
    
    func showAuthController() {
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
        if segue.identifier == showAuthenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else { fatalError("Failed to prepare for \(showAuthenticationScreenSegueIdentifier)") }
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}
//MARK: - AuthViewControllerDelegate
extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
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
                self?.switchToTabBarController()
            case.failure(let error):
                self?.showLoginAlert(error: error)
            }
            completion()
        }
    }
    
    private func showLoginAlert(error: Error) {
//        print("We are here")
        
        alertPresenter.showAlert(title: "Что-то пошло не так :(",
                                 message: "Не удалось войти в систему, \(error.localizedDescription)") { [weak self] in
            guard let self = self else { return }
            self.showAuthController()
            
        }
    }
    
    private func presentAuthScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let viewController = storyboard.instantiateViewController(identifier: "AuthViewControllerID")
        guard let authViewController = viewController as? AuthViewController else { return }
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true)
    }
}

