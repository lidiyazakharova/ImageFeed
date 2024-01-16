import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    
    private let keychainWrapper = KeychainWrapper.standard

    var token: String? {
        get {
            keychainWrapper.string(forKey: Constants.bearerToken)
        }
        set {
            guard let newValue = newValue else {
                keychainWrapper.removeObject(forKey: Constants.bearerToken)
                return
            }
            
            keychainWrapper.set(newValue, forKey: Constants.bearerToken)
        }
    }
}
    
//    private static let keyAccessToken = "KEY_ACCESS_TOKEN"
//    private let userDefaults: UserDefaults
//
//    var token: String? {
//            get {
//                userDefaults.string(forKey: OAuth2TokenStorage.keyAccessToken)
//            }
//            set {
//                userDefaults.set(newValue, forKey: OAuth2TokenStorage.keyAccessToken)
//            }
//    }
//
//    init(userDefaults: UserDefaults = .standard) {
//        self.userDefaults = userDefaults
//    }
//}
//
