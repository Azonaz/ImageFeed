import UIKit

final class AlertPresenter {

    static func showAlert(in vc: UIViewController, model: AlertModel) {
        let alert = UIAlertController(title: model.title,
                                      message: model.message,
                                      preferredStyle: .alert)
        if let firstButtonText = model.firstButtonText {
            let firstButtonAction = UIAlertAction(title: firstButtonText, style: .default) { _ in
                model.firstButtonCompletion()
        }
            alert.addAction(firstButtonAction)
        }
        if let secondButtonText = model.secondButtonText {
            let secondButtonAction = UIAlertAction(title: secondButtonText, style: .cancel) { _ in
                model.secondButtonCompletion()
        }
            alert.addAction(secondButtonAction)
        }
        vc.present(alert, animated: true, completion: nil)
    }
}

enum Alert {
    static let alertAuth = AlertModel(
        title: "Что-то пошло не так",
        message: "Не удалось войти в систему",
        firstButtonText: "OK",
        secondButtonText: nil,
        firstButtonCompletion: { },
        secondButtonCompletion: { }
    )
    static let alertShowImage = AlertModel(
        title: "Что-то пошло не так",
        message: "Не удалось загрузить изображение",
        firstButtonText: "OK",
        secondButtonText: nil,
        firstButtonCompletion: { },
        secondButtonCompletion: { }
    )
}
