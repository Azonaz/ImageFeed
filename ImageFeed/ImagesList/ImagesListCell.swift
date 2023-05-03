import UIKit

final class ImagesListCell: UITableViewCell {
    static var reuseIdentifier = "ImagesListCell"
    private var gradientLayer: CAGradientLayer!
    private let gradientHeight = 30.0
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var cellImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        gradientLayer = CAGradientLayer()
        if let gradient1 = UIColor.YPGradient1?.cgColor, let gradient2 = UIColor.YPGradient2?.cgColor {
            gradientLayer.colors = [gradient1, gradient2]
        }
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = CGRect(x: 0, y: cellImage.bounds.height - gradientHeight, width: cellImage.bounds.width, height: gradientHeight)
        cellImage.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = CGRect(x: 0, y: cellImage.bounds.height - gradientHeight, width: cellImage.bounds.width, height: gradientHeight)
    }
}

