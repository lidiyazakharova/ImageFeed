import Foundation

final class URLRequestBuilder {
    static let shared = URLRequestBuilder()
    private let storage: OAuth2TokenStorage
    
    init(storage: OAuth2TokenStorage = .shared) {
        self.storage = storage
    }
    
    func makeHTTPRequest(
        path: String,
        httpMethod: String,
        baseURL: URL) -> URLRequest? {
            guard let baseUrl = URL(string: path, relativeTo: baseURL) else {
                return nil
            }
            var request = URLRequest(url: baseUrl)
            request.httpMethod = httpMethod
            if let token = storage.token {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            return request
        }
}
