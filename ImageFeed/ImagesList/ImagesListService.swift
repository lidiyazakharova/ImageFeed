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
//                print("Result success")
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
                print("Result failed \(error)")// убрать ошибку
                
                completion(.failure(error))
            }
//            print(self?.photos.count)
        }
    }
    
    func makePhotosRequest () -> URLRequest? {
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
        print("Change like")
        
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
                print("Like success")
                completion(.success(Void()))
                
            case .failure(let error):
                print("Result failed \(error)")// убрать ошибку
                
                completion(.failure(error))
            }
        }
        
        // Поиск индекса элемента
//        if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
            // Текущий элемент
//           let photo = self.photos[index]
           // Копия элемента с инвертированным значением isLiked.
//           let newPhoto = Photo(
//                    id: photo.id,
//                    size: photo.size,
//                    createdAt: photo.createdAt,
//                    welcomeDescription: photo.welcomeDescription,
//                    thumbImageURL: photo.thumbImageURL,
//                    largeImageURL: photo.largeImageURL,
//                    isLiked: !photo.isLiked
//                )
            // Заменяем элемент в массиве.
//            self.photos = self.photos.withReplaced(itemAt: index, newValue: newPhoto)
//        }
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














//
//Управление загрузкой включает ответ на вопросы:
//какую страницу загружать?
//идёт ли сейчас загрузка или нужно создать новый сетевой запрос?
//Управление массивом photos:
//из какого потока обновлять массив (можно ли из фонового или это должен быть main)?
//каким образом его обновлять, когда получен ответ от очередного сетевого запроса?

//!Добавить свойство task: URLSessionTask? (сохраняем в нём результат urlSession.objectTask), и если task != nil, то сетевой запрос в прогрессе.

//!Так как читать массив photos мы будем из main — в методе, реализующем UITableViewDataSource, то и обновление массива должно быть в потоке main.

//!Добавить новые фотографии в конец массива photos


// перенести в другой файл
//func tableView(
//  _ tableView: UITableView,
//  willDisplay cell: UITableViewCell,
//  forRowAt indexPath: IndexPath
//) {
//    // ...
//}
//Метод tableView(_:, willDisplay:, forRowAt:) вызывается прямо перед тем, как ячейка таблицы будет показана на экране. В этом методе можно проверить условие indexPath.row + 1 == photos.count, и если оно верно — вызывать fetchPhotosNextPage().
//



