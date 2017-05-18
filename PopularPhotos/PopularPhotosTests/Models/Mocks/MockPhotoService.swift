
@testable import PopularPhotos

class MockPhotoService: PhotoService {
    
    var mock: [Photo]!
    
    private var pageCalled: Int?
    
    func fetchAndClearPageCalled() -> Int? {
        let ret = pageCalled
        pageCalled = nil
        return ret
    }
    
    func getPhotos(feature: String, page: Int, exclude: String?, onComplete: @escaping ([Photo]) -> ()) {
        pageCalled = page
        onComplete(mock)
    }
    
}
