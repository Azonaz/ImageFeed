import UIKit

final class ProfileService {
    static let shared = ProfileService()
    private (set) var profile: Profile?
    private var task: URLSessionTask?
    private let urlSession = URLSession.shared
    private var lastToken: String?

    private init() {}

    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        if lastToken == token { return }
        task?.cancel()
        lastToken = token
        let request = URLRequests.profile(token: token)
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self else { return }
            switch result {
            case .success(let body):
                self.profile = Profile(userName: body.username,
                                       name: "\(body.firstName) \(body.lastName ?? "")",
                                       loginName: "@\(body.username)",
                                       bio: body.bio ?? "")
                completion(.success(self.profile!))
            case .failure(let error):
                self.lastToken = nil
                completion(.failure(error))
            }
            self.task = nil
        }
        self.task = task
        task.resume()
    }
}
