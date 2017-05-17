
@testable import PopularPhotos

import CoreGraphics

class MockHomeViewModel: HomeViewModel {
    
    var mock: [String]!
    
    func getPhotosCount() -> Int {
        return mock.count
    }
    
    func getPhotoSize(index: Int) -> CGSize {
        return CGSize(width: 1960, height: 1080)
    }
    
    func getThumbnailUrl(index: Int) -> String {
        return mock[index]
    }
    
    func getPhotoUrl(index: Int) -> String {
        return mock[index]
    }
    
    func refreshPhotos() {
        
    }
    
    func loadMorePhotos() {
        
    }
}
