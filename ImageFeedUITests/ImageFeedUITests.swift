import XCTest

let email = "your email"//ВНЕСТИ свой email
let password = "your password"//ВНЕСТИ свой passowrd
let profileName = "your name" //ВНЕСТИ свой Profile.name
let profileLogin = "your loginName"//ВНЕСТИ свой Profile.loginName


class ImageFeedUITests: XCTestCase {
    
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    func testAuth() throws {
        app.buttons["Authenticate"].tap()
        
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        
        loginTextField.tap()
        loginTextField.typeText(email)
        
        app.toolbars.buttons["Done"].tap()
        sleep(1)
        
        webView.swipeUp()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        
        passwordTextField.tap()
        passwordTextField.typeText(password)
        
        app.toolbars.buttons["Done"].tap()
        sleep(1)
        
        webView.swipeUp()
        
        webView.buttons["Login"].tap()
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
        
    }
    
    func testFeed() throws {
        let tablesQuery = app.tables
        
        let cell = tablesQuery.cells.element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5))

        cell.buttons["like button off"].tap()
        XCTAssertTrue(cell.buttons["like button on"].waitForExistence(timeout: 5))
        
        cell.buttons["like button on"].tap()
        XCTAssertTrue(cell.buttons["like button off"].waitForExistence(timeout: 5))

        cell.tap()

        sleep(2)

        let image = app.scrollViews.images.element(boundBy: 0)
        XCTAssertTrue(image.waitForExistence(timeout: 5))

        image.pinch(withScale: 3, velocity: 1)
        image.pinch(withScale: 0.5, velocity: -1)

        let navBackButtonWhiteButton = app.buttons["nav back button white"]
        XCTAssertTrue(navBackButtonWhiteButton.waitForExistence(timeout: 5))

        navBackButtonWhiteButton.tap()
    }
    
    func testProfile() throws {
        let textName = "textName"
        let textLogin = "textLogin"
        
        app.tabBars.buttons.element(boundBy: 1).tap()
        
        let labelName = app.staticTexts[textName]
        XCTAssertTrue(labelName.waitForExistence(timeout: 5))
        XCTAssertTrue(labelName.label == profileName)
        
        let labelLogin = app.staticTexts[textLogin]
        XCTAssertTrue(labelLogin.waitForExistence(timeout: 5))
        XCTAssertTrue(labelLogin.label == profileLogin)
        
        let logoutButton = app.buttons["logout button"]
        XCTAssertTrue(logoutButton.waitForExistence(timeout: 5))
        
        logoutButton.tap()
        
        let yesButton = app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Yes"]
        XCTAssertTrue(yesButton.waitForExistence(timeout: 5))
        
        yesButton.tap()
        
        sleep(3)
    }
}
