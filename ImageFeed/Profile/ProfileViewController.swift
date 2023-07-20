import UIKit
import Kingfisher

public protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfileViewPresenterProtocol? { get set }
    func updateAvatar(url: URL?)
    func updateProfileDetails(profile: Profile?)
}

final class ProfileViewController: UIViewController & ProfileViewControllerProtocol {
    var presenter: ProfileViewPresenterProtocol?
 //   private let profileService = ProfileService.shared
 //   private let profileImageService = ProfileImageService.shared
 //   private let oAuth2TokenStorage = OAuth2TokenStorage.shared
  //  private var profileImageServiceObserver: NSObjectProtocol?
    lazy var avatarImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Avatar")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 33
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Екатерина Новикова"
        label.font = UIFont.systemFont(ofSize: 23, weight: .semibold)
        label.textColor = .ypWhite
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var loginNameLabel: UILabel = {
        let label = UILabel()
        label.text = "@ekaterina_nov"
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = .ypGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Hello, world!"
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = .ypWhite
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var logoutButton: UIButton = {
        let button = UIButton.systemButton(
            with: UIImage(named: "LogOut") ?? UIImage(),
            target: self,
            action: #selector(didTapLogoutButton)
        )
        button.tintColor = .ypRed
        button.accessibilityIdentifier = "Logout"
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        addAvatarImage()
        addNameLabel()
        addLoginNameLabel()
        addDescriptionLabel()
        addLogoutButton()
      //  updateProfileDetails(profile: profileService.profile)
     //   presenter?.profileImageObserver()
//        profileImageServiceObserver = NotificationCenter.default.addObserver(
//            forName: ProfileImageService.didChangeNotification,
//            object: nil,
//            queue: .main) { [weak self] _ in
//                guard let self else { return }
//                self.updateAvatar()
//            }
    //    updateAvatar()
        presenter?.viewDidLoad()
    }

    private func addAvatarImage() {
        view.addSubview(avatarImage)
        avatarImage.heightAnchor.constraint(equalToConstant: 70).isActive = true
        avatarImage.widthAnchor.constraint(equalToConstant: 70).isActive = true
        avatarImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32).isActive = true
        avatarImage.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                             constant: 16).isActive = true
    }

    private func addNameLabel() {
        view.addSubview(nameLabel)
        nameLabel.topAnchor.constraint(equalTo: avatarImage.bottomAnchor, constant: 8).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: avatarImage.leadingAnchor).isActive = true
    }

    private func addLoginNameLabel() {
        view.addSubview(loginNameLabel)
        loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8).isActive = true
        loginNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor).isActive = true
    }

    private func addDescriptionLabel() {
        view.addSubview(descriptionLabel)
        descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8).isActive = true
        descriptionLabel.leadingAnchor.constraint(equalTo: loginNameLabel.leadingAnchor).isActive = true
    }

    private func addLogoutButton() {
        view.addSubview(logoutButton)
        logoutButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        logoutButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        logoutButton.centerYAnchor.constraint(equalTo: avatarImage.centerYAnchor).isActive = true
        logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                               constant: -24).isActive = true
    }

    @objc private func didTapLogoutButton() {
        showLogOutAlert()
    }

   func updateProfileDetails(profile: Profile?) {
        guard let profile else {
            assertionFailure("No profile details")
            return
        }
        nameLabel.text = profile.name
        loginNameLabel.text = profile.loginName
        descriptionLabel.text = profile.bio
    }

    func updateAvatar(url: URL?) {
        guard let url else { return }
        let placeholderImage = UIImage(systemName: "no_avatar")
        avatarImage.kf.indicatorType = .activity
        avatarImage.kf.setImage(with: url, placeholder: placeholderImage)
    }

    @objc private func showLogOutAlert() {
       
        let model = AlertModel(title: "Пока, пока!",
                               message: "Уверены, что хотите выйти?",
                               firstButtonText: "Да",
                               secondButtonText: "Нет",
                               firstButtonCompletion: {[weak self] in
            guard let self else { return }
            self.presenter?.cleanData()
        //    WebViewViewController.cleanData()
         //   self.oAuth2TokenStorage.removeToken()
            guard let window = UIApplication.shared.windows.first else {
                assertionFailure("Error")
                return
            }
            window.rootViewController = SplashViewController()},
                               secondButtonCompletion: { })
        AlertPresenter.showAlert(in: self, model: model)
    }
}
