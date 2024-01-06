import Foundation
//MARK: - HTTP Request
//extension URLRequest {
//    static func makeHTTPRequest(
//        path: String,
//        httpMethod: String,
//        baseURLString: String) -> URLRequest? {
//            guard
//                let url = URL(string: baseURLString),
//                let baseUrl = URL(string: path, relativeTo: url)
//            else { return nil }
//
//            var request = URLRequest(url: baseUrl)
//            request.httpMethod = httpMethod
//            let token = OAuth2TokenStorage.shared.token {
//                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//            }
//            return request
//        }
//}


extension URLRequest {
    static func makeHTTPRequest(
        path: String,
        httpMethod: String,
        baseURL: URL) -> URLRequest {
            var request = URLRequest(url: URL(string: path, relativeTo: baseURL)!)
            request.httpMethod = httpMethod
            if let token = OAuth2TokenStorage.shared.token {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            return request
        }
}

//final class URLRequestBuilder {
//    static let shared = URLRequestBuilder()
//    private let storage: OAuth2TokenStorage
//
//    init(storage: OAuth2TokenStorage = .shared) {
//        self.storage = storage
//    }
//
//    func makeHTTPRequest(
//            path: String,
//            httpMethod: String,
//            baseURL: URL) -> URLRequest {
//                var request = URLRequest(url: URL(string: path, relativeTo: baseURL)!)
//                request.httpMethod = httpMethod
//                let token = OAuth2TokenStorage.shared.token {
//                    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//                }
//                return request
//            }
//}
