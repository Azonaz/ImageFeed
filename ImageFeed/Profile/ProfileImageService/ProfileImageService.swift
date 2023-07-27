import UIKit

final class ProfileImageService {

    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    private (set) var avatarURL: String?
    private var task: URLSessionTask?
    private var usedToken: String?
    private let urlSession = URLSession.shared

    private init() {}

    func fetchProfileImageURL(userName: String,
                              token: String,
                              _ completion: @escaping (Result<String?, Error>) -> Void) {
        assert(Thread.isMainThread)
        if usedToken == token { return }
        task?.cancel()
        usedToken = token
        let request = URLRequests.profileImage(token: token, userName: userName)
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self else { return }
            switch result {
            case .success(let body):
                self.avatarURL = body.profileImage.small
                completion(.success(self.avatarURL!))
                NotificationCenter.default.post(name: ProfileImageService.didChangeNotification,
                                                object: self,
                                                userInfo: ["URL": self.avatarURL!])
            case .failure(let error):
                self.usedToken = nil
                completion(.failure(error))
            }
            self.task = nil
        }
        self.task = task
        task.resume()
    }
}
