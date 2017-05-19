
@testable import PopularPhotos

import XCTest

class HomeCollectionViewControllerTests: XCTestCase {
    
    let mockViewModel = MockHomeViewModel()
    let homeController = HomeCollectionViewController()
    
    var createMocks: (Int)->[String] = { (count: Int) in
        let ret = (0..<count).map {
            "\($0)"
        }
        return ret
    }
    
    override func setUp() {
        super.setUp()
        homeController.homeViewModel = mockViewModel
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testItOnlyLoadsMorePhotosNearEnd() {
        mockViewModel.mock = createMocks(50)
        mockViewModel.loadMorePhotosCallback = { XCTFail() }
        homeController.loadMorePhotosIfAlmostReachingEnd(index: 0)
        homeController.loadMorePhotosIfAlmostReachingEnd(index: 10)
        homeController.loadMorePhotosIfAlmostReachingEnd(index: 40)
        homeController.loadMorePhotosIfAlmostReachingEnd(index: 39)
        
        var called = false
        mockViewModel.loadMorePhotosCallback = {
            called = true
        }
        homeController.loadMorePhotosIfAlmostReachingEnd(index: 46)
        
        XCTExpectEqual(actual: called, expected: true)
    }
    
}
