import UIKit

//protocol ImagesListViewController: ImagesListCellDelegate {
//    func imageListCellDidTapLike(_ cell: ImagesListCell)
//}

final class ImagesListViewController: UIViewController {
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private let imagesListService = ImagesListService.shared
    @IBOutlet private var tableView: UITableView!
    private var imageListServiceObserver: NSObjectProtocol?
    private var alertPresenter = AlertPresenter()
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
//    private let photosName: [String] = Array(0..<20).map{ "\($0)" }
    private var photos: [Photo] = []
    
    weak var delegate: ImagesListCellDelegate?
 
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return.lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alertPresenter.delegate = self
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        imagesListService.fetchPhotosNextPage{result in}
        
        imageListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            self.updateTableViewAnimated()
        }
    }
//    private func updateTableViewAnimated() {
//        tableView.reloadData()
//    }
    
   private func updateTableViewAnimated() {
       let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
//   //использовать вместо map
//    var indexPaths: [IndexPath] = []
//    for i in oldCount..<newCount {
//        indexPaths.append(IndexPath(row: i, section: 0))
//    }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            let viewController = segue.destination as! SingleImageViewController
            let indexPath = sender as! IndexPath
//            let image = UIImage(named: photosName[indexPath.row])
//            viewController.image = image
            
            viewController.photo = imagesListService.photos[indexPath.row]
//            print("10")
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ImagesListService.shared.photos.count
//        return photosName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
//        cell.delegate = self
        
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        guard let image = UIImage(named: photosName[indexPath.row]) else {
//            return 0
//        }
//        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
//        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
//        let imageWidth = image.size.width
//        let scale = imageViewWidth / imageWidth
//        let cellHeight = image.size.height * scale + imageInsets.top + imageInsets.bottom
//        return cellHeight
//    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print("Row index \(indexPath)")
        
        if indexPath.row + 1 == imagesListService.photos.count || imagesListService.photos.count == 0 {
            imagesListService.fetchPhotosNextPage() { result in }
        }
    }
}


extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard indexPath.row < ImagesListService.shared.photos.count else { return }
        
        let photo = ImagesListService.shared.photos[indexPath.row]
        let imageUrl = URL(string: photo.thumbImageURL)
        
        cell.cellImage.kf.indicatorType = .activity
        cell.cellImage.kf.setImage(
            with: imageUrl,
            placeholder: UIImage(named: "stub_card"),
            completionHandler: { result in
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        )
        cell.dateLabel.text = dateFormatter.string(from: photo.createdAt!)
        cell.gradient.layer.cornerRadius = 16
        cell.gradient.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        
        let likeImage = photo.isLiked ? UIImage(named: "likeActive") : UIImage(named: "likeNoActive")
        cell.likeButton.setImage(likeImage, for: .normal)
        
        cell.delegate = self
        
//        guard let image = UIImage(named: photosName[indexPath.row]) else {
//            return
//        }
//
//        cell.cellImage.image = image
//        cell.dateLabel.text = dateFormatter.string(from: Date())
//        cell.gradient.layer.cornerRadius = 16
//        cell.gradient.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
//
//        let isLiked = indexPath.row % 2 == 0
//        let likeImage = isLiked ? UIImage(named: "likeActive") : UIImage(named: "likeNoActive")
//        cell.likeButton.setImage(likeImage, for: .normal)
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        // Покажем лоадер
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { result in
            switch result {
            case .success:
                let newPhoto = Photo(id: photo.id, size: photo.size, createdAt: photo.createdAt, welcomeDescription: photo.welcomeDescription, thumbImageURL: photo.thumbImageURL, largeImageURL: photo.largeImageURL, isLiked: !photo.isLiked)
                
                self.imagesListService.photos[indexPath.row] = newPhoto
                // Синхронизируем массив картинок с сервисом
                self.photos = self.imagesListService.photos
                // Изменим индикацию лайка картинки
                cell.setIsLiked(self.photos[indexPath.row].isLiked)
                // Уберём лоадер
                UIBlockingProgressHUD.dismiss()
            case .failure(let error):
                // Уберём лоадер
                UIBlockingProgressHUD.dismiss()
                // Покажем, что что-то пошло не так
                // TODO: Показать ошибку с использованием UIAlertController
                self.showLikeAlert(error: error)
            }
        }
    }
    private func showLikeAlert(error: Error) {
        alertPresenter.showAlert(title: "Что-то пошло не так :(",
                                 message: "Не удалось сохранить like, \(error.localizedDescription)") {}
    }
}


