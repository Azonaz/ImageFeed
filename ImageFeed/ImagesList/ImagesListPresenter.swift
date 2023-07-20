import Foundation

protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    var imagesListService: ImagesListServiceProtocol? { get set }
    var photos: [Photo] { get set }
    func viewDidLoad()
    func updateTableViewAnimated()
    func fetchPhotosNextPageIfNeeded(index: Int)
    func changeLike(at index: Int, _ completion: @escaping (Result<[Photo], Error>) -> Void)
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    
    var view: ImagesListViewControllerProtocol?
    var imagesListService: ImagesListServiceProtocol?
    var photos: [Photo] = []
    private var imagesListServiceObserver: NSObjectProtocol?
    
    func viewDidLoad() {
        imagesListService = ImagesListService.shared
        imagesListService?.fetchPhotosNextPage()
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main) { [weak self] _ in
                guard let self else { return }
                self.updateTableViewAnimated()
            }
    }
    
    func updateTableViewAnimated() {
        guard let imagesListService else { return }
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        let indexes = Array(oldCount..<newCount)
        synchPhotos()
        if oldCount != newCount {
            view?.updateTableViewAnimated(at: indexes)
        }
    }
    
    func fetchPhotosNextPageIfNeeded(index: Int) {
        if index == photos.count - 1 {
            imagesListService?.fetchPhotosNextPage()
        }
    }
    
    func changeLike(at index: Int, _ completion: @escaping (Result<[Photo], Error>) -> Void) {
        guard let photo = photos[safe: index] else { return }
        imagesListService?.changeLike(photoId: photo.id,
                                      isLike: !photo.isLiked) { [ weak self ] result in
            guard let self else { return }
            switch result {
            case .success():
                DispatchQueue.main.async {
                    self.synchPhotos()
                    completion(.success(self.photos))
                }
            case .failure(let error):
                completion(.failure(error))
            } 
        }
    }
    
    func synchPhotos() {
        guard let imagesListService else { return }
        photos = imagesListService.photos
    }
}

