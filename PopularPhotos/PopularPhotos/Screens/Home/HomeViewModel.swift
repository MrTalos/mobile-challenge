import Foundation

import GreedoLayout

protocol HomeViewModel {
    func getPhotosCount() -> Int
    func getPhotoSize(index: Int) -> CGSize
    func getThumbnailUrl(index: Int) -> String
    func getPhotoUrl(index: Int) -> String
    func refreshPhotos()
    func loadMorePhotos()
}

class HomeViewModelImpl: NSObject, HomeViewModel {
    
    let feature: String
    let service: PhotoService
    
    var photos: [Photo] = []
    
    init(feature: String, delegate: HomeViewModelDelegate, service: PhotoService = PhotoServiceImpl.instance) {
        self.feature = feature
        self.service = service
        photos.append(Photo(id: 212029119, name: "Vika", desc: "", imageUrl: "https://drscdn.500px.org/photo/212029119/m%3D900_k%3D1_a%3D1/14e68bd7c4c6f29772b943222ebb3fcc", width: 1600, height: 900))
        
        photos.append(Photo(id: 212089563, name: "At the Beach", desc: "", imageUrl: "https://drscdn.500px.org/photo/212089563/m%3D900_k%3D1_a%3D1/bfc37abcbf2c347d1b293fd36beafd38", width: 2750, height: 1972))
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
    
    func getThumbnailUrl(index: Int) -> String {
        return index < photos.count ? photos[index].imageUrl : ""
    }
    
    func getPhotoUrl(index: Int) -> String {
        return index < photos.count ? photos[index].imageUrl : ""
    }
    
    func refreshPhotos() {
//        service.getPhotos(feature: feature, page: 0, exclude: ["Nude"]) { [weak self] (photos: [Photo]) in
//            if let ref = self {
//                ref.photos = photos
//                
//            }
//        }
    }
    
    func loadMorePhotos() {
        
    }
    
}
