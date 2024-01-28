import UIKit

final class ImagesListService {
    
    static let shared = ImagesListService()
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    private let builder: URLRequestBuilder
    var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private var nextPage: Int = 0
    private var currentTask: URLSessionTask?
    private var changeLikeTask: URLSessionTask?
    private let perPage = 10
    
    private init(builder: URLRequestBuilder = .shared){
        self.builder = builder
    }
    
    func fetchPhotosNextPage(completion: @escaping (Result<[Photo], Error>) -> Void) {
        guard currentTask == nil else { return }
        
        nextPage = lastLoadedPage == nil ? 1 : lastLoadedPage! + 1
        
        assert(Thread.isMainThread)
        
        guard let request = makePhotosRequest() else {
            assertionFailure("Invalid request")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        let session = URLSession.shared
        currentTask = session.objectTask(for: request) {
            [weak self] (result: Result<[PhotoResult], Error>) in
            self?.currentTask = nil
            switch result {
                
            case .success(let photoResult):
                self?.lastLoadedPage = self?.nextPage
                var newPhotos: [Photo] = []
                photoResult.forEach { photoResult in
                    newPhotos.append(Photo(result: photoResult))
                }
                self?.photos.append(contentsOf: newPhotos)
                completion(.success(newPhotos))
                NotificationCenter.default.post(
                    name: ImagesListService.didChangeNotification,
                    object: self
                )
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func makePhotosRequest () -> URLRequest? {
        guard let url = URL(string: Constants.defaultBaseURL) else {
            return nil
        }
        return builder.makeHTTPRequest(
            path: "/photos?page=\(self.nextPage)&per_page=1\(perPage)",
            httpMethod: "GET",
            baseURL: url
        )
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        
        var request: URLRequest?
        if isLike {
            request = makeLikeRequest(photoId: photoId)
        } else {
            request = makeDeleteLikeRequest(photoId: photoId)
        }
        
        guard let request = request else {
            assertionFailure("Invalid request")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        let session = URLSession.shared
        changeLikeTask = session.objectTask(for: request) {
            (result: Result<SinglePhotoResult, Error>) in
            switch result {
            case .success:
                completion(.success(Void()))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func makeLikeRequest(photoId: String) -> URLRequest? {
        guard let url = URL(string: Constants.defaultBaseURL) else {
            return nil
        }
        return builder.makeHTTPRequest(
            path: "/photos/\(photoId)/like",
            httpMethod: "POST",
            baseURL: url
        )
    }
    
    private func makeDeleteLikeRequest(photoId: String) -> URLRequest? {
        guard let url = URL(string: Constants.defaultBaseURL) else {
            return nil
        }
        return builder.makeHTTPRequest(
            path: "/photos/\(photoId)/like",
            httpMethod: "DELETE",
            baseURL: url
        )
    }
}
