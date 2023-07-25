import Foundation

protocol ImagesListPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didTapLike(for cell: ImagesListCell)
    func addImagesListServiseObserver()
    func tableViewWillDisplayCell(at indexPath: IndexPath)
}

class ImagesListPresenter: ImagesListPresenterProtocol {
    private weak var view: ImagesListViewControllerProtocol?
    private let imagesListService: ImagesListServiceProtocol
    private var imagesListServiceObserver: NSObjectProtocol?

    init(view: ImagesListViewControllerProtocol,
         imagesListService: ImagesListServiceProtocol = ImagesListService.shared) {
        self.view = view
        self.imagesListService = imagesListService
    }

    func viewDidLoad() {
        imagesListService.fetchPhotosNextPage()
        addImagesListServiseObserver()
    }

    func addImagesListServiseObserver() {
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main) { [weak self] _ in
                guard let self else { return }
                self.updateTableViewAnimated()
            }
    }

    func updateTableViewAnimated() {
        guard let view = view else { return }
        let oldCount = view.photos.count
        let newCount = imagesListService.photos.count
        if oldCount != newCount {
            view.photos = imagesListService.photos
            let indexPaths = (oldCount..<newCount).map { index in
                IndexPath(row: index, section: 0)
            }
            view.performBatchUpdate(with: indexPaths)
        }
    }

    func didTapLike(for cell: ImagesListCell) {
        guard let indexPath = view?.indexPath(for: cell),
              var photo = imagesListService.photos[safe: indexPath.row] else {
            return
        }
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    photo.isLiked = !photo.isLiked
                    cell.setIsLiked(photo.isLiked)
                }
                UIBlockingProgressHUD.dismiss()
            case .failure(_):
                UIBlockingProgressHUD.dismiss()
                self.view?.showAlert()
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
