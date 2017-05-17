
@testable import PopularPhotos

import XCTest
import Alamofire

class PhotoServiceImplTest: XCTestCase {
    
    let mockService = MockHTTPService()
    var photoService: PhotoServiceImpl!
    
    override func setUp() {
        super.setUp()
        photoService = PhotoServiceImpl(httpService: mockService)
        
    }
    
    func testItSendsCorrectRequests() {
        
        mockService.mock = [
            "https://api.500px.com/v1/photos":
                mockService.createErrorResponse(error: .serverError)
        ]
        mockService.validateRequest = { (request: URLRequestConvertible) in
            let method = request.urlRequest?.httpMethod
            XCTExpectEqual(actual: method, expected: "GET")
            guard let url = request.urlRequest?.url?.absoluteString else {
                XCTFail("url is empty")
                return
            }
            XCTAssertNotNil(url.range(of: "exclude%5B%5D=Nude"))
            XCTAssertNotNil(url.range(of: "exclude%5B%5D=random"))
            XCTAssertNotNil(url.range(of: "feature=not_popular"))
            XCTAssertNotNil(url.range(of: "page=2"))
        }
        
        photoService.getPhotos(feature: "not_popular", page: 2, exclude: ["Nude", "random"]) { (photos: [Photo]) in
            XCTExpectEqual(actual: photos.count, expected: 0)
        }
        
    }
    
    func testItParsesCorrectly() {
        
        mockService.mock = [
            "https://api.500px.com/v1/photos":
                mockService.createJsonResponse(jsonString: getString(fromFile: "GetPhotosSuccessJson", "txt"))
        ]
        
        photoService.getPhotos(feature: "popular", page: 1, exclude: []) { (photos: [Photo]) in
            XCTExpectEqual(actual: photos.count, expected: 25)
            XCTExpectEqual(actual: photos[0].id, expected: 212189651)
            XCTExpectEqual(actual: photos[22].id, expected: 212184499)
        }
    }
    
}
