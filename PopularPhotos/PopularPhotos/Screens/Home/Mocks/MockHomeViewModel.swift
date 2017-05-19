
@testable import PopularPhotos

import CoreGraphics

class MockHomeViewModel: HomeViewModel {
    
    var mock: [String]!
    
    var refreshPhotosCallback = {}
    
    var loadMorePhotosCallback = {}
    
    var mockLoading = false
    
    func getPhotosCount() -> Int {
        return mock.count
    }
    
    func getPhotoSize(index: Int) -> CGSize {
        return CGSize(width: 1960, height: 1080)
    }
    
    func getPhotoUrl(index: Int) -> String {
        return mock[index]
    }
    
    func getPhotoName(index: Int) -> String {
        return mock[index]
    }
    
    func refreshPhotos() {
        refreshPhotosCallback()
    }
    
    func loadMorePhotos() {
        loadMorePhotosCallback()
    }
    
    func isLoading() -> Bool {
        return mockLoading
    }
}
