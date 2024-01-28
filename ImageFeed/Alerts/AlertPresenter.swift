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
    
    func showConfirmLogoutAlert(yesHandler: @escaping() -> Void) {
        let alert = UIAlertController(title: "Пока, пока!",
                                      message: "Вы уверены, что хотите выйти?",
                                      preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Да", style: .default) { _ in
            yesHandler()
        }
        let noAction = UIAlertAction(title: "Нет", style: .default) { _ in }
        
        alert.addAction(yesAction)
        alert.addAction(noAction)
        delegate?.present(alert, animated: true)
    }
}
