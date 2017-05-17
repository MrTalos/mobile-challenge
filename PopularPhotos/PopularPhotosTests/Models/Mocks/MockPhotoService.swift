
@testable import PopularPhotos

class MockPhotoService: PhotoService {
    
    func getPhotos(feature: String, page: Int, exclude: [String], onComplete: @escaping ([Photo]) -> ()) {
    }
    
}
