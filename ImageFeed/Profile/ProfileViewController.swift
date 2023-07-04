import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let oAuth2TokenStorage = OAuth2TokenStorage.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    private var animationLayers = Set<CALayer>()
    private lazy var avatarImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Avatar")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 33
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Екатерина Новикова"
        label.font = UIFont.systemFont(ofSize: 23, weight: .semibold)
        label.textColor = .ypWhite
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var loginNameLabel: UILabel = {
        let label = UILabel()
        label.text = "@ekaterina_nov"
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = .ypGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Hello, world!"
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = .ypWhite
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var logoutButton: UIButton = {
        let button = UIButton.systemButton(
            with: UIImage(named: "LogOut") ?? UIImage(),
            target: self,
            action: #selector(didTapLogoutButton)
        )
        button.tintColor = .ypRed
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
        updateProfileDetails(profile: profileService.profile)
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main) { [weak self] _ in
                guard let self else { return }
                self.updateAvatar()
            }
        setAvatarGradient()
        setNameGradient()
        setLoginGradient()
        setDescriptionGradient()
        updateAvatar()
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

    private func updateProfileDetails(profile: Profile?) {
        guard let profile else {
            assertionFailure("No profile details")
            return
        }
        nameLabel.text = profile.name
        loginNameLabel.text = profile.loginName
        descriptionLabel.text = profile.bio
    }

    private func updateAvatar() {
        guard let avatarURL = profileImageService.avatarURL,
              let url = URL(string: avatarURL)
        else { return }
        let placeholderImage = UIImage(systemName: "no_avatar")
        avatarImage.kf.indicatorType = .activity
        avatarImage.kf.setImage(with: url, placeholder: placeholderImage)
        removeGradient()
    }

    private func showLogOutAlert() {
        let model = AlertModel(title: "Пока, пока!",
                               message: "Уверены, что хотите выйти?",
                               firstButtonText: "Да",
                               secondButtonText: "Нет",
                               firstButtonCompletion: {[weak self] in
            guard let self else { return }
            WebViewViewController.cleanData()
            self.oAuth2TokenStorage.removeToken()
            guard let window = UIApplication.shared.windows.first else {
                assertionFailure("Error")
                return
            }
            window.rootViewController = SplashViewController()},
                               secondButtonCompletion: { })
        AlertPresenter.showAlert(in: self, model: model)
    }
}

extension ProfileViewController {
    private func setGradient(for layer: CALayer, with label: UILabel) {
        let gradient = CAGradientLayer()
        let fittingSize = label.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: label.bounds.height))
        let textWidth = fittingSize.width
        let textHeight = fittingSize.height
        gradient.frame = CGRect(origin: .zero, size: CGSize(width: textWidth, height: textHeight))
        gradient.locations = [0, 0.1, 0.3]
        gradient.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.cornerRadius = 9
        gradient.masksToBounds = true
        animationLayers.insert(gradient)
        layer.addSublayer(gradient)
        let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
        gradientChangeAnimation.duration = 1
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.fromValue = [0, 0.1, 0.3]
        gradientChangeAnimation.toValue = [0, 0.8, 1]
        gradient.add(gradientChangeAnimation, forKey: "locationsChange")
    }

    private func setNameGradient() {
        setGradient(for: nameLabel.layer, with: nameLabel)
    }

    private func setLoginGradient() {
        setGradient(for: loginNameLabel.layer, with: loginNameLabel)
    }

    private func setDescriptionGradient() {
        setGradient(for: descriptionLabel.layer, with: descriptionLabel)
    }

    private func setAvatarGradient() {
        let avatarGradient = CAGradientLayer()
        avatarGradient.frame = CGRect(origin: .zero, size: CGSize(width: 70, height: 70))
        avatarGradient.locations = [0, 0.1, 0.3]
        avatarGradient.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        avatarGradient.startPoint = CGPoint(x: 0, y: 0.5)
        avatarGradient.endPoint = CGPoint(x: 1, y: 0.5)
        avatarGradient.cornerRadius = 35
        avatarGradient.masksToBounds = true
        animationLayers.insert(avatarGradient)
        avatarImage.layer.addSublayer(avatarGradient)
        let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
        gradientChangeAnimation.duration = 1
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.fromValue = [0, 0.1, 0.3]
        gradientChangeAnimation.toValue = [0, 0.8, 1]
        avatarGradient.add(gradientChangeAnimation, forKey: "locationsChange")
    }

    private func removeGradient() {
        animationLayers.forEach { layer in
            layer.removeFromSuperlayer()
        }
    }
}
