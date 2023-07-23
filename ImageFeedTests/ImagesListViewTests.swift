@testable import ImageFeed
import XCTest


let photoArrayStub: [Photo] = [Photo(
    id: "1",
    size: CGSize(width: 1.0, height: 1.0),
    createdAt: nil,
    welcomeDescription: nil,
    thumbImageURL: "",
    largeImageURL: "",
    isLiked: false
)]

final class ImagesListServiceSpy: ImagesListServiceProtocol {
    var photos: [ImageFeed.Photo] = photoArrayStub
    var fetchPhotosNextPageCalled = false
    var changeLikeCall = false

    func fetchPhotosNextPage() {
        fetchPhotosNextPageCalled = true
    }

    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        changeLikeCall = true
    }
}

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    var viewDidLoadCalled: Bool = false
    var imagesListService: ImagesListServiceProtocol?
    weak var view: ImagesListViewControllerProtocol?

    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didTapLike(for cell: ImageFeed.ImagesListCell) {
    }
    
    func imagesListServiseObserver() {
    }
}

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    
    var photos: [ImageFeed.Photo] = []
    var getPhotosNextPageCalled = false
    
    func getPhotosNextPage() {
            getPhotosNextPageCalled = true
        }
    func configureTableView() {
    }
    
    func updateTableViewAnimated() {
    }
    
    func indexPath(for cell: ImageFeed.ImagesListCell) -> IndexPath? {
    return nil
    }
}

final class ImageListTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        //given
        let viewController = ImagesListViewController()
        let presenter = ImagesListPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        _ = viewController.view
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    
    
}
