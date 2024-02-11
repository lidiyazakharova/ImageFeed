import UIKit

final class ProfileService {
    static let shared = ProfileService()
    let configuration: AuthConfiguration
    private (set) var profile: Profile?
    private var currentTask: URLSessionTask?
    private let builder: URLRequestBuilder
    
    private init(builder: URLRequestBuilder = .shared,
                 configuration: AuthConfiguration = .standard){
        self.builder = builder
        self.configuration = configuration
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
            [weak self] (response: Result<ProfileResult, Error>) in
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
    
  private func makeFetchProfileRequest () -> URLRequest? {
      guard let url = URL(string: configuration.defaultBaseURL.absoluteString) else {
            return nil
        }
        
        return builder.makeHTTPRequest(
            path: "/me",
            httpMethod: "GET",
            baseURL: url
        )
    }
}

