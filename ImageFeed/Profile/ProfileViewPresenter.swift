import Foundation
import WebKit

public protocol ProfileViewPresenterProtocol {

    func viewDidLoad()
    func removeData()
    func viewWillAppear()
}

final class ProfileViewPresenter: ProfileViewPresenterProtocol {

    weak var view: ProfileViewControllerProtocol?
    
    private let imagesListService = ImagesListService.shared
    private let profileImageService = ProfileImageService.shared
    private let profileService = ProfileService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    
    func viewDidLoad() {
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            guard let url = ProfileImageService.shared.avatarURL else { return }
            
            self.view?.updateAvatar(url: url)
        }
    }
    
    func viewWillAppear() {
        fetchProfileImageURL()
        updateProfileInfo()
    }
    
    func removeData() {
        OAuth2TokenStorage.shared.token = nil
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
        self.imagesListService.reset()
    }
    
    private func fetchProfileImageURL() {
        guard let profile = profileService.profile else {
            assertionFailure("No saved profile")
            return
        }
        
        profileImageService.fetchProfileImageURL(userName: profile.username) { _ in
        }
    }
    
    private func updateProfileInfo() {
        guard let profile = profileService.profile else {
            assertionFailure("No saved profile")
            return
        }
        
        view?.updateProfileInfo(
            name: profile.name,
            bio: profile.bio,
            loginName: profile.loginName)
    }
}

extension Notification {
    static let userInfoImageURLKey: String = "URL"
    var userInfoImageURL: String? {
        userInfo?[Notification.userInfoImageURLKey] as? String
    }
}

