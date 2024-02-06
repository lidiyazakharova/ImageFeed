@testable import ImageFeed
import Foundation
import XCTest

final class ProfileViewPresenterSpy: ProfileViewPresenterProtocol {
    var viewDidLoadCalled: Bool = false
    var viewWillAppearCalled: Bool = false
    var view: ProfileViewControllerProtocol?
    let presentName = "Lidia Zakharova"
    let presentLogin = "@lidiyazak"
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func removeData() {
    }
    
    func viewWillAppear() {
        viewWillAppearCalled = true
    }
}

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: ImageFeed.ProfileViewPresenterProtocol?
    var updateAvatarCalled = false
    
    func updateAvatar(url: URL) {
        updateAvatarCalled = true
    }
    func updateProfileInfo(name: String, bio: String?, loginName: String) {}
    
}

class ProfileViewTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad() {
        //given
        let viewController = ProfileViewController()
        let presenter = ProfileViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        //when
        _ = viewController.view
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled) //behaviour verification
    }
    
    func testViewControllerCallsViewWillAppear() {
        //given
        let viewController = ProfileViewController()
        let presenter = ProfileViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        //when
        viewController.viewWillAppear(false)
        
        //then
        XCTAssertTrue(presenter.viewWillAppearCalled) //behaviour verification
    }
    
    func testPresenterCallsUpdateAvatar() {
        //given
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfileViewPresenter()
        viewController.presenter = presenter
        presenter.view = viewController
        //when
        presenter.viewWillAppear()
        
        //then
        XCTAssertTrue(viewController.updateAvatarCalled) //behaviour verification
    }
    
    func testProfileInfoUpdate() {
        //given
        let viewController = ProfileViewController()
        let presenter = ProfileViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        viewController.updateProfileInfo(
            name: "Lidia Zakharova",
            bio: nil,
            loginName: "@lidiyazak")
        
        //then
        XCTAssertTrue(viewController.nameLabel.text == presenter.presentName)
        XCTAssertTrue(viewController.loginNameLabel.text == presenter.presentLogin)
    }
    
}
