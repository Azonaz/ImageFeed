import Foundation

struct PhotoLikeResult: Decodable {
    let photo: PhotoLikeDataResult
}

struct PhotoLikeDataResult: Decodable {
    let id: String
    let isLiked: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case isLiked = "liked_by_user"
    }
}
