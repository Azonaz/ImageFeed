import UIKit

final class AlertPresenter {

    static func showAlert(in vc: UIViewController, model: AlertModel) {
        let alert = UIAlertController(title: model.title,
                                      message: model.message,
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: model.buttonText,
                                   style: .default) { _ in
            model.completion()
        }
        alert.addAction(action)
        vc.present(alert, animated: true, completion: nil)
    }
}

enum Alert {
    static let alertAuth = AlertModel(
        title: "Что-то пошло не так(",
        message: "Не удалось войти в систему",
        buttonText: "OK",
        completion: { }
    )
}
