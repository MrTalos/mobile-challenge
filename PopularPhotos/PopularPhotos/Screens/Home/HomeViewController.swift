
import UIKit

import ESPullToRefresh
import GreedoLayout
import ImageViewer
import SDWebImage

protocol HomeViewModelDelegate {
    func refreshDidEnd()
    func loadingMoreDidEnd()
    func updateImages(oldImageCount: Int, changeStart: Int, changeEnd: Int)
}

class HomeViewModelDelegateImpl: HomeViewModelDelegate {
    
    weak var controller: HomeCollectionViewController?
    
    init(controller: HomeCollectionViewController) {
        self.controller = controller
    }
    
    func refreshDidEnd() {
        controller?.collectionView?.es_stopPullToRefresh()
    }
    
    func loadingMoreDidEnd() {
        controller?.collectionView?.es_stopLoadingMore()
    }
    
    func updateImages(oldImageCount: Int, changeStart: Int, changeEnd: Int) {
        let indexPaths = (changeStart..<changeEnd).map{
            IndexPath(row: $0, section: 0)
        }
        controller?.layout.clearCache()
        if oldImageCount == changeStart {
            controller?.collectionView?.insertItems(at: indexPaths)
        } else {
            controller?.collectionView?.reloadData()
        }
    }
    
}

private enum HomeConsts {
    
    static let normalMaxHeight: CGFloat = 150.0
    static let alternativeMaxHeight: CGFloat = 300.0
    
    static let collectionViewInsetNormal: CGFloat = 10.0
    static let collectionViewInsetWithStatusBar: CGFloat = 25.0
    
}

class HomeCollectionViewController: UICollectionViewController {
    
    var layout: GreedoCollectionViewLayout!
    
    var homeViewModel: HomeViewModel!
    
    var fullscreenViewController: GalleryViewController?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupViewModel()
        setupPullToRefresh()
    }
    
    private func setupLayout() {
        layout = GreedoCollectionViewLayout(collectionView: collectionView)
        layout.fixedHeight = false
        layout.dataSource = self
    }
    
    private func setupViewModel() {
        homeViewModel = HomeViewModelImpl(feature: "popular", delegate: HomeViewModelDelegateImpl(controller: self))
        homeViewModel.loadMorePhotos()
    }
    
    private func setupPullToRefresh() {
        collectionView?.es_addPullToRefresh {
            self.homeViewModel.refreshPhotos()
        }
        collectionView?.es_addInfiniteScrolling {
            self.homeViewModel.loadMorePhotos()
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        guard let collectionView = collectionView else {
            return
        }
        
        let maxHeight: CGFloat
        switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
        case (.compact, .regular):
            maxHeight = HomeConsts.normalMaxHeight
        default:
            maxHeight = HomeConsts.alternativeMaxHeight
        }
        layout.rowMaximumHeight = maxHeight
        
        layout.clearCache()
        collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
        
        if let fullscreenViewController = fullscreenViewController {
            keepPhotoCellInVisibleRange(index: fullscreenViewController.currentIndex)
        }
    }
    
}

extension HomeCollectionViewController {
    
    // MARK: - UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return homeViewModel.getPhotosCount()
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "thumbnailCell", for: indexPath)
        if let cell = cell as? PhotoThumbnailCollectionViewCell,
                let url = URL(string: homeViewModel.getPhotoUrl(index: indexPath.row)) {
            cell.image.sd_setImage(
                with: url, placeholderImage: UIImage(named: "500px_mark_light"),
                options: .continueInBackground,
                completed: { (image: UIImage?, error: Error?, cacheType: SDImageCacheType, requestUrl:URL?) in
                cell.imageObj = image
            })
        }
        return cell
    }
    
}

extension HomeCollectionViewController {
    
    // MARK: - UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        displayPhoto(indexPath: indexPath)
    }
    
}

extension HomeCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return layout.sizeForPhoto(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        let topInset: CGFloat
        let inset = HomeConsts.collectionViewInsetNormal
        switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
        case (.compact, .regular):
            topInset = HomeConsts.collectionViewInsetWithStatusBar
        default:
            topInset = HomeConsts.collectionViewInsetNormal
        }
        return UIEdgeInsets(top: topInset, left: inset, bottom: inset, right: inset)
    }
    
}

extension HomeCollectionViewController: GreedoCollectionViewLayoutDataSource {
    
    func greedoCollectionViewLayout(_ layout: GreedoCollectionViewLayout!,
                                    originalImageSizeAt indexPath: IndexPath!) -> CGSize {
        return homeViewModel.getPhotoSize(index: indexPath.row)
    }
    
}

extension HomeCollectionViewController: GalleryDisplacedViewsDataSource {
    
    fileprivate func displayPhoto(indexPath: IndexPath) {
        fullscreenViewController = GalleryViewController(
            startIndex: indexPath.row,
            itemsDataSource: FullscreenViewModelImpl(photoSource: homeViewModel),
            displacedViewsDataSource: self,
            configuration: [.deleteButtonMode(.none),
                            .thumbnailsButtonMode(.none),
                            .headerViewLayout(.pinLeft(25, 10)),
                            .footerViewLayout(.pinRight(25, 10))])
        
        fullscreenViewController!.landedPageAtIndexCompletion = { (page: Int) in
            self.keepPhotoCellInVisibleRange(index: page)
            self.loadMorePhotosIfAlmostReachingEnd(index: page)
            self.setupFullscreenLabels(index: page)
        }
        
        fullscreenViewController!.closedCompletion = {
            self.fullscreenViewController = nil
        }
        
        self.presentImageGallery(fullscreenViewController!, completion: nil)
    }
    
    func provideDisplacementItem(atIndex index: Int) -> DisplaceableView? {
        guard let cell = collectionView?.cellForItem(at: IndexPath(row: index, section: 0)) as? PhotoThumbnailCollectionViewCell else {
            return nil
        }
        return cell.image
    }
    
    func keepPhotoCellInVisibleRange(index: Int) {
        let index = IndexPath(row: index, section: 0)
        collectionView?.scrollToItem(at: index, at: .centeredVertically, animated: true)
    }
    
    func loadMorePhotosIfAlmostReachingEnd(index: Int) {
        if homeViewModel.getPhotosCount() - index < 5, !homeViewModel.isLoading() {
            homeViewModel.loadMorePhotos()
        }
    }
    
    private func setupFullscreenLabels(index: Int) {
        let create: (UIColor) -> UILabel = { (color: UIColor) in
            let label = UILabel()
            label.textColor = color
            return label
        }
        let updateNames = { (header: UILabel, footer: UILabel) in
            header.text = self.homeViewModel.getPhotoName(index: index)
            footer.text = self.homeViewModel.getAuthorName(index: index)
        }
        if let header = fullscreenViewController?.headerView as? UILabel,
            let footer = fullscreenViewController?.footerView as? UILabel {
            updateNames(header, footer)
        } else {
            let header = create(UIColor.white)
            let footer = create(UIColor.lightGray)
            fullscreenViewController?.headerView = header
            fullscreenViewController?.footerView = footer
            updateNames(header, footer)
        }
    }
    
}
