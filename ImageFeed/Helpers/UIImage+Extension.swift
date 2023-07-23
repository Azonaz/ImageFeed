import UIKit

extension UIImage {
    static var activeLike: UIImage { UIImage(named: "LikeOn") ?? UIImage() }
    static var inactiveLike: UIImage { UIImage(named: "LikeOff") ?? UIImage() }
    static var placeholderImage: UIImage { UIImage(named: "imagePlaceholder") ?? UIImage() }
 }
