import XCTest

let email = "lidijaromanowa@gmail.com"
let password = "gataHkey_2018"

class ImageFeedUITests: XCTestCase {
    
    private let app = XCUIApplication() // переменная приложения
    
    override func setUpWithError() throws {
        //            Запуск приложения всегда выполняет функция override func setUpWithError() throws.
        continueAfterFailure = false // настройка выполнения тестов, которая прекратит выполнения тестов, если в тесте что-то пошло не так
        
        app.launch() // запускаем приложение перед каждым тестом
    }
    
    func testAuth() throws {
        // тестируем сценарий авторизации
        // Нажать кнопку авторизации
        /*
         У приложения мы получаем список кнопок на экране и получаем нужную кнопку по тексту на ней
         Далее вызываем функцию tap() для нажатия на этот элемент
         */
        app.buttons["Authenticate"].tap()
        //            button.accessibilityIdentifier = "Authenticate" если верстка кодом
        // Подождать, пока экран авторизации открывается и загружается
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        // Ввести данные в форму
        loginTextField.tap()
        loginTextField.typeText(email)
        webView.swipeUp()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        
        passwordTextField.tap()
        passwordTextField.typeText(password)
        webView.swipeUp()
        // Нажать кнопку логина
        webView.buttons["Login"].tap()
        // Подождать, пока открывается экран ленты
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
        
    }
    
    func testFeed() throws {
        // тестируем сценарий ленты
        let tablesQuery = app.tables

        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        cell.swipeUp()

        sleep(2)

        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)

        cellToLike.buttons["like button off"].tap()
        cellToLike.buttons["like button on"].tap()

        sleep(2)

        cellToLike.tap()

        sleep(2)

        let image = app.scrollViews.images.element(boundBy: 0)
        // Zoom in
        image.pinch(withScale: 3, velocity: 1) // zoom in
        // Zoom out
        image.pinch(withScale: 0.5, velocity: -1)

        let navBackButtonWhiteButton = app.buttons["nav back button white"]
        navBackButtonWhiteButton.tap()
    }
    
    func testProfile() throws {
        // тестируем сценарий профиля

        sleep(3)
//        app.tabBars.buttons.element(boundBy: 1).tap()

        XCTAssertTrue(app.staticTexts["Name Lastname"].exists)
        XCTAssertTrue(app.staticTexts["@username"].exists)

        app.buttons["logout button"].tap()

        app.alerts["Bye bye!"].scrollViews.otherElements.buttons["Yes"].tap()
    }
}


/*
 У приложения мы получаем список кнопок на экране и получаем нужную кнопку по тексту на ней
 Далее вызываем функцию tap() для нажатия на этот элемент
 */
//  app.buttons["Authenticate"].tap()
//Следующий шаг — работа с WebView. Это тоже пользовательский интерфейс, и тесты там работают точно так же: сначала нам надо найти на экране WebView, в нём — найти поля ввода, ввести туда наши данные и нажать кнопку входа. Для этого могут пригодиться функции:
//let webView = app.webViews["UnsplashWebView"] — вернёт нужный WebView по accessibilityIdentifier (не забудьте установить нашему WebView идентификатор так же, как и для кнопки);
//webView.waitForExistence(timeout: 5) — подождёт 5 секунд, пока WebView не появится;
//let loginTextField = webView.descendants(matching: .textField).element — найдёт поле для ввода логина;
//let passwordTextField = webView.descendants(matching: .secureTextField).element — найдёт поле для ввода пароля;
//loginTextField.typeText("Ваш e-mail") — введёт текст в поле ввода;
//webView.swipeUp() — поможет скрыть клавиатуру после ввода текста (необязательно, но иногда требуется для прохождения теста);
//print(app.debugDescription) — печатает в консоли дерево UI-элементов (пригодится для отладки и выявления проблем).



//Для автоматизации работы с лентой вам понадобятся новые полезные функции:
//let tablesQuery = app.tables — вернёт таблицы на экране;
//tablesQuery.children(matching: .cell).element(boundBy: 0) — вернёт ячейку по индексу 0;
//swipeUp() — метод поможет осуществить скроллинг;
//let image = app.scrollViews.images.element(boundBy: 0) — вернёт первую картинку на scrollView;
//image.pinch(withScale: 3, velocity: 1) — увеличит картинку;
//image.pinch(withScale: 0.5, velocity: -1) — уменьшит картинку.


//Для автоматизации шагов работы с профилем вам также пригодятся новые функции:
//app.tabBars.buttons.element(boundBy: 0).tap() — нажмёт таб с индексом 0 на TabBar;
//app.alerts["Alert"].scrollViews.otherElements.buttons["OK"].tap() — нажмёт кнопку «ОК» на алерте с заголовком "Alert";
//app.staticTexts["Text"].exists — поле exists подскажет, существует ли такой текст на экране.



















//    override func setUpWithError() throws {
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//
//        // In UI tests it is usually best to stop immediately when a failure occurs.
//        continueAfterFailure = false
//
//        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
//    }
//
//    override func tearDownWithError() throws {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//    }
//
//    func testExample() throws {
//        // UI tests must launch the application that they test.
//        let app = XCUIApplication()
//        app.launch()
//
//        // Use XCTAssert and related functions to verify your tests produce the correct results.
//    }
//
//    func testLaunchPerformance() throws {
//        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
//            // This measures how long it takes to launch your application.
//            measure(metrics: [XCTApplicationLaunchMetric()]) {
//                XCUIApplication().launch()
//            }
//        }
//    }
//}
