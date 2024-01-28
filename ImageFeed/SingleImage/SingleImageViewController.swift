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
            let fullImageUrl = URL(string: photo.largeImageURL)
            
            imageView.kf.indicatorType = .activity
            //            imageView.kf.setImage(
            //                with: fullImageUrl,
            //                completionHandler: { result in
            //                    guard let image = self.imageView.image else { return }
            //
            //                    self.rescaleAndCenterImageInScrollView(image: image)
            //                }
            //            )
            
            UIBlockingProgressHUD.show()
            imageView.kf.setImage(
                with: fullImageUrl,
                completionHandler: { [weak self] result in
                    UIBlockingProgressHUD.dismiss()
                    guard let self = self else { return }
                    switch result {
                    case .success(let imageResult):
                        self.rescaleAndCenterImageInScrollView(image: imageResult.image)
                    case .failure (let error):
                        print("10")
                        self.showError(error: error) // добавить сообщение по ошибке
                        //                        Добавьте также функцию showError(), которая показывает алерт об ошибке с текстом «Что-то пошло не так. Попробовать ещё раз?» и с кнопками «Не надо» (скрывает алерт) и «Повторить» (повторно выполняет kt.setImage — используйте блок кода выше; его можно положить в отдельную функцию и вызвать её при нажатии на «Повторить»).
                    }
                    
                }
            )
        }
        
    }
    
    private var alertPresenter = AlertPresenter()
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return.lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alertPresenter.delegate = self
        //        imageView.image = image
        //        scrollView.minimumZoomScale = 0.1
        //        scrollView.maximumZoomScale = 1.25
        //        rescaleAndCenterImageInScrollView(image: image)
        
//        let imageUrl = URL(string: photo.largeImageURL)
//
//        imageView.kf.indicatorType = .activity
//
//        imageView.kf.setImage(
//            with: imageUrl,
//            completionHandler: { result in
//                guard let image = self.imageView.image else { return }
//
//                self.scrollView.minimumZoomScale = 0.1
//                self.scrollView.maximumZoomScale = 1.25
//                self.rescaleAndCenterImageInScrollView(image: image)
//            }
//        )
//    }

        let fullImageUrl = URL(string: photo.largeImageURL)
        
//        imageView.kf.indicatorType = .activity
        UIBlockingProgressHUD.show()
        imageView.kf.setImage(
            with: fullImageUrl,
            completionHandler: { [weak self] result in
                UIBlockingProgressHUD.dismiss()
                
                guard let self = self else { return }
                switch result {
                case .success(let imageResult):
                self.scrollView.minimumZoomScale = 0.1
                self.scrollView.maximumZoomScale = 1.25
                    self.rescaleAndCenterImageInScrollView(image: imageResult.image)
                case .failure(let error):
                        self.showError(error: error)
                    }
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
    
    private func showError (error: Error) {
        alertPresenter.showAlert(title: "Что-то пошло не так. Попробовать ещё раз?",
                                 message: "Попробовать ещё раз?, \(error.localizedDescription)") { [weak self] in
            guard let self = self else { return }
            // Что передавать?
            
        }
    }
}
extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}

