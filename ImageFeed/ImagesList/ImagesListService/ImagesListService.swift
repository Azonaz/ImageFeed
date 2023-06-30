import UIKit

final class ImagesListService {
    static let shared = ImagesListService()
    private (set) var photos: [Photo] = []
    static let DidChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastLoadedPage: Int = 0
    private var token: String? {
        OAuth2TokenStorage.shared.token
    }

    private init() { }

    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        guard task == nil, let token = token else { return }
        let nextPage = lastLoadedPage + 1
        let request = URLRequests.photos(page: nextPage, perPage: photosPerPage, token: token)
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self else { return }
            switch result {
            case .success(let body):
                DispatchQueue.main.async {
                    let newPhotos = self.convert(photoResult: body)
                    self.photos.append(contentsOf: newPhotos)
                    NotificationCenter.default.post(name: ImagesListService.DidChangeNotification,
                                                    object: self)
                    self.lastLoadedPage += 1
                }
            case .failure(let error):
                assertionFailure(error.localizedDescription)
            }
            self.task = nil
        }
        self.task = task
        task.resume()
    }

    private func convert(photoResult: [PhotoResult]) -> [Photo] {
        return photoResult.map {
            Photo(id: $0.id,
                  size: CGSize(width: $0.width, height: $0.height),
                  createdAt: ISO8601DateFormatter().date(from: $0.createdAt),
                  welcomeDescription: $0.description,
                  thumbImageURL: $0.urls.thumb,
                  largeImageURL: $0.urls.full,
                  isLiked: $0.isLiked)
        }
    }
}
