@testable import ImageFeed
import XCTest

final class WebViewPresenterSpy: WebViewPresenterProtocol {
    var viewDidLoadCalled: Bool = false
    var view: WebViewViewControllerProtocol?

    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func didUpdateProgressValue(_ newValue: Double) {
    }

    func code(from url: URL) -> String? {
        return nil
    }
}

final class WebViewViewControllerSpy: WebViewViewControllerProtocol {
    var presenter: ImageFeed.WebViewPresenterProtocol?
    var loadRequestCalled: Bool = false

    func load(request: URLRequest) {
        loadRequestCalled = true
    }

    func setProgressValue(_ newValue: Float) {
    }

    func setProgressHidden(_ isHidden: Bool) {
    }
}

final class ImageFeedTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        // given
        let viewController = WebViewViewController()
        let presenter = WebViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        // when
        _ = viewController.view
        // then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }

    func testPresenterCallsLoadRequest() {
        // given
        let viewController = WebViewViewControllerSpy()
        let authHelper = AuthHelper(configuration: .standard)
        let presenter = WebViewPresenter(authHelper: authHelper)
        viewController.presenter = presenter
        presenter.view = viewController
        // when
        presenter.viewDidLoad()
        // then
        XCTAssertTrue(viewController.loadRequestCalled)
    }

    func testProgressVisibleWhenLessThenOne() {
        // given
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 0.6
        // when
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        // then
        XCTAssertFalse(shouldHideProgress)
    }

    func testProgressHiddenWhenOne() {
        // given
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 0.6
        // when
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        // then
        XCTAssertFalse(shouldHideProgress)
    }

    func testAuthHelperAuthURL() {
        // given
        let configuration = AuthConfiguration.standard
        let helper = AuthHelper(configuration: configuration)
        // when
        let urlString = helper.authRequest().url!.absoluteString
        // then
        XCTAssertTrue(urlString.contains(configuration.authURL.absoluteString))
        XCTAssertTrue(urlString.contains("oauth/authorize"))
        XCTAssertTrue(urlString.contains(configuration.accessKeys))
        XCTAssertTrue(urlString.contains(configuration.redirectURIS))
        XCTAssertTrue(urlString.contains("code"))
        XCTAssertTrue(urlString.contains(configuration.accessScopes))
    }

    func testCodeFromURL() {
        // given
        let helper = AuthHelper()
        var urlComponents = URLComponents(string: "https://unsplash.com/oauth/authorize/native")!
        urlComponents.queryItems = [
            URLQueryItem(name: "code", value: "test code")
        ]
        let url = urlComponents.url!
        // when
        let code = helper.code(from: url)
        // then
        XCTAssertEqual(code, "test code")
    }
}
