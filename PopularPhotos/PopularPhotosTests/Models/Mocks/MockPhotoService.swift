
@testable import PopularPhotos

import Foundation

class MockPhotoService: PhotoService {
    
    var mock: [Photo]!
    
    var asyncCallback: (() -> ())?
    
    private var pageCalled: Int?
    
    func fetchAndClearPageCalled() -> Int? {
        let ret = pageCalled
        pageCalled = nil
        return ret
    }
    
    func getPhotos(feature: String, page: Int, exclude: String?, onComplete: @escaping ([Photo]) -> ()) {
        pageCalled = page
        if let asyncCallback = asyncCallback {
            let returnMock = mock!
            DispatchQueue.main.async {
                onComplete(returnMock)
                asyncCallback()
            }
        } else {
            onComplete(mock)
        }
    }
    
}
