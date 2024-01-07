import UIKit

final class ProfileService {
    static let shared = ProfileService()
    private (set) var profile: Profile?
    private var currentTask: URLSessionTask?
    private let builder: URLRequestBuilder
    
    init(builder: URLRequestBuilder = .shared){
        self.builder = builder
    }
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        currentTask?.cancel()
        
        guard let request = makeFetchProfileRequest(token: token) else {
            assertionFailure("Invalid request")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        let session = URLSession.shared
        currentTask = session.objectTask(for: request) {
            [weak self] (response: Result<ProfileResponse, Error>) in
            self?.currentTask = nil
            switch response {
            case .success(let profileResponse):
                let profile = Profile(result: profileResponse)
                completion(.success(profile))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func makeFetchProfileRequest (token: String) -> URLRequest? {
//        URLRequest.makeHTTPRequest(
        builder.makeHTTPRequest(
            path: "/me",
            httpMethod: "GET",
            baseURL: URL(string: Constants.defaultBaseURL)!
        )
        
    }
    
}

