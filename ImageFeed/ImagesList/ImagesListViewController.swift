import UIKit
import Kingfisher

protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListPresenterProtocol? { get set }
    func updateTableViewAnimated(at indexes: [Int])
}

final class ImagesListViewController: UIViewController & ImagesListViewControllerProtocol {
    @IBOutlet private var tableView: UITableView!

    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    var presenter: ImagesListPresenterProtocol?
 //   private let imagesListService = ImagesListService.shared
 //   private var photos: [Photo] = []
  //  private var imagesListServiceObserver: NSObjectProtocol?

    

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
//        imagesListServiceObserver = NotificationCenter.default.addObserver(
//            forName: ImagesListService.didChangeNotification,
//            object: nil,
//            queue: .main) { [weak self] _ in
//                guard let self else { return }
//                self.updateTableViewAnimated()
//            }
        presenter?.viewDidLoad()
   //     imagesListService.fetchPhotosNextPage()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard let viewController = segue.destination as? SingleImageViewController,
                  let indexPath = sender as? IndexPath,
                  let urlString = presenter?.photos[safe: indexPath.row]?.largeImageURL,
                  let imageURL = URL(string: urlString)
            else { return }
            viewController.imageURL = imageURL
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }

    func updateTableViewAnimated(at indexes: [Int]) {
            tableView.performBatchUpdates {
                let indexPaths = indexes.map { IndexPath(row: $0, section: 0)}
                    tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
    }
}

extension ImagesListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let presenter else { return 0 }
        return presenter.photos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        imageListCell.delegate = self
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imagesListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell),
              let presenter,
              let imagesListCell = cell as? ImagesListCell else { return }
        let index = indexPath.row
        UIBlockingProgressHUD.show()
        presenter.changeLike(at: index) { result in
            switch result {
            case .success(let photos):
                DispatchQueue.main.async {
                    imagesListCell.setIsLiked(photos[index].isLiked)
                }
                UIBlockingProgressHUD.dismiss()
            case .failure(let error):
                assertionFailure(error.localizedDescription)
                UIBlockingProgressHUD.dismiss()
            }
        }
    }
}

extension ImagesListViewController {

    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard let photo = presenter?.photos[safe: indexPath.row] else { return }
        cell.configCell(photo: photo) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(_):
                tableView.reloadRows(at: [indexPath], with: .automatic)
            case .failure(let error):
                assertionFailure(error.localizedDescription)
            }
        }
//        let likedImage = photo.isLiked ? UIImage(named: "LikeOn") : UIImage(named: "LikeOff")
//        cell.likeButton.setImage(likedImage, for: .normal)
//        cell.dateLabel.text = (photo.createdAt != nil) ? dateFormatter.string(from: photo.createdAt!) : ""
//        guard let url = URL(string: photo.thumbImageURL) else { return }
//        let placeholder = UIImage(named: "imagePlaceholder") ?? UIImage()
//        cell.cellImage.kf.indicatorType = .activity
//        cell.cellImage.kf.setImage(with: url, placeholder: placeholder) { [weak self] _ in
//            guard let self else { return }
//            self.tableView.reloadRows(at: [indexPath], with: .automatic)
//        }
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let presenter, let image = presenter.photos[safe: indexPath.row] else {
            assertionFailure("No photo")
            return 0
        }
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = image.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = image.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        presenter?.fetchPhotosNextPageIfNeeded(index: indexPath.row)
    }
}
