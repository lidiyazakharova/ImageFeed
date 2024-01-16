import UIKit

final class ImageListService {
    static let shared = ImageListService()
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    private let builder: URLRequestBuilder
    private (set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private var currentTask: URLSessionTask?
    
    init(builder: URLRequestBuilder = .shared){
        self.builder = builder
    }

func fetchPhotosNextPage (userName: String, completion: @escaping (Result<Photo, Error>) -> Void) {
    assert(Thread.isMainThread)
    currentTask?.cancel()
    
    guard let request = makePhotosRequest(userName: userName) else {
        assertionFailure("Invalid request")
        completion(.failure(NetworkError.invalidRequest))
        return
    }
    
//    let session = URLSession.shared
//    currentTask = session.objectTask(for: request) {
//        [weak self] (response: Result<Photo, Error>) in
//        self?.currentTask = nil
//
//        switch response {
//        case .success(let photoResult):
//            let photos = [Photo](result: photoResult)
//            self?.photos = photos
//            completion(.success(photoResult))
//
//                       NotificationCenter.default.post(
//                           name: ImageListService.didChangeNotification,
//                           object: self,
//                           userInfo: ["URL": mediumPhoto]) //ПОМЕНЯТЬ!!!
//        case .failure(let error):
//            completion(.failure(error))
//        }
//    }
    let nextPage = lastLoadedPage == nil ? 1 : lastLoadedPage! + 1//???
}

    func makePhotosRequest (userName: String) -> URLRequest? {
        builder.makeHTTPRequest(
            path: "/users/ \(userName)",
            httpMethod: "GET",
            baseURL: URL(string: Constants.defaultBaseURL)! // ПОМЕНЯТЬ Request
        )
    }
}

func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {}


//// Поиск индекса элемента
//if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
//    // Текущий элемент
//   let photo = self.photos[index]
//   // Копия элемента с инвертированным значением isLiked.
//   let newPhoto = Photo(
//            id: photo.id,
//            size: photo.size,
//            createdAt: photo.createdAt,
//            welcomeDescription: photo.welcomeDescription,
//            thumbImageURL: photo.thumbImageURL,
//            largeImageURL: photo.largeImageURL,
//            isLiked: !photo.isLiked
//        )
//    // Заменяем элемент в массиве.
//    self.photos = self.photos.withReplaced(itemAt: index, newValue: newPhoto)
//}

//extension ImagesListViewController: ImagesListCellDelegate {
//    
//    func imageListCellDidTapLike(_ cell: ImagesListCell) {
//    
//      guard let indexPath = tableView.indexPath(for: cell) else { return }
//      let photo = photos[indexPath.row]
//      // Покажем лоадер
//     UIBlockingProgressHUD.show()
//     imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { result in
//        switch result {
//        case .success:
//           // Синхронизируем массив картинок с сервисом
//           self.photos = self.imagesListService.photos
//           // Изменим индикацию лайка картинки
//           сell.setIsLiked(self.photos[indexPath.row].isLiked)
//           // Уберём лоадер
//           UIBlockingProgressHUD.dismiss()
//        case .failure:
//           // Уберём лоадер
//           UIBlockingProgressHUD.dismiss()
//           // Покажем, что что-то пошло не так
//           // TODO: Показать ошибку с использованием UIAlertController
//           }
//        }
//    }
//    
//} 


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
