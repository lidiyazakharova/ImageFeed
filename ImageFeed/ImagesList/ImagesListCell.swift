import UIKit

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    
    static let reuseIdentifier = "ImagesListCell"
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var gradient: GradientView!
    weak var delegate: ImagesListCellDelegate? 
 
    @IBAction private func likeButtonClicked(_ sender: Any) {
        delegate?.imageListCellDidTapLike(self)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.kf.cancelDownloadTask()
    }
}

extension ImagesListCell {
    func setIsLiked(_ state: Bool) {
        likeButton.setImage(
            state
            ? UIImage(named: "likeActive")
            : UIImage(named: "likeNoActive"),
            for: .normal
        )
        
        if(state) {
            likeButton.accessibilityIdentifier = "like button on"
        } else {
            likeButton.accessibilityIdentifier = "like button off"
        }
    }
    
    @objc func likeButtonClicked() {
        delegate?.imageListCellDidTapLike(self)
    }
}
