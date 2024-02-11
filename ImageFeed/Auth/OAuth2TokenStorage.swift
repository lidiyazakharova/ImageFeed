import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    
    static let shared = OAuth2TokenStorage()
    let configuration: AuthConfiguration
    private let keychainWrapper = KeychainWrapper.standard
    
    var token: String? {
        get {
            keychainWrapper.string(forKey: configuration.bearerToken)
        }
        set {
            guard let newValue = newValue else {
                keychainWrapper.removeObject(forKey: configuration.bearerToken)
                return
            }
            keychainWrapper.set(newValue, forKey: configuration.bearerToken)
        }
    }
    
    private init(configuration: AuthConfiguration = .standard) {
        self.configuration = configuration
    }

}
