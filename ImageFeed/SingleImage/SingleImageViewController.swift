import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController {
    
    //MARK: - Private Properties
    var photo: Photo? = nil
    private var alertPresenter = AlertPresenter()
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    //MARK: - UIViewController
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return.lightContent
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        alertPresenter.delegate = self
        guard let largeImageURL = photo?.largeImageURL else { return }
        let fullImageUrl = URL(string: largeImageURL)
        setImage(imageView: imageView, url: fullImageUrl)
    }
    
    //MARK: - Private Functions
    private func setImage(imageView: UIImageView, url: URL?) {
        UIBlockingProgressHUD.show()
        imageView.kf.setImage(
            with: url,
            completionHandler: { [weak self] result in
                UIBlockingProgressHUD.dismiss()
                guard let self = self else { return }
                switch result {
                case .success(let imageResult):
                    self.scrollView.minimumZoomScale = 0.1
                    self.scrollView.maximumZoomScale = 1.25
                    self.rescaleAndCenterImageInScrollView(image: imageResult.image)
                case .failure(_):
                    self.alertPresenter.showError(repeatHandler: { [weak self] in
                        self?.setImage(imageView: imageView, url: url)
                    })
                }
            })
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

//MARK: - Extension
extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}

