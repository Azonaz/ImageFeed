import XCTest

final class ImageFeedUITests: XCTestCase {
    let login = "ya-azonaz@yandex.ru"
    let password = "12345678"
    let userName = "Ana Mal"
    let loginName = "@azonazya"

    private let app = XCUIApplication() // переменная приложения

    override func setUpWithError() throws {
        continueAfterFailure = false // настройка, которая прекратит выполнение тестов, если в них что-то пошло не так
        app.launch() // запускаем приложение перед каждым тестом
    }

    func testAuth() throws {
        // тестируем сценарий авторизации
        app.buttons["Authenticate"].tap()

        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 5))

        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(webView.waitForExistence(timeout: 3))
        loginTextField.tap()
        loginTextField.typeText(login)

        webView.swipeUp()

        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(webView.waitForExistence(timeout: 3))
        passwordTextField.tap()
        passwordTextField.typeText(password)
        XCTAssertTrue(webView.waitForExistence(timeout: 1))

        let loginButton = webView.descendants(matching: .button).element
        XCTAssertTrue(webView.waitForExistence(timeout: 1))
        loginButton.tap()

        let tableView = app.tables
        let cell = tableView.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }

    func testFeed() throws {
        // тестируем сценарий ленты
        let tableView = app.tables
        let cell = tableView.children(matching: .cell).element(boundBy: 0)
        cell.swipeUp()
        XCTAssertTrue(app.waitForExistence(timeout: 3))

        let cellToLike = tableView.children(matching: .cell).element(boundBy: 1)
        let likeButton = cellToLike.buttons["LikeButton"]
        likeButton.tap()
        XCTAssertTrue(likeButton.waitForExistence(timeout: 7))
        likeButton.tap()
        XCTAssertTrue(likeButton.waitForExistence(timeout: 7))

        cell.tap()
        sleep(3)

        let image = app.scrollViews.images.element(boundBy: 0)
        image.pinch(withScale: 3, velocity: 1)
        image.pinch(withScale: 0.5, velocity: -1)

        let backButton = app.buttons["BackButton"]
        backButton.tap()
        XCTAssertTrue(likeButton.waitForExistence(timeout: 3))
    }

    func testProfile() throws {
        // тестируем сценарий профиля
        let tablesQuery = app.tables
        _ = tablesQuery.children(matching: .cell).element(boundBy: 0)
        sleep(5)

        app.tabBars.buttons.element(boundBy: 1).tap()
        sleep(3)

        XCTAssertTrue(app.staticTexts[userName].exists)
        XCTAssertTrue(app.staticTexts[loginName].exists)
        sleep(3)

        app.buttons["Logout"].tap()

        _ = app.webViews["UnsplashWebView"]
    }
}
