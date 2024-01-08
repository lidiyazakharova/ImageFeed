import Foundation

final class ProfileImageService {
    static let shared = ProfileImageService()
    private (set) var profile: Profile?
    private var currentTask: URLSessionTask?
    private let builder: URLRequestBuilder
    
    init(builder: URLRequestBuilder = .shared){
        self.builder = builder
    }
    
    func fetchProfileImage(_ token: String, completion: @escaping (Result<ProfileImage, Error>) -> Void) {
//        currentTask?.cancel()
//
//        guard let request = makeFetchProfileRequest(token: token) else {
//            assertionFailure("Invalid request")
//            completion(.failure(NetworkError.invalidRequest))
//            return
//        }
//
//        let session = URLSession.shared
//        currentTask = session.objectTask(for: request) {
//            [weak self] (response: Result<ProfileImage, Error>) in
//            self?.currentTask = nil
//            switch response {
//            case .success(let profileImage):
//                let profile = Profile(result: profileImage)
//                completion(.success(profile))
//            case .failure(let error):
//                completion(.failure(error))
//            }
//        }
    }
    
    func makeFetchProfileRequest (token: String) -> URLRequest? {
        builder.makeHTTPRequest(
            path: "/me",
            httpMethod: "GET",
            baseURL: URL(string: Constants.defaultBaseURL)!
        )
        
    }
    
}

