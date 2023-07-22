import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController {
    var imageURL: URL?

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var scrollView: UIScrollView!

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 3
        setImage()
    }

    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }

    @IBAction private func didTapShareButton(_ sender: UIButton) {
        guard let image = imageView.image else { return }
        let share = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(share, animated: true)
    }

    private func setImage() {
        guard let url = imageURL else { return }
        UIBlockingProgressHUD.show()
        let placeholder: UIImage = .placeholderImage
        imageView.kf.setImage(with: url, placeholder: placeholder) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self else { return }
            switch result {
            case .success(let imageResult):
                self.rescaleAndCenterImageInScrollView(image: imageResult.image)
            case .failure:
                self.showImageAlert()
                return
            }
        }
        guard let image = imageView.image else { return }
        self.rescaleAndCenterImageInScrollView(image: image)
    }

    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, max(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let contentOffsetX = (newContentSize.width - visibleRectSize.width) / 2
        let contentOffsetY = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: contentOffsetX, y: contentOffsetY), animated: false)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }

    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        centerImageInScrollView()
    }

    private func centerImageInScrollView() {
        guard let imageView = imageView else { return }
        let imageSize = imageView.frame.size
        let scrollSize = scrollView.bounds.size
        let verticalInset = imageSize.height < scrollSize.height ? (scrollSize.height - imageSize.height) / 2 : 0
        let horizontalInset = imageSize.width < scrollSize.width ? (scrollSize.width - imageSize.width) / 2 : 0
        let contentInset = UIEdgeInsets(top: verticalInset,
                                        left: horizontalInset,
                                        bottom: verticalInset,
                                        right: horizontalInset)
        scrollView.contentInset = contentInset
    }

    private func showImageAlert() {
        AlertPresenter.showAlert(in: presentedViewController ?? self, model: AlertModel.alertShowImage)
    }
}
