import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    private let oAuth2TokenStorage = OAuth2TokenStorage()
    private let authHelper = AuthHelper()
    private var task: URLSessionTask?
    private var lastCode: String?
    private let urlSession = URLSession.shared
    private (set) var authToken: String? {
        get {
            return oAuth2TokenStorage.token
        }
        set {
            oAuth2TokenStorage.token = newValue
        }
    }

    private init() {}

    func fetchOAuthToken(code: String,
                         completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        if lastCode == code { return }
        task?.cancel()
        lastCode = code
        let request = authHelper.authToken(by: code)
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            guard let self else { return }
            switch result {
            case .success(let body):
                let authToken = body.accessToken
                self.authToken = authToken
                completion(.success(authToken))
            case .failure(let error):
                completion(.failure(error))
                self.lastCode = nil

            }
            self.task = nil
        }
        self.task = task
        task.resume()
    }
}
