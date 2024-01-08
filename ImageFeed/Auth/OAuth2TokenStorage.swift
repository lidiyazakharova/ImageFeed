import Foundation

final class OAuth2TokenStorage {
    
    private static let keyAccessToken = "KEY_ACCESS_TOKEN"
    private let userDefaults: UserDefaults
    
    var token: String? {
            get {
                userDefaults.string(forKey: OAuth2TokenStorage.keyAccessToken)
            }
            set {
                userDefaults.set(newValue, forKey: OAuth2TokenStorage.keyAccessToken)
            }
    }
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
}

