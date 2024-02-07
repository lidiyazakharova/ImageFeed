@testable import ImageFeed
import Foundation
import XCTest

final class ProfileViewPresenterSpy: ProfileViewPresenterProtocol {
    var viewDidLoadCalled: Bool = false
    var viewWillAppearCalled: Bool = false
    var view: ProfileViewControllerProtocol?
    let profileService = ProfileService.shared
    let presentName = "your profile name" //ВНЕСТИ свой Profile.name
    let presentLogin = "your login" //ВНЕСТИ свой Profile.loginName
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    func removeData() {}
    func viewWillAppear() {
        viewWillAppearCalled = true
    }
}

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: ImageFeed.ProfileViewPresenterProtocol?
    var updateProfileInfoCalled = false
    
    func updateAvatar(url: URL) {}
    func updateProfileInfo(name: String, bio: String?, loginName: String) {
        updateProfileInfoCalled = true
    }
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
        XCTAssertTrue(presenter.viewDidLoadCalled)
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
        XCTAssertTrue(presenter.viewWillAppearCalled)
    }
    
    func testProfileInfoUpdate() {
        //given
        let viewController = ProfileViewController()
        let presenter = ProfileViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        viewController.updateProfileInfo(
            name: "your profile name",//ВНЕСТИ свой Profile.name
            bio: nil,
            loginName: "your login")//ВНЕСТИ свой Profile.loginName
        
        //then
        XCTAssertTrue(viewController.nameLabel.text == presenter.presentName)
        XCTAssertTrue(viewController.loginNameLabel.text == presenter.presentLogin)
    }
    
}
