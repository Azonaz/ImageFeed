import UIKit

final class LightStatusBarController: UINavigationController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
}
