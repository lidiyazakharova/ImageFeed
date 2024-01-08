import UIKit

final class ProfileService {
    static let shared = ProfileService()
    private (set) var profile: Profile?
    private var currentTask: URLSessionTask?
    private let builder: URLRequestBuilder
    
    init(builder: URLRequestBuilder = .shared){
        self.builder = builder
    }
    
    func fetchProfile(completion: @escaping (Result<Profile, Error>) -> Void) {
        currentTask?.cancel()
        
        guard let request = makeFetchProfileRequest() else {
            assertionFailure("Invalid request")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        let session = URLSession.shared
        currentTask = session.objectTask(for: request) {
            [weak self] (response: Result<ProfileResponse, Error>) in
            self?.currentTask = nil
            switch response {
            case .success(let profileResult):
                let profile = Profile(result: profileResult)
                self?.profile = profile
                completion(.success(profile))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func makeFetchProfileRequest () -> URLRequest? {
//        URLRequest.makeHTTPRequest(
        builder.makeHTTPRequest(
            path: "/me",
            httpMethod: "GET",
            baseURL: URL(string: Constants.defaultBaseURL)!
        )
        
    }
    
}

