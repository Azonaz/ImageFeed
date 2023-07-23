import Foundation

protocol ImagesListPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didTapLike(for cell: ImagesListCell)
    func imagesListServiseObserver()
    func tableViewWillDisplayCell(at indexPath: IndexPath)
}

class ImagesListPresenter: ImagesListPresenterProtocol {
    private weak var view: ImagesListViewControllerProtocol?
    private let imagesListService = ImagesListService.shared
    private var imagesListServiceObserver: NSObjectProtocol?

    init(view: ImagesListViewControllerProtocol) {
        self.view = view
    }

    func viewDidLoad() {
        imagesListService.fetchPhotosNextPage()
        imagesListServiseObserver()
    }

    func imagesListServiseObserver() {
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main) { [weak self] _ in
                guard let self else { return }
                self.updateTableViewAnimated()
            }
    }

    func updateTableViewAnimated() {
        let oldCount = view?.photos.count ?? 0
        let newCount = imagesListService.photos.count
        if oldCount != newCount {
            view?.photos = imagesListService.photos
            let indexPaths = (oldCount..<newCount).map { index in
                IndexPath(row: index, section: 0)
            }
            view?.performBatchUpdate(with: indexPaths)
        }
    }

    func didTapLike(for cell: ImagesListCell) {
        guard let indexPath = view?.indexPath(for: cell),
              var photo = imagesListService.photos[safe: indexPath.row] else {
            return
        }
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard self != nil else { return }
            switch result {
            case .success:
                DispatchQueue.main.async {
                    photo.isLiked = !photo.isLiked
                    cell.setIsLiked(photo.isLiked)
                }
                UIBlockingProgressHUD.dismiss()
            case .failure(let error):
                assertionFailure(error.localizedDescription)
                UIBlockingProgressHUD.dismiss()
            }
        }
    }

    func tableViewWillDisplayCell(at indexPath: IndexPath) {
        if let photosCount = view?.photos.count,
           indexPath.row == photosCount - 1 {
            imagesListService.fetchPhotosNextPage()
        }
    }
}
