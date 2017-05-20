import Foundation
import CoreGraphics
import Alamofire

class Photo {
    
    let id: Int64
    let name: String
    let rating: Double
    let user: String
    let imageUrl: String
    let size: CGSize
    
    init?(photoJson: [String: Any]) {
        guard let id = photoJson["id"] as? Int64,
            let name = photoJson["name"] as? String,
            let rating = photoJson["rating"] as? Double,
            let imageUrls = photoJson["image_url"] as? [String],
            let userJson = photoJson["user"] as? [String: Any],
            let user = userJson["fullname"] as? String,
            let imageUrl = imageUrls.last,
            let width = photoJson["width"] as? Int,
            let height = photoJson["height"] as? Int else {
                return nil
        }
        self.id = id
        self.name = name
        self.rating = rating
        self.user = user
        self.imageUrl = imageUrl
        size = CGSize(width: width, height: height)
    }
    
}
