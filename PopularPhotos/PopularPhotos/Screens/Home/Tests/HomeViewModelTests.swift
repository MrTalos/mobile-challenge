
@testable import PopularPhotos

import XCTest

class HomeViewModelTests: XCTestCase {
    
    let mockPhotoService = MockPhotoService()
    let mockViewModelDelegate = MockHomeViewModelDelegate()
    let mockFeature = "popular"
    var homeViewModel: HomeViewModelImpl!
    
    override func setUp() {
        super.setUp()
        homeViewModel = HomeViewModelImpl(feature: mockFeature,
                                          delegate: mockViewModelDelegate,
                                          service: mockPhotoService)
    }
    
    private func createMockPhotos(quantity: Int) -> [Photo] {
        return (0..<quantity).map {
            Photo(id: Int64($0), name: "anyname", desc: nil, imageUrl: "anyurl", width: $0*3, height: $0*2)
        }
    }
    
    func testItReturnsRightInformation() {
        let totalCount = 10
        mockPhotoService.mock = createMockPhotos(quantity: totalCount)
        
        homeViewModel.refreshPhotos()
        
        XCTExpectEqual(actual: homeViewModel.getPhotosCount(), expected: totalCount)
        XCTExpectEqual(actual: homeViewModel.getPhotoUrl(index: totalCount), expected: "")
        XCTExpectEqual(actual: homeViewModel.getPhotoUrl(index: 3), expected: "anyurl")
        XCTExpectEqual(actual: homeViewModel.getPhotoSize(index: 5).width, expected: 15)
    }
    
    func testItKnowsFirstPageIsOne() {
        mockPhotoService.mock = createMockPhotos(quantity: 0)
        
        homeViewModel.refreshPhotos()
        XCTExpectEqual(actual: mockPhotoService.fetchAndClearPageCalled(), expected: 1)
        
        homeViewModel.refreshPhotos()
        XCTExpectEqual(actual: mockPhotoService.fetchAndClearPageCalled(), expected: 1)
    }
    
    func testItDoesLoadingMoreCorrectly() {
        let firstBatchMockPhotos = createMockPhotos(quantity: 15)
        let secondBatchMockPhotos = createMockPhotos(quantity: 25)
        
        mockPhotoService.mock = firstBatchMockPhotos
        homeViewModel.refreshPhotos()
        var imagesUpdated = mockViewModelDelegate.fetchAndClearUpdateImagesCapture()
        XCTExpectEqual(actual: imagesUpdated?.0, expected: 0)
        XCTExpectEqual(actual: imagesUpdated?.1, expected: 0)
        XCTExpectEqual(actual: imagesUpdated?.2, expected: 15)
        
        mockPhotoService.mock = secondBatchMockPhotos
        homeViewModel.loadMorePhotos()
        imagesUpdated = mockViewModelDelegate.fetchAndClearUpdateImagesCapture()
        XCTExpectEqual(actual: imagesUpdated?.0, expected: 15)
        XCTExpectEqual(actual: imagesUpdated?.1, expected: 15)
        XCTExpectEqual(actual: imagesUpdated?.2, expected: 40)
    }
    
    func testItCallsCorrectDidEnds() {
        mockPhotoService.mock = createMockPhotos(quantity: 15)
        
        homeViewModel.refreshPhotos()
        XCTExpectEqual(actual: mockViewModelDelegate.fetchAndClearRefreshDidEndCalled(), expected: true)
        XCTExpectEqual(actual: mockViewModelDelegate.fetchAndClearLoadingMoreDidEndCalled(), expected: false)
        
        homeViewModel.loadMorePhotos()
        XCTExpectEqual(actual: mockViewModelDelegate.fetchAndClearRefreshDidEndCalled(), expected: false)
        XCTExpectEqual(actual: mockViewModelDelegate.fetchAndClearLoadingMoreDidEndCalled(), expected: true)
    }
    
    func testItDoesntUpdateViewWhenFailed() {
        mockPhotoService.mock = createMockPhotos(quantity: 0)
        
        homeViewModel.refreshPhotos()
        XCTAssertNil(mockViewModelDelegate.fetchAndClearUpdateImagesCapture())
        
        homeViewModel.loadMorePhotos()
        XCTAssertNil(mockViewModelDelegate.fetchAndClearUpdateImagesCapture())
    }
    
    func testItRetriesWhenFailed() {
        mockPhotoService.mock = createMockPhotos(quantity: 0)
        
        homeViewModel.refreshPhotos()
        XCTExpectEqual(actual: mockPhotoService.fetchAndClearPageCalled(), expected: 1)
        
        homeViewModel.loadMorePhotos()
        XCTExpectEqual(actual: mockPhotoService.fetchAndClearPageCalled(), expected: 1)
    }
    
}
