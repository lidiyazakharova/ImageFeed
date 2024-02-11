import UIKit

public protocol ImageListViewControllerProtocol: AnyObject {
    func updateTableViewAnimated(oldCount: Int, newCount: Int)
    func changeBlockingProgressHUD(visible: Bool)
    func showLikeAlert(error: Error)
    func updateCellLikeStatus(cellIndex: IndexPath, isLiked: Bool)
}

final class ImagesListViewController: UIViewController & ImageListViewControllerProtocol {
    
    var presenter: ImageListViewPresenterProtocol?
    weak var delegate: ImagesListCellDelegate?
    
    //MARK: - Private Properties
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    @IBOutlet private var tableView: UITableView!
    private var alertPresenter = AlertPresenter()
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    
    //MARK: - UIViewController
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return.lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alertPresenter.delegate = self
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        presenter?.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            let viewController = segue.destination as? SingleImageViewController
            guard let indexPath = sender as? IndexPath else { return }
            viewController?.photo = presenter?.getPhotos()[indexPath.row]
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    //MARK: - Private Functions
    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
    
    func changeBlockingProgressHUD(visible: Bool) {
        if(visible) {
            UIBlockingProgressHUD.show()
        } else {
            UIBlockingProgressHUD.dismiss()
        }
    }
}

//MARK: - Extension
extension ImagesListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.getPhotos().count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath)
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let photosCount = presenter?.getPhotos().count ?? 0
        
        if indexPath.row + 1 == photosCount || photosCount == 0 {
            presenter?.fetchPhotosNextPage()
        }
    }
}

extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard indexPath.row < (presenter?.getPhotos().count ?? 0) else { return }
        guard let photo = presenter?.getPhotos()[indexPath.row] else { return }
        
        let imageUrl = URL(string: photo.thumbImageURL)
        cell.cellImage.kf.indicatorType = .activity
        cell.cellImage.kf.setImage(
            with: imageUrl,
            placeholder: UIImage(named: "stub_card"),
            completionHandler: { [weak self] result in
                self?.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        )
        cell.dateLabel.text = dateFormatter.string(from: photo.createdAt!)
        cell.gradient.layer.cornerRadius = 16
        cell.gradient.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        let likeImage = photo.isLiked ? UIImage(named: "likeActive") : UIImage(named: "likeNoActive")
        cell.likeButton.setImage(likeImage, for: .normal)
        
        if(photo.isLiked) {
            cell.likeButton.accessibilityIdentifier = "like button on"
        } else {
            cell.likeButton.accessibilityIdentifier = "like button off"
        }
        
        cell.delegate = self
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        presenter?.changePhotoLike(photoIndex: indexPath)
    }
    
    func updateCellLikeStatus(cellIndex: IndexPath, isLiked: Bool) {
        guard let cell = tableView.cellForRow(at: cellIndex) else { return }
        guard let imageCell = cell as? ImagesListCell else { return }
        imageCell.setIsLiked(isLiked)
    }
    
    func showLikeAlert(error: Error) {
        alertPresenter.showAlert(title: "Что-то пошло не так :(",
                                 message: "Не удалось сохранить like, \(error.localizedDescription)") {}
    }
}


