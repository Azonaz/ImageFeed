import Foundation

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    var isLiked: Bool
}
    extension Photo: Equatable {
        static func == (lhs: Photo, rhs: Photo) -> Bool {
            return lhs.id == rhs.id
                && lhs.size == rhs.size
                && lhs.createdAt == rhs.createdAt
                && lhs.welcomeDescription == rhs.welcomeDescription
            && lhs.thumbImageURL == rhs.thumbImageURL
            && lhs.largeImageURL == rhs.largeImageURL
                && lhs.isLiked == rhs.isLiked
        }
}
