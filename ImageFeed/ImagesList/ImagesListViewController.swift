import UIKit

final class ImagesListViewController: UIViewController {
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private let imageListService = ImagesListService.shared
    @IBOutlet private var tableView: UITableView!
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    private let photosName: [String] = Array(0..<20).map{ "\($0)" }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return.lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
//        profileImageServiceObserver = NotificationCenter.default.addObserver(
//            forName: ProfileImageService.didChangeNotification,
//            object: nil,
//            queue: .main
//        ) { [weak self] _ in
//            guard let self = self else { return }
//            self.updateAvatar()
//        }
//        updateAvatar()
//    }
//
//    private func updateAvatar() {
//        guard let profileImageURL = ProfileImageService.shared.avatarURL
//        else { return }
//
//        let processor = RoundCornerImageProcessor(cornerRadius: 50)
//        avatarImage.kf.indicatorType = .activity
//        avatarImage.kf.setImage(with: profileImageURL, options: [.processor(processor)])
//    }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            let viewController = segue.destination as! SingleImageViewController
            let indexPath = sender as! IndexPath
            let image = UIImage(named: photosName[indexPath.row])
            viewController.image = image
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photosName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath)
    
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        configCell(for: imageListCell, with: indexPath)
       // imageListCell.fetchPhotosNextPage(userName: user, completion: <#T##(Result<Photo, Error>) -> Void#>)
        // добавить проверку на current task
        
//        Метод tableView(_:, willDisplay:, forRowAt:) вызывается прямо перед тем, как ячейка таблицы будет показана на экране. В этом методе можно проверить условие indexPath.row + 1 == photos.count, и если оно верно — вызывать fetchPhotosNextPage().
//        Отметим, что этот метод может вызываться для одной и той же ячейки множество раз (иногда десятки раз). Поэтому нужно сделать так, чтобы многократные вызовы fetchPhotosNextPage() были «дешёвыми» по ресурсам и не приводили к прерыванию текущего сетевого запроса.
        
        return imageListCell
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = UIImage(named: photosName[indexPath.row]) else {
            return 0
        }
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = image.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = image.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print("Row index \(indexPath)")
        
        if indexPath.row + 1 == imageListService.photos.count || imageListService.photos.count == 0 {
            imageListService.fetchPhotosNextPage() { result in
                print("Result success or nor hz")
            }
        }
    }
}

extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard let image = UIImage(named: photosName[indexPath.row]) else {
            return
        }
        
        cell.cellImage.image = image
        cell.dateLabel.text = dateFormatter.string(from: Date())
        cell.gradient.layer.cornerRadius = 16
        cell.gradient.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        
        let isLiked = indexPath.row % 2 == 0
        let likeImage = isLiked ? UIImage(named: "likeActive") : UIImage(named: "likeNoActive")
        cell.likeButton.setImage(likeImage, for: .normal)
    }
}
