import UIKit
import Kingfisher

class ImagesListViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!

    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private let imagesListService = ImagesListService.shared
    private var photos: [Photo] = []
    private var imagesListServiceObserver: NSObjectProtocol?

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main) { [weak self] _ in
                guard let self else { return }
                self.updateTableViewAnimated()
            }
        imagesListService.fetchPhotosNextPage()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard let viewController = segue.destination as? SingleImageViewController,
                  let indexPath = sender as? IndexPath,
                  let urlString = photos[safe: indexPath.row]?.largeImageURL,
                  let imageURL = URL(string: urlString)
            else { return }
            viewController.imageURL = imageURL
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }

    func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { index in
                    IndexPath(row: index, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
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
    func imagesListCellDidTapLike(_ cell: UITableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell),
              let photo = photos[safe: indexPath.row],
              let imagesListCell = cell as? ImagesListCell else { return }
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photo.id,
                                     isLike: !photo.isLiked) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.photos = self.imagesListService.photos
                    imagesListCell.setIsLiked(self.photos[indexPath.row].isLiked)
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
        guard let photo = photos[safe: indexPath.row] else { return }
        let likedImage = photo.isLiked ? UIImage(named: "LikeOn") : UIImage(named: "LikeOff")
        cell.likeButton.setImage(likedImage, for: .normal)
        cell.dateLabel.text = (photo.createdAt != nil) ? dateFormatter.string(from: photo.createdAt!) : ""
        guard let url = URL(string: photo.thumbImageURL) else { return }
        let placeholder = UIImage(named: "imagePlaceholder") ?? UIImage()
        cell.cellImage.kf.indicatorType = .activity
        cell.cellImage.kf.setImage(with: url, placeholder: placeholder) { [weak self] _ in
            guard let self else { return }
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = photos[safe: indexPath.row] else {
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
        if indexPath.row == photos.count - 1 {
            imagesListService.fetchPhotosNextPage()
        }
    }
}
