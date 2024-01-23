import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController {
    
//    var image: UIImage! {
//        didSet {
//            guard isViewLoaded else { return }
//            imageView.image = image
//            rescaleAndCenterImageInScrollView(image: image)
//        }
//    }
    
    var photo: Photo! {
        didSet {
            guard isViewLoaded else { return }
            let imageUrl = URL(string: photo.largeImageURL)
            
            imageView.kf.indicatorType = .activity
            imageView.kf.setImage(
                with: imageUrl,
                completionHandler: { result in
                    guard let image = self.imageView.image else { return }
                    
                    self.rescaleAndCenterImageInScrollView(image: image)
                }
            )
        }
    }
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return.lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        imageView.image = image
//        scrollView.minimumZoomScale = 0.1
//        scrollView.maximumZoomScale = 1.25
//        rescaleAndCenterImageInScrollView(image: image)
        
        let imageUrl = URL(string: photo.largeImageURL)
        
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(
            with: imageUrl,
            completionHandler: { result in
                guard let image = self.imageView.image else { return }
                
                self.scrollView.minimumZoomScale = 0.1
                self.scrollView.maximumZoomScale = 1.25
                self.rescaleAndCenterImageInScrollView(image: image)
            }
        )
    }
    
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapShareButton(_ sender: UIButton) {
        guard let image = imageView.image else { return }
        
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(share, animated: true, completion: nil)
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, max(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}

