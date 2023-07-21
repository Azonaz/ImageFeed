import Foundation

struct AlertModel {
    var title: String
    var message: String
    var firstButtonText: String?
    var secondButtonText: String?
    var firstButtonCompletion: () -> Void
    var secondButtonCompletion: () -> Void
    
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

//    static func logOutAlert(firstButtonCompletion: @escaping() -> Void) -> AlertModel {
//        return AlertModel(title: "Пока, пока!",
//                               message: "Уверены, что хотите выйти?",
//                               firstButtonText: "Да",
//                               secondButtonText: "Нет",
//                               firstButtonCompletion: firstButtonCompletion,
//                          secondButtonCompletion: { }
//        )
//    }

}
