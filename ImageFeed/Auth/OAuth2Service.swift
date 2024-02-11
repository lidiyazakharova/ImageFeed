import Foundation

final class OAuth2Service {
    let configuration: AuthConfiguration
    var isAuthenticated: Bool { storage.token != nil }
    private let urlSession: URLSession
    private let storage: OAuth2TokenStorage
    private let builder: URLRequestBuilder
    private var lastCode: String?
    private var currentTask: URLSessionTask?
  
    
    init(
        urlSession: URLSession = .shared,
        storage: OAuth2TokenStorage = .shared,
        builder: URLRequestBuilder = .shared,
        configuration: AuthConfiguration = .standard
    ) {
        self.urlSession = urlSession
        self.storage = storage
        self.builder = builder
        self.configuration = configuration
    }

    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        if lastCode == code { return }
        currentTask?.cancel()
        lastCode = code
        
        guard let request = authTokenRequest(code: code) else {
            assertionFailure("Invalid request")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        let session = URLSession.shared
        currentTask = session.objectTask(for: request) {
            [weak self] (response: Result<OAuthTokenResponseBody, Error>) in
            switch response {
            case .success(let body):
                let authToken = body.accessToken
                self?.storage.token = authToken
                completion(.success(authToken))
                self?.currentTask = nil
            case .failure(let error):
                completion(.failure(error))
                self?.lastCode = nil
            }
        }
    }
}

extension OAuth2Service {
    private func authTokenRequest(code: String) -> URLRequest? {
        guard let url = URL(string: configuration.baseURL.absoluteString) else {
            return nil
        }
        return builder.makeHTTPRequest(
            path: "\(configuration.baseAuthTokenPath)"
            + "?client_id=\(configuration.accessKey)"
            + "&&client_secret=\(configuration.secretKey)"
            + "&&redirect_uri=\(configuration.redirectURI)"
            + "&&code=\(code)"
            + "&&grant_type=authorization_code",
            httpMethod: "POST",
            baseURL: url
        )
    }
}
