import UIKit

final class LightStatusBarController: UINavigationController {
    override var childForStatusBarStyle: UIViewController? { return visibleViewController }
}
