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
        
        currentTask = fetchProfileResponse(request: request) { [weak self] response in
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
    
    
    func fetchProfileResponse (request: URLRequest, completion: @escaping (Result<ProfileResponse, Error>) -> Void) -> URLSessionTask {
        let fulfillCompletionOnMainThread: (Result<ProfileResponse, Error>) -> Void = { result in DispatchQueue.main.async {
            completion(result)
        }
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200 ..< 300 ~= statusCode {
                    do {
                        let decoder = JSONDecoder()
                        let result = try decoder.decode(ProfileResponse.self, from: data)
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
    
    func makeFetchProfileRequest (token: String) -> URLRequest? {
//        URLRequest.makeHTTPRequest(
        builder.makeHTTPRequest(
            path: "/me",
            httpMethod: "GET",
            baseURL: URL(string: Constants.defaultBaseURL)!
        )
        
    }
    
}

