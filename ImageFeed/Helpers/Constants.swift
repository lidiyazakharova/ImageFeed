import Foundation

enum Constants {
    
    //MARK: Unsplash api base paths
    static let defaultBaseURL = "https://api.unsplash.com"
    static let baseURL = "https://unsplash.com"
    static let unsplashAuthorizeURL = "https://unsplash.com/oauth/authorize"
    static let baseAuthTokenPath = "/oauth/token"
    static let authorizedPath = "/oauth/authorize/native"
    
    //MARK: Unsplash api constants
    static let accessKey = "VxG9li5SL5IH3aD7qCDXVZQ7Klv-qAbvIduwAh_rJAc"
    static let secretKey = "fJLnw76SaLMIqOVzKKN5qyr8Ke-V8eCULogEnZsH5ik"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    
    //MARK: Storage constants
    static let bearerToken = "bearerToken"
    
}
