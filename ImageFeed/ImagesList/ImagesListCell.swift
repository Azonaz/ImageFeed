import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imagesListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    private var gradientLayer: CAGradientLayer!
    private let gradientHeight = 30.0
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var cellImage: UIImageView!
    weak var delegate: ImagesListCellDelegate?
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
      //  formatter.dateStyle = .long
      //  formatter.timeStyle = .none
        return formatter
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        gradientLayer = CAGradientLayer()
        if let gradient1 = UIColor.YPGradient1?.cgColor, let gradient2 = UIColor.YPGradient2?.cgColor {
            gradientLayer.colors = [gradient1, gradient2]
        }
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = CGRect(x: 0, y: cellImage.bounds.height - gradientHeight,
                                     width: cellImage.bounds.width, height: gradientHeight)
        cellImage.layer.insertSublayer(gradientLayer, at: 0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = CGRect(x: 0, y: cellImage.bounds.height - gradientHeight,
                                     width: cellImage.bounds.width, height: gradientHeight)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.kf.cancelDownloadTask()
    }
    
    func configCell(photo: Photo, _ completion: @escaping (Result<Void, Error>) -> Void) {
        let datePhoto = (photo.createdAt != nil) ? dateFormatter.string(from: photo.createdAt!) : ""
        let likedImage = photo.isLiked ? UIImage(named: "LikeOn") : UIImage(named: "LikeOff")
        likeButton.isSelected = photo.isLiked
        likeButton.setImage(likedImage, for: .normal)
        dateLabel.text = datePhoto
        guard let url = URL(string: photo.thumbImageURL) else { return }
        let placeholder = UIImage(named: "imagePlaceholder") ?? UIImage()
        cellImage.kf.indicatorType = .activity
//        cellImage.kf.setImage(with: url, placeholder: placeholder) { [weak self] result in
//                    guard let self else { return }
//            switch result {
//            case .success():
//                completion(.success(()))
//            case .failure(let error):
//                self.cellImage.image = UIImage(named: "imagePlaceholder")
//                completion(.failure(error))
//            }
       //         }
    }

    func setIsLiked(_ isLiked: Bool) {
        let likedImage = isLiked ? UIImage(named: "LikeOn") : UIImage(named: "LikeOff")
        likeButton.setImage(likedImage, for: .normal)
    //    likeButton.isSelected = isLiked
    }

    @IBAction private func likeButtonClick(_ sender: Any) {
        delegate?.imagesListCellDidTapLike(self)
    }
}
