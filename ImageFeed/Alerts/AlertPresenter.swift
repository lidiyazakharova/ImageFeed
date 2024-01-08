import UIKit

final class AlertPresenter {
    
    weak var delegate: UIViewController?
    
    init(delegate: UIViewController? = nil) {
        self.delegate = delegate
    }
    
    func showAlert(title: String, message: String, handler: @escaping() -> Void) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default) { _ in
            handler()
        }
        alert.addAction(alertAction)
        delegate?.present(alert, animated: true)
    }
}

//import Foundation
//
//struct AlertModel {
//    let title: String
//    let message: String
//    let buttonText: String
//    let buttonAction: () -> Void
//}

//protocol AlertPresenter {
//    func show(alertModel: AlertModel)
//}
//
//final class AlertPresenterImplementation{
//    private weak var viewControllerDelegate: UIViewController?
//
//    init(viewControllerDelegate: UIViewController? = nil) {
//        self.viewControllerDelegate = viewControllerDelegate
//    }
//}
//
//extension AlertPresenterImplementation: AlertPresenter {
//    func show(alertModel: AlertModel) {
//        let alert = UIAlertController(
//            title: alertModel.title,
//            message: alertModel.message,
//            preferredStyle: .alert)
//
//        alert.view.accessibilityIdentifier = "Game results"
//
//        let action = UIAlertAction(title: alertModel.buttonText, style: .default) { _ in
//            alertModel.buttonAction()
//        }
//
//        alert.addAction(action)
//
//        viewControllerDelegate?.present(alert, animated: true)
//    }
//}
