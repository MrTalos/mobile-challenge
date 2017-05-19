import Foundation
import CoreGraphics
import Alamofire

class Photo {
    
    let id: Int64
    let name: String
    let user: String
    let imageUrl: String
    let size: CGSize
    
    init(id: Int64, name: String, user: String, imageUrl: String, width: Int, height: Int) {
        self.id = id
        self.name = name
        self.user = user
        self.imageUrl = imageUrl
        size = CGSize(width: width, height: height)
    }
    
}
