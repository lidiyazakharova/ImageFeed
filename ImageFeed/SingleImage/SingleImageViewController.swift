import UIKit

final class SingleImageViewController: UIViewController {

    var image: UIImage! {
            didSet {
                guard isViewLoaded else { return } // 1
                imageView.image = image // 2
            }
        }
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
            super.viewDidLoad()
        
            imageView.image = image
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        
        }
    
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
} 
