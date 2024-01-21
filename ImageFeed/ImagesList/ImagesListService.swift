import UIKit

final class ImagesListService {
    
    static let shared = ImagesListService()
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    private let builder: URLRequestBuilder
    private (set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private var nextPage: Int = 0
    private var currentTask: URLSessionTask?
    
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
            [weak self] (response: Result<[PhotoResult], Error>) in
            self?.currentTask = nil
            switch response {
            case .success(let result):
                print("Result success")
                
                self?.lastLoadedPage = self?.nextPage
                
                var newPhotos: [Photo] = []
                result.forEach { photoResult in
                    newPhotos.append(Photo(result: photoResult))
                }
                self?.photos.append(contentsOf: newPhotos)
                
                completion(.success(newPhotos))
                
                NotificationCenter.default.post(
                    name: ImagesListService.didChangeNotification,
                    object: self
                )
                
            case .failure(let error):
                print("Result failed \(error)")
                
                completion(.failure(error))
            }
        }
    }
    
    func makePhotosRequest () -> URLRequest? {
        guard let url = URL(string: Constants.defaultBaseURL) else {
            return nil
        }
        return builder.makeHTTPRequest(
            path: "/photos?page=\(self.nextPage)&per_page=10",
            httpMethod: "GET",
            baseURL: url
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



//func requestNextQuestion() {
//    DispatchQueue.global().async { [weak self] in
//        guard let self = self else { return }
//        let index = (0..<self.movies.count).randomElement() ?? 0
//
//        guard let movie = self.movies[safe: index] else { return }
//
//        var imageData = Data()
//
//        do {
//            imageData = try Data(contentsOf: movie.resizedImageURL)
//        } catch {
//            print("Failed to load image")
//        }
//
//        let rating = Float(movie.rating) ?? 0
//        let ratingToCompare = (7...9).randomElement() ?? 9
//        let text = "Рейтинг этого фильма больше чем \(ratingToCompare)?"
//        let correctAnswer = rating > Float(ratingToCompare)
//
//        let question = QuizQuestion(image: imageData,
//                                    text: text,
//                                    correctAnswer: correctAnswer)
//
//        DispatchQueue.main.async { [weak self] in
//            guard let self = self else { return }
//            self.delegate?.didReceiveNextQuestion(question)
//        }
//    }
//}
//
//func loadData() {
//    moviesLoader.loadMovies { [weak self] result in
//
//        DispatchQueue.main.async {
//            guard let self = self else { return }
//            switch result {
//            case .success(let mostPopularMovies):
//                self.movies = mostPopularMovies.items
//                self.delegate?.didLoadDataFromServer()
//            case .failure(let error):
//                self.delegate?.didFailToLoadData(with: error)
//            }
//        }
//    }
//}
