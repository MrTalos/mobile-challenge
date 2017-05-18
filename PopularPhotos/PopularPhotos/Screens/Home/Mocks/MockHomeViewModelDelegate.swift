
@testable import PopularPhotos

import XCTest

class MockHomeViewModelDelegate: HomeViewModelDelegate {
    
    private var refreshDidEndCalled = false
    private var loadingMoreDidEndCalled = false
    private var updateImagesCapture: (Int, Int, Int)?
    
    func fetchAndClearUpdateImagesCapture() -> (Int, Int, Int)? {
        let capture = updateImagesCapture
        updateImagesCapture = nil
        return capture
    }
    
    func fetchAndClearRefreshDidEndCalled() -> Bool {
        let ret = refreshDidEndCalled
        refreshDidEndCalled = false
        return ret
    }
    
    func fetchAndClearLoadingMoreDidEndCalled() -> Bool {
        let ret = loadingMoreDidEndCalled
        loadingMoreDidEndCalled = false
        return ret
    }
    
    func refreshDidEnd() {
        refreshDidEndCalled = true
    }
    
    func loadingMoreDidEnd() {
        loadingMoreDidEndCalled = true
    }
    
    func updateImages(oldImageCount: Int, changeStart: Int, changeEnd: Int) {
        updateImagesCapture = (oldImageCount, changeStart, changeEnd)
    }
    
}
