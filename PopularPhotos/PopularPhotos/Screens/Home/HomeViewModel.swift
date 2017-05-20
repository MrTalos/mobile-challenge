
import UIKit

protocol HomeViewModel {
    
    func getPhotosCount() -> Int
    
    func getPhotoSize(index: Int) -> CGSize
    
    func getPhotoUrl(index: Int) -> String
    
    func getPhotoName(index: Int) -> String
    
    func getRating(index: Int) -> Double
    
    func getAuthorName(index: Int) -> String
    
    func refreshPhotos()
    
    func loadMorePhotos()
    
    func isLoading() -> Bool
    
}

class HomeViewModelImpl: NSObject, HomeViewModel {
    
    let feature: String
    let delegate: HomeViewModelDelegate
    let service: PhotoService
    
    var photos: [Photo] = []
    var loadedPage = 0
    private var loading = false
    
    init(feature: String, delegate: HomeViewModelDelegate, service: PhotoService = PhotoServiceImpl.instance) {
        self.feature = feature
        self.delegate = delegate
        self.service = service
    }
    
    func getPhotosCount() -> Int {
        return photos.count
    }
    
    func getPhotoSize(index: Int) -> CGSize {
        if index < photos.count {
            return photos[index].size
        }
        return CGSize(width: 0, height: 0)
    }
    
    func getPhotoUrl(index: Int) -> String {
        return index < photos.count ? photos[index].imageUrl : ""
    }
    
    func getPhotoName(index: Int) -> String {
        return index < photos.count ? photos[index].name : ""
    }
    
    func getRating(index: Int) -> Double {
        return index < photos.count ? photos[index].rating : 0
    }
    
    func getAuthorName(index: Int) -> String {
        return index < photos.count ? photos[index].user : ""
    }
    
    func refreshPhotos() {
        loadedPage = 0
        loadMorePhotos()
    }
    
    func loadMorePhotos() {
        let page = loadedPage + 1
        loading = true
        service.getPhotos(feature: feature, page: page, exclude: "Nude") { [weak self] (photos: [Photo]) in
            if let ref = self {
                ref.loading = false
                let oldSize = ref.photos.count
                if page == 1 {
                    ref.delegate.refreshDidEnd()
                    if photos.count > 0 {
                        ref.photos.removeAll()
                    }
                } else {
                    ref.delegate.loadingMoreDidEnd()
                }
                if photos.count > 0, page < ref.loadedPage + 2 {
                    let currentIndex = ref.photos.count
                    ref.loadedPage = page
                    ref.photos = ref.photos + photos
                    ref.delegate.updateImages(
                        oldImageCount: oldSize, changeStart: currentIndex,
                        changeEnd: currentIndex + photos.count)
                }
            }
        }
    }
    
    func isLoading() -> Bool {
        return loading
    }
    
}
