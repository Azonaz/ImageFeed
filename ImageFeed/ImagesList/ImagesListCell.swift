import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imagesListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    weak var delegate: ImagesListCellDelegate?

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var cellImage: UIImageView!

    private var gradientLayer: CAGradientLayer!
    private let gradientHeight = 30.0

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        gradientLayer = CAGradientLayer()
        if let gradient1 = UIColor.YPGradient1?.cgColor, let gradient2 = UIColor.YPGradient2?.cgColor {
            gradientLayer.colors = [gradient1, gradient2]
        }
        gradientLayer.locations = [0.0, 1.0]
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

    func configCell(with photo: Photo) {
        let likedImage = getLikeImage(isLiked: photo.isLiked)
        likeButton.setImage(likedImage, for: .normal)
        dateLabel.text = (photo.createdAt != nil) ? dateFormatter.string(from: photo.createdAt!) : ""
        guard let url = URL(string: photo.thumbImageURL) else { return }
        let placeholder: UIImage = .placeholderImage
        cellImage.kf.indicatorType = .activity
        cellImage.kf.setImage(with: url, placeholder: placeholder)
    }

    func setIsLiked(_ isLiked: Bool) {
        let likeImage = getLikeImage(isLiked: isLiked)
        likeButton.setImage(likeImage, for: .normal)
    }

    private func getLikeImage(isLiked: Bool) -> UIImage {
        return isLiked ? .activeLike : .inactiveLike
    }

    @IBAction private func likeButtonClick(_ sender: Any) {
        delegate?.imagesListCellDidTapLike(self)
    }
}
