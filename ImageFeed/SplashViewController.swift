import UIKit
import ProgressHUD

final class SplashViewController: UIViewController {
    private let oAuth2Service = OAuth2Service.shared
    private let oAuth2TokenStorage = OAuth2TokenStorage()
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private lazy var splashScreenLogo: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "splash_screen_logo")
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    private var mainStoryboard: UIStoryboard {
        UIStoryboard(name: "Main", bundle: .main)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let token = oAuth2TokenStorage.token {
            fetchProfile(token: token)
        } else {
            presentAuthViewController()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        showAuthAlert()
        addSplashScreenLogo()
    }

    private func switchToTabBarController () {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid configuration")
            return
        }
        let tabBarController = mainStoryboard.instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }

    private func presentAuthViewController() {
        guard let authViewController = mainStoryboard.instantiateViewController(
            withIdentifier: "AuthViewController") as? AuthViewController,
              let navigationController = mainStoryboard.instantiateViewController(
                withIdentifier: "LightStatusBarController") as? LightStatusBarController
        else {
            assertionFailure("Failed")
            return
        }
        authViewController.delegate = self
        navigationController.viewControllers = [authViewController]
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }

    private func addSplashScreenLogo() {
        view.addSubview(splashScreenLogo)
        splashScreenLogo.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        splashScreenLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
}

extension SplashViewController {

    private func fetchOAuthToken(code: String) {
        oAuth2Service.fetchOAuthToken(code: code) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let token):
                self.fetchProfile(token: token)
            case .failure:
                UIBlockingProgressHUD.dismiss()
                showAuthAlert()
            }
        }
    }

    private func fetchProfile(token: String) {
        profileService.fetchProfile(token) { [weak self] result in
            guard let self else { return }
            UIBlockingProgressHUD.dismiss()
            switch result {
            case .success(let profile):
                fetchProfileImageURL(userName: profile.userName, token: token)
                self.switchToTabBarController()
            case .failure:
               showAuthAlert()
            }
        }
    }

    private func fetchProfileImageURL(userName: String, token: String) {
        profileImageService.fetchProfileImageURL(userName: userName,
                                                 token: token) { _ in }
    }

    private func showAuthAlert() {
        AlertPresenter.showAlert(in: presentedViewController ?? self, model: Alert.alertAuth)
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        vc.dismiss(animated: true) { [weak self] in
            guard let self else { return }
            UIBlockingProgressHUD.show()
            self.fetchOAuthToken(code: code)
        }
    }
}
