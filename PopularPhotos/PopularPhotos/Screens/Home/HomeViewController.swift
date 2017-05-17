
import UIKit

import GreedoLayout
import SDWebImage

protocol HomeViewModelDelegate {
    
}

class HomeViewModelDelegateImpl: HomeViewModelDelegate {
    
    weak var controller: HomeCollectionViewController?
    
    init(controller: HomeCollectionViewController) {
        self.controller = controller
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
    
    var viewModel: HomeViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupViewModel()
    }
    
    private func setupLayout() {
        layout = GreedoCollectionViewLayout(collectionView: collectionView)
        layout.fixedHeight = false
        layout.dataSource = self
    }
    
    private func setupViewModel() {
        viewModel = HomeViewModelImpl(feature: "popular", delegate: HomeViewModelDelegateImpl(controller: self))
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
        
        let visibleIndexpaths = collectionView.indexPathsForVisibleItems
        if let first = visibleIndexpaths.first, first.row > 0 {
            layout.clearCache(after: IndexPath(row: first.row - 1, section: first.section))
        } else {
            layout.clearCache()
        }
        
        collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
        
    }
    
}

extension HomeCollectionViewController {
    
    // MARK: - UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.getPhotosCount()
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "thumbnailCell", for: indexPath)
        if let cell = cell as? PhotoThumbnailCollectionViewCell,
                let url = URL(string: viewModel.getThumbnailUrl(index: indexPath.row)) {
            cell.image.sd_setImage(with: url, placeholderImage: UIImage(named: "thumbnail-placeholder"))
        }
        return cell
    }
    
}

extension HomeCollectionViewController {
    
    // MARK: - UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
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
        return viewModel.getPhotoSize(index: indexPath.row)
    }
    
}
