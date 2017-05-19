
import ImageViewer
import SDWebImage

//protocol FullscreenViewModel: GalleryItemsDataSource {
//    
//}

class FullscreenViewModelImpl: GalleryItemsDataSource {
    
    let source: HomeViewModel
    
    init(photoSource: HomeViewModel) {
        source = photoSource
    }
    
    func itemCount() -> Int {
        return source.getPhotosCount()
    }
    
    func provideGalleryItem(_ index: Int) -> GalleryItem {
        return GalleryItem.image { (fetch) in
            SDWebImageManager.shared().downloadImage(with: URL(string: self.source.getPhotoUrl(index: index)), progress: { (done: Int, need: Int) in
                debugPrint(done, need)
            }, completed: { (image: UIImage?, error: Error?, _, result: Bool, request: URL?) in
                fetch(image)
            })
        }
    }
}
