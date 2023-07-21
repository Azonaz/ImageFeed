import UIKit

protocol ProfileViewPresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    var profile: Profile? { get }
    var avatarURL: URL? { get }
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
    var profile: Profile?{
        profileService.profile
    }
    var avatarURL: URL? {
        URL(string: profileImageService.avatarURL ?? String())
//        guard let avatarURL = profileImageService.avatarURL else { return nil}
//        return URL(string: avatarURL)
    }
    
    init(
        view: ProfileViewControllerProtocol) {
        self.view = view
    }
    
    func viewDidLoad() {
        view?.updateProfileDetails(profile: profileService.profile)
        view?.updateAvatar(url: avatarURL)
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
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Error")
            return
        }
        window.rootViewController = SplashViewController()
    }
}