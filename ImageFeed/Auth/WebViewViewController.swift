import UIKit
import WebKit

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

public protocol WebViewViewControllerProtocol: AnyObject {
    var presenter: WebViewPresenterProtocol? { get set }
    func load(request: URLRequest)
    func setProgressValue(_ newValue: Float)
    func setProgressHidden(_ isHidden: Bool)
}

final class WebViewViewController: UIViewController & WebViewViewControllerProtocol {
    
    var presenter: WebViewPresenterProtocol?
    weak var delegate: WebViewViewControllerDelegate?
    @IBOutlet private var webView: WKWebView!
    @IBOutlet private var progressView: UIProgressView!
    private var estimatedProgressObservation: NSKeyValueObservation?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return.lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.accessibilityIdentifier = "UnsplashWebView" 
//        progressView.progress = 0.0
        webView.navigationDelegate = self
        presenter?.viewDidLoad()
        
        estimatedProgressObservation = webView.observe(
            \.estimatedProgress,
             options: [],
             changeHandler: { [weak self] _,_ in
                 guard let self = self else { return }
                 self.presenter?.didUpdateProgressValue(self.webView.estimatedProgress)
             })
    }
    
    func load(request: URLRequest) {
        webView.load(request)
    }
    
    func setProgressValue(_ newValue: Float) {
        progressView.progress = newValue
    }
    
    func setProgressHidden(_ isHidden: Bool) {
        progressView.isHidden = isHidden
    }
    
    @IBAction private func didTapBackButton(_ sender: Any) {
        delegate?.webViewViewControllerDidCancel(self)
    }
    
}

extension WebViewViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = fetchCode(from: navigationAction) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    private func fetchCode(from navigationAction: WKNavigationAction) -> String? {
        if let url = navigationAction.request.url {
            return presenter?.fetchCode(from: url)
        }
        return nil
    }
    
    
}


//Добавьте уведомление презентера о том, что WebView обновил значение estimatedProgress. В методе observeValue(forKeyPath:of:change:context:) вьюконтроллера замените вызов updateProgress() на presenter?.didUpdateProgressValue(webView.estimatedProgress):
//override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//    if keyPath == #keyPath(WKWebView.estimatedProgress) {
//        presenter?.didUpdateProgressValue(webView.estimatedProgress)
//    } else {
//        super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
//    }
//}


//override func viewDidAppear(_ animated: Bool) {
//    super.viewDidAppear(animated)
//    // NOTE: Since the class is marked as `final` we don't need to pass a context.
//    // In case of inhertiance context must not be nil.
//    webView.addObserver(
//        self,
//        forKeyPath: #keyPath(WKWebView.estimatedProgress),
//        options: .new,
//        context: nil)
//}
//
//override func viewWillDisappear(_ animated: Bool) {
//    super.viewWillDisappear(animated)
//    webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), context: nil)
//}
//
//override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//    if keyPath == #keyPath(WKWebView.estimatedProgress) {
//        presenter?.didUpdateProgressValue(webView.estimatedProgress)
//    } else {
//        super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
//    }
//}
