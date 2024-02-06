import Foundation

public protocol ImageListViewPresenterProtocol: AnyObject {
    func viewDidLoad()
    func getPhotos() -> [Photo]
    func changePhotoLike(photoIndex: IndexPath)
    func fetchPhotosNextPage()
}

final class ImageListViewPresenter: ImageListViewPresenterProtocol {
    weak var view: ImageListViewControllerProtocol?
    
    private var imageListServiceObserver: NSObjectProtocol?
    private let imagesListService = ImagesListService.shared
    private var photos: [Photo] = []
    
    func viewDidLoad() {
        imageListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            self.changeCount()
        }
        self.fetchPhotosNextPage()
//        imagesListService.fetchPhotosNextPage{result in}
        
//        photo = imagesListService.photos[indexPath.row]
    }
    
    func getPhotos() -> [Photo] {
        return imagesListService.photos
    }
    
    func changePhotoLike(photoIndex: IndexPath) {
        let photo = getPhotos()[photoIndex.row]
        
        view?.changeBlockingProgressHUD(visible: true)
        
        imagesListService.changeLike(photoId: photo.id,
                                     isLike: !photo.isLiked) { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            case .success:
                let newPhoto = Photo(id: photo.id,
                                     size: photo.size,
                                     createdAt: photo.createdAt,
                                     welcomeDescription: photo.welcomeDescription,
                                     thumbImageURL: photo.thumbImageURL,
                                     largeImageURL: photo.largeImageURL,
                                     isLiked: !photo.isLiked)
                self.imagesListService.photos[photoIndex.row] = newPhoto
                self.photos = self.imagesListService.photos
                
                self.view?.updateCellLikeStatus(cellIndex: photoIndex, isLiked: newPhoto.isLiked)
                self.view?.changeBlockingProgressHUD(visible: false)
            case .failure(let error):
                self.view?.changeBlockingProgressHUD(visible: false)
                self.view?.showLikeAlert(error: error)
            }
        }
    }
    
    func fetchPhotosNextPage() {
        imagesListService.fetchPhotosNextPage{result in}
    }
    
    func changeCount() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        
        photos = imagesListService.photos
        
        view?.updateTableViewAnimated(oldCount: oldCount, newCount: newCount)
    }
}
