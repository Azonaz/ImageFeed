import Foundation

protocol ImagesListPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didTapLike(for cell: ImagesListCell)
}

class ImagesListPresenter: ImagesListPresenterProtocol {
    private weak var view: ImagesListViewControllerProtocol?
    private let imagesListService = ImagesListService.shared
    
    init(view: ImagesListViewControllerProtocol) {
        self.view = view
    }
    
    func viewDidLoad() {
        view?.configureTableView()
        imagesListService.fetchPhotosNextPage()
    }
    
    func didTapLike(for cell: ImagesListCell) {
        guard let indexPath = view?.indexPath(for: cell),
              var photo = imagesListService.photos[safe: indexPath.row] else {
            return
        }
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self = self else { return }
            
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
}
