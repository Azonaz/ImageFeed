@testable import ImageFeed
import XCTest

final class ImagesListServiceSpy: ImagesListServiceProtocol {
    var photos: [Photo] = []
    var fetchPhotosNextPageCall: Bool = false

    func fetchPhotosNextPage() {
        fetchPhotosNextPageCall = true
    }

    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
    }
}

final class ImageListTests: XCTestCase {
    func testImagesListPresenterFetchPhotosCalles() {
        // given
        let view = ImagesListViewController()
        let service = ImagesListServiceSpy()
        let presenter = ImagesListPresenter(view: view, imagesListService: service)

        // when
        presenter.viewDidLoad()

        // then
        XCTAssertTrue(service.fetchPhotosNextPageCall)
    }
}
