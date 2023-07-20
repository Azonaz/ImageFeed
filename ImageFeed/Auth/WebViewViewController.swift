import UIKit
import WebKit

public protocol WebViewViewControllerProtocol: AnyObject {
    var presenter: WebViewPresenterProtocol? { get set }
    func load(request: URLRequest)
    func setProgressValue(_ newValue: Float)
    func setProgressHidden(_ isHidden: Bool)
}

final class WebViewViewController: UIViewController & WebViewViewControllerProtocol {

    @IBOutlet private weak var webView: WKWebView!
    @IBOutlet private weak var progressView: UIProgressView!

    var presenter: WebViewPresenterProtocol?
    weak var delegate: WebViewViewControllerDelegate?
    private var estimatedProgressObservation: NSKeyValueObservation?

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        webView.accessibilityIdentifier = "UnsplashWebView"
 //       progressView.progress = 0
        webView.navigationDelegate = self
        presenter?.viewDidLoad()
        estimatedProgressObservation = webView.observe(
            \.estimatedProgress,
             options: [],
             changeHandler: { [weak self] _, _ in
                 guard let self else { return }
                 //self.updateProgress()
                 self.presenter?.didUpdateProgressValue(self.webView.estimatedProgress)
             })
    }

    func setProgressValue(_ newValue: Float) {
        progressView.progress = newValue
    }

    func setProgressHidden(_ isHidden: Bool) {
        progressView.isHidden = isHidden
    }
    
//    private func updateProgress() {
//        let progress = Float(webView.estimatedProgress)
//        progressView.setProgress(progress, animated: false)
//        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
//    }

    func load(request: URLRequest) {
        webView.load(request)
    }

    @IBAction private func didTapBackButton(_ sender: Any?) {
        delegate?.webViewViewControllerDidCancel(self)
    }
}

extension WebViewViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = code(from: navigationAction) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }

    private func code(from navigationAction: WKNavigationAction) -> String? {
        if let url = navigationAction.request.url {
                return presenter?.code(from: url)
        } else {
            return nil
        }
    }

    static func cleanData() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes,
                                                        for: [record], completionHandler: { })
            }
        }
    }
}
