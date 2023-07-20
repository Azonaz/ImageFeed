import UIKit

public protocol ProfileViewPresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
  //  var profileImageServiceObserver: NSObjectProtocol? { get set }
    func viewDidLoad()
  //  func profileImageObserver()
 //   func showLogOutAlert(vc: UIViewController)
    func cleanData()
}

final class ProfileViewPresenter: ProfileViewPresenterProtocol {
    
    
    weak var view: ProfileViewControllerProtocol?
    var profileImageServiceObserver: NSObjectProtocol?
    private let oAuth2TokenStorage = OAuth2TokenStorage.shared
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private var avatarURL: URL? {
        guard let avatarURL = profileImageService.avatarURL else { return nil}
        return URL(string: avatarURL)
    }
    
    func viewDidLoad() {
        view?.updateAvatar(url: avatarURL)
        view?.updateProfileDetails(profile: profileService.profile)
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            self.view?.updateAvatar(url: self.avatarURL)
        }
    }
    
    func cleanData() {
        WebViewViewController.cleanData()
        oAuth2TokenStorage.removeToken()
    }
    
    
    
}
