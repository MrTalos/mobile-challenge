
import UIKit

import ESPullToRefresh
import GreedoLayout
import NYTPhotoViewer
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
    
    weak var focusedFullscreen: FullscreenPhoto?
    
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
        
        if let fullscreen = focusedFullscreen {
            let index = IndexPath(row: fullscreen.index, section: 0)
            collectionView.scrollToItem(at: index, at: .centeredVertically, animated: true)
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
        let test = layout.sizeForPhoto(at: indexPath)
        return test
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

extension HomeCollectionViewController: NYTPhotosViewControllerDelegate {
    
    // MARK: - NYTPhoto related
    
    fileprivate func displayPhoto(indexPath: IndexPath) {
        guard let cell = collectionView?.cellForItem(at: indexPath) as? PhotoThumbnailCollectionViewCell,
                let loadedImage = cell.imageObj else {
            return
        }
        let detailed = FullscreenPhoto(image: loadedImage, index: indexPath.row,
                                       info: homeViewModel.getPhotoName(index: indexPath.row))
        let photosViewController = NYTPhotosViewController(photos: [detailed], initialPhoto: detailed, delegate: self)
        present(photosViewController, animated: true, completion: nil)
        focusedFullscreen = detailed
    }
    
    func photosViewController(_ photosViewController: NYTPhotosViewController, referenceViewFor photo: NYTPhoto) -> UIView? {
        guard let photo = photo as? FullscreenPhoto else {
            return nil
        }
        return collectionView?.cellForItem(at: IndexPath(row: photo.index, section: 0))
    }
    
}
