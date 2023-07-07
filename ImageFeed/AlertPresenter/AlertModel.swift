import Foundation

struct AlertModel {
    var title: String
    var message: String
    var firstButtonText: String?
    var secondButtonText: String?
    var firstButtonCompletion: () -> Void
    var secondButtonCompletion: () -> Void
}
