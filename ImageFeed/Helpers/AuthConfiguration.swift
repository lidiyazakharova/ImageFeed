import Foundation

//MARK: Unsplash api constants
let AccessKey = "VxG9li5SL5IH3aD7qCDXVZQ7Klv-qAbvIduwAh_rJAc"
let SecretKey = "fJLnw76SaLMIqOVzKKN5qyr8Ke-V8eCULogEnZsH5ik"
let RedirectURI = "urn:ietf:wg:oauth:2.0:oob"
let AccessScope = "public+read_user+write_likes"

//MARK: Unsplash api base paths
let DefaultBaseURL = URL(string:"https://api.unsplash.com")!
let BaseURL = URL(string: "https://unsplash.com")!
let UnsplashAuthorizeURL = "https://unsplash.com/oauth/authorize"
let BaseAuthTokenPath = "/oauth/token"
let AuthorizedPath = "/oauth/authorize/native"

//MARK: Storage constants
let BearerToken = "bearerToken"

struct AuthConfiguration {
    
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let authURL: String
    let baseURL: URL
    let baseAuthTokenPath: String
    let authorizedPath: String
    let bearerToken: String
    
    static var standard: AuthConfiguration {
            return AuthConfiguration(accessKey: AccessKey,
                                     secretKey: SecretKey,
                                     redirectURI: RedirectURI,
                                     accessScope: AccessScope,
                                     defaultBaseURL: DefaultBaseURL,
                                     authURL: UnsplashAuthorizeURL,
                                     baseURL: BaseURL,
                                     baseAuthTokenPath: BaseAuthTokenPath,
                                     authorizedPath: AuthorizedPath,
                                     bearerToken: BearerToken
            )
        }
    
    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, defaultBaseURL: URL, authURL: String, baseURL: URL, baseAuthTokenPath: String, authorizedPath: String, bearerToken: String) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURL = defaultBaseURL
        self.authURL = authURL
        self.baseURL = baseURL
        self.baseAuthTokenPath = baseAuthTokenPath
        self.authorizedPath = authorizedPath
        self.bearerToken = bearerToken
        
    }
}
