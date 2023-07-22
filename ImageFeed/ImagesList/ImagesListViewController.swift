import UIKit
import Kingfisher

protocol ImagesListViewControllerProtocol: AnyObject {
    func configureTableView()
    func indexPath(for cell: ImagesListCell) -> IndexPath?
}

final class ImagesListViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private let imagesListService = ImagesListService.shared
    private var photos: [Photo] = []
    private var imagesListServiceObserver: NSObjectProtocol?
    private var presenter: ImagesListPresenterProtocol?
    
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = ImagesListPresenter(view: self)
        presenter?.viewDidLoad()
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

extension ImagesListViewController: ImagesListViewControllerProtocol {
    func configureTableView() {
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main) { [weak self] _ in
                self?.updateTableViewAnimated()
            }
    }
      
    func indexPath(for cell: ImagesListCell) -> IndexPath? {
        return tableView.indexPath(for: cell)
    }
    
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imagesListCellDidTapLike(_ cell: ImagesListCell) {
        presenter?.didTapLike(for: cell)
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
        if let photo = photos[safe: indexPath.row] {
                imageListCell.configCell(with: photo)
            }
            return imageListCell
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
