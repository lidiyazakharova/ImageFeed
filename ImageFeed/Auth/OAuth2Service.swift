import Foundation

final class OAuth2Service {
    private let urlSession: URLSession
    private let storage: OAuth2TokenStorage
    private var lastCode: String?
    private var currentTask: URLSessionTask?
    
    init(urlSession: URLSession = .shared, storage: OAuth2TokenStorage = .shared) {
        self.urlSession = urlSession
        self.storage = storage
    }
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        if lastCode == code { return }
        currentTask?.cancel()
        lastCode = code
        
        guard let request = authTokenRequest(code: code) else {
            assertionFailure("Invalid request")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        //        let request = authTokenRequest(code: code)
        
        currentTask = fetchOAuthBody(request: request) { [weak self] response in
//            self?.currentTask = nil
            switch response {
            case .success(let body):
                let authToken = body.accessToken
                self?.storage.token = authToken
                completion(.success(authToken))
                self?.currentTask = nil
            case .failure(let error):
                completion(.failure(error))
                if error != nil { self?.lastCode = nil }
            }
        }
    }
    
    func fetchOAuthBody (request: URLRequest, completion: @escaping (Result<OAuthTokenResponseBody, Error>) -> Void) -> URLSessionTask {
        let fulfillCompletionOnMainThread: (Result<OAuthTokenResponseBody, Error>) -> Void = { result in DispatchQueue.main.async {
            completion(result)
        }
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200 ..< 300 ~= statusCode {
                    do {
                        let decoder = JSONDecoder()
                        let result = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                        fulfillCompletionOnMainThread(.success(result))
                    } catch {
                        fulfillCompletionOnMainThread(.failure(NetworkError.decodingError(error)))
                    }
                } else {
                    fulfillCompletionOnMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                }
            } else if let error = error {
                fulfillCompletionOnMainThread(.failure(NetworkError.urlRequestError(error)))
            } else {
                fulfillCompletionOnMainThread(.failure(NetworkError.urlSessionError))
            }
        })
        task.resume()
        return task
    }
    
}


extension OAuth2Service {
    private func authTokenRequest(code: String) -> URLRequest? {
        URLRequest.makeHTTPRequest(
            path: "\(Constants.baseAuthTokenPath)"
            + "?client_id=\(Constants.accessKey)"
            + "&&client_secret=\(Constants.secretKey)"
            + "&&redirect_uri=\(Constants.redirectURI)"
            + "&&code=\(code)"
            + "&&grant_type=authorization_code",
            httpMethod: "POST",
            baseURL: URL(string: Constants.baseURL)!)
    }
}
















































//final class OAuth2Service {
////    static let shared = OAuth2Service()
////    private let urlSession = URLSession.shared
//    private let urlSession: URLSession
//    private let storage: OAuth2TokenStorage
//
//    init(urlSession: URLSession = .shared, storage: OAuth2TokenStorage = .shared) {
//        self.urlSession = urlSession
//        self.storage = storage
//    }
//
////    private (set) var authToken: String? {
////        get {
////            return OAuth2TokenStorage().token
////        }
////        set {
////            OAuth2TokenStorage().token = newValue
////        } }
//
//
//    private var lastCode: String?
//    private var task: URLSessionTask?
//
//    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void ){
//            if lastCode == code { return }
//            task?.cancel()
//            lastCode = code
//
//            let request = authTokenRequest(code: code)
//            let task = object(for: request) { [weak self] result in
//                guard let self = self else { return }
//                switch result {
//
//                case .success(let body):
//                    let authToken = body.accessToken
//                    self.storage.token = authToken
//                    completion(.success(authToken))
//                    //добавлен код
//                    self.task = nil
//
//                case .failure(let error):
//                    completion(.failure(error))
//                    //добавлен код
//                    if error != nil { self.lastCode = nil }
//                }
//            }
//
//
//        self.task = task
//            task.resume()
//        }
//}
////    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
////            assert(Thread.isMainThread)                         // 4
////            if task != nil {                                    // 5
////                if lastCode != code {                           // 6
////                    task?.cancel()                              // 7
////                } else {
////                    return                                      // 8
////                }
////            } else {
////                if lastCode == code {                           // 9
////                    return
////                }
////            }
////            lastCode = code                                     // 10
//
//
////            ||if lastCode == code { return }                      // 1
////           ||task?.cancel()                                      // 2
////           ||lastCode = code                                     // 3
//
//
////            let request = makeRequest(code: code)               // 11
////            let task = urlSession.dataTask(with: request) { data, response, error in
////                DispatchQueue.main.async {                      // 12
////                    completion(.success("")) // TODO [Sprint 10]// 13
////                    self.task = nil                             // 14
////                    if error != nil {                           // 15
////                        self.lastCode = nil                     // 16
////                    }
////                }
////            }
////            self.task = task                                    // 17
////            task.resume()                                       // 18
////        }
////
////        private func makeRequest(code: String) -> URLRequest {  // 19
////            guard let url = URL(string: "...\(code)") else { fatalError("Failed to create URL") }
////            var request = URLRequest(url: url)
////            request.httpMethod = "POST"
////            return request
////        }
////    }
////------
////    func fetchOAuthToken(
////        _ code: String,
////        completion: @escaping (Result<String, Error>) -> Void ){
////            let request = authTokenRequest(code: code)
////            let task = object(for: request) { [weak self] result in
////                guard let self = self else { return }
////                switch result {
////
////                case .success(let body):
////                    let authToken = body.accessToken
////                    self.storage.token = authToken
////                    completion(.success(authToken))
////
////                case .failure(let error):
////                    completion(.failure(error))
////                } }
////            task.resume()
//////        }
////}
//
//extension OAuth2Service {
//    private func object(for request: URLRequest, completion: @escaping (Result<OAuthTokenResponseBody, Error>) -> Void ) -> URLSessionTask {
//        let decoder = JSONDecoder()
//        return urlSession.data(for: request) { (result: Result<Data, Error>) in
//            let response = result.flatMap { data -> Result<OAuthTokenResponseBody, Error> in
//                Result { try decoder.decode(OAuthTokenResponseBody.self, from: data) }
//            }
//            completion(response)
//        }
//    }
//
//    private func authTokenRequest(code: String) -> URLRequest {
//        URLRequest.makeHTTPRequest(
//            path: baseAuthTokenPath
////                "/oauth/token"
//            + "?client_id=\(AccessKey)"
//            + "&&client_secret=\(SecretKey)"
//            + "&&redirect_uri=\(RedirectURI)"
//            + "&&code=\(code)"
//            + "&&grant_type=authorization_code",
//            httpMethod: "POST",
//            baseURL: BaseURL
////            baseURL: URL(string: "https://unsplash.com")!
////            baseURL: DefaultBaseURL
//        ) }
//}
//
////       k как собрать запросб через URLComponents (нужны строковые константы)
////        var urlComponents = URLComponents(string: Constants.baseURL)
////        urlComponents?.queryItems = [
////            URLQueryItem(name: "client_id", value: AccessKey),
////        ]
//
//// MARK: - HTTP Request
//extension URLRequest {
//    static func makeHTTPRequest(
//        path: String,
//        httpMethod: String,
//        baseURL: URL = DefaultBaseURL
//    ) -> URLRequest {
//        var request = URLRequest(url: URL(string: path, relativeTo: baseURL)!)
//        request.httpMethod = httpMethod
//        return request
//    } }
//            // MARK: - Network Connection
//
//            extension URLSession {
//                func data(for request: URLRequest,completion: @escaping (Result<Data, Error>) -> Void) -> URLSessionTask {
//                    let fulfillCompletion: (Result<Data, Error>) -> Void = { result in
//                        DispatchQueue.main.async {
//                            completion(result)
//                        }
//                    }
//                    let task = dataTask(with: request, completionHandler: { data, response, error in
//                        if let data = data,
//                           let response = response,
//                           let statusCode = (response as? HTTPURLResponse)?.statusCode
//                        {
//                            if 200 ..< 300 ~= statusCode {
//                                fulfillCompletion(.success(data))
//                            } else {
//                                fulfillCompletion(.failure(NetworkError.httpStatusCode(statusCode)))
//                            }
//                        } else if let error = error {
//                            fulfillCompletion(.failure(NetworkError.urlRequestError(error)))
//                        } else {
//                            fulfillCompletion(.failure(NetworkError.urlSessionError))
//                        }
//                    })
//                    task.resume()
//                    return task
//                }
//            }
//
