import UIKit

protocol ImagesListServiceProtocol {
    var photos: [Photo] { get set }
    func fetchPhotosNextPage()
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void)
}

final class ImagesListService: ImagesListServiceProtocol {
    static let shared = ImagesListService()
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    var photos: [Photo] = []
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastLoadedPage: Int = 0

    private var token: String? {
        OAuth2TokenStorage.shared.token
    }

    private lazy var dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        return formatter
    }()

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
                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification,
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
                  createdAt: dateFormatter.date(from: $0.createdAt),
                  welcomeDescription: $0.description,
                  thumbImageURL: $0.urls.thumb,
                  largeImageURL: $0.urls.full,
                  isLiked: $0.isLiked)
        }
    }

    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        assert(Thread.isMainThread)
        guard let token else { return }
        let request = isLike ? URLRequests.likes(photoID: photoId, method: .post, token: token)
        : URLRequests.likes(photoID: photoId, method: .delete, token: token)
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<PhotoLikeResult, Error>) in
            guard let self else { return }
            switch result {
            case .success(let body):
                DispatchQueue.main.async {
                    if let index = self.photos.firstIndex(where: { $0.id == photoId}) {
                        self.photos[index].isLiked = body.photo.isLiked
                    }
                    completion(.success(()))
                }
            case .failure(let error):
                completion(.failure(error))
            }
            self.task = nil
        }
        self.task = task
        task.resume()
    }
}
