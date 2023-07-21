import UIKit

final class AlertPresenter {

    static func showAlert(in vc: UIViewController, model: AlertModel) {
        let alert = UIAlertController(title: model.title,
                                      message: model.message,
                                      preferredStyle: .alert)
        if let firstButtonText = model.firstButtonText {
            let firstButtonAction = UIAlertAction(title: firstButtonText, style: .cancel) { _ in
                model.firstButtonCompletion()
        }
            alert.addAction(firstButtonAction)
        }
        if let secondButtonText = model.secondButtonText {
            let secondButtonAction = UIAlertAction(title: secondButtonText, style: .default) { _ in
                model.secondButtonCompletion()
        }
            alert.addAction(secondButtonAction)
        }
        vc.present(alert, animated: true, completion: nil)
    }
}
