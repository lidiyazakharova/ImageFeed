import UIKit

final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
//        let imageListViewController = storyboard.instantiateViewController(withIdentifier: "ImageListViewController")
        
        let imageListViewController = storyboard
            .instantiateViewController(withIdentifier: "ImageListViewController") as! ImagesListViewController
        let imageListViewPresenter = ImageListViewPresenter()
        imageListViewController.presenter = imageListViewPresenter
        imageListViewPresenter.view = imageListViewController
        
        let profileViewController = ProfileViewController()
        let profileViewPresenter = ProfileViewPresenter()
        
        profileViewController.presenter = profileViewPresenter
        profileViewPresenter.view = profileViewController
        
        profileViewController.tabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(named: "tab_profile_active"),
            selectedImage: nil
        )
        self.viewControllers = [imageListViewController, profileViewController]
    }
}
