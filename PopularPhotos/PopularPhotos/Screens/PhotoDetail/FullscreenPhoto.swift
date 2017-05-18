
import NYTPhotoViewer

class FullscreenPhoto: NSObject, NYTPhoto {
    
    var image: UIImage?
    
    var imageData: Data?
    
    var placeholderImage: UIImage?
    
    let index: Int
    
    var attributedCaptionTitle: NSAttributedString?
    
    var attributedCaptionCredit: NSAttributedString?
    
    var attributedCaptionSummary: NSAttributedString?
    
    init(image: UIImage, index: Int, info: String) {
        self.image = image
        self.index = index
        attributedCaptionTitle = NSAttributedString(string: info, attributes: [NSForegroundColorAttributeName: UIColor.white])
    }
}
