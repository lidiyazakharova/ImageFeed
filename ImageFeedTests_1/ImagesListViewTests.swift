@testable import ImageFeed
import Foundation
import XCTest

final class ImageListViewPresenterSpy: ImageListViewPresenterProtocol {
    var viewDidLoadCalled: Bool = false
    var view: ImageListViewControllerProtocol?
    var photos: [Photo] = []
    let imagesListService = ImagesListService.shared
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func getPhotos() -> [Photo] { return imagesListService.photos }
    func changePhotoLike(photoIndex: IndexPath) {}
    
    func fetchPhotosNextPage() {}
}

final class ImageListViewControllerSpy: ImageListViewControllerProtocol {
    var presenter: ImageFeed.ImageListViewPresenterProtocol?
    
    var changeBlockingProgressHUDCalled: Bool = false
    var updateTableViewAnimatedCalled: Bool = false
    
    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        updateTableViewAnimatedCalled = true
    }
    
    
    func changeBlockingProgressHUD(visible: Bool) {
        changeBlockingProgressHUDCalled = true
    }
    
    func showLikeAlert(error: Error) {}
    func updateCellLikeStatus(cellIndex: IndexPath, isLiked: Bool) {}
}

class ImageListViewTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad() {
        //given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ImageListViewController") as! ImagesListViewController
        let presenter = ImageListViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        //when
        _ = viewController.view
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled) //behaviour verification
    }
    
    func testChangeCountCalledUpdateTableViewAnimated() {
        //given
        let presenter = ImageListViewPresenter()
        let viewController = ImageListViewControllerSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        presenter.changeCount()
        
        //then
        XCTAssertTrue(viewController.updateTableViewAnimatedCalled)
    }

    func testPhotosListIsEmptyOnStartPresenter(){
        //given
        let presenter = ImageListViewPresenter()
        
        //then
        XCTAssertTrue(presenter.getPhotos().count == 0) //behaviour verification
    }
}
