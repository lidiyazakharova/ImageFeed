import Foundation

final class ProfileImageService {
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    private var currentTask: URLSessionTask?
    private (set) var avatarURL: URL?
    private let builder: URLRequestBuilder
    
    private init(builder: URLRequestBuilder = .shared){
        self.builder = builder
    }
    
    func fetchProfileImageURL(userName: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard let request = makeImageRequest(userName: userName) else { return }
        let session = URLSession.shared
        let task = session.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self = self else { return }
            switch result {
            case.success(let profilePhoto):
                guard let mediumPhoto = profilePhoto.profileImage?.medium else { return }
                self.avatarURL = URL(string: mediumPhoto)
                completion(.success(mediumPhoto))
                
                NotificationCenter.default.post(
                    name: ProfileImageService.didChangeNotification,
                    object: self,
                    userInfo: ["URL": mediumPhoto]
                )
                
            case.failure(let error):
                completion(.failure(error))
            }
            self.currentTask = nil
        }
        self.currentTask = task
        task.resume()
    }
    
   private func makeImageRequest (userName: String) -> URLRequest? {
        guard let url = URL(string: Constants.defaultBaseURL) else {
            return nil
        }
        return builder.makeHTTPRequest(
            path: "/users/\(userName)",
            httpMethod: "GET",
            baseURL: url
        )
    }
}
