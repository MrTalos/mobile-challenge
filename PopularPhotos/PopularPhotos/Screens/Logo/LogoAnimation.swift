
import FLAnimatedImage

class LogoAnimation: UIView {
    
    @IBOutlet weak var logo: FLAnimatedImageView!
    
    @IBOutlet weak var calculator: UIImageView!
    
    var maskingView: UIView?
    
    var startedPlaying = false

//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        if let data = NSDataAsset(name: "animated_logo")?.data {
//            let gif = FLAnimatedImage(animatedGIFData: data, optimalFrameCacheSize: 3, predrawingEnabled: true)
//            logo.animatedImage = gif
//            logo.loopCompletionBlock = { _ in
//                self.logo.stopAnimating()
//            }
//        }
//    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    init(maskingView: UIView?) {
        super.init(frame: CGRect.zero)
        setup()
        self.maskingView = maskingView
    }
    
    private func setup() {
        initDefaultSubviewFromXib(xibName: "LogoAnimation")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !startedPlaying {
            if let data = NSDataAsset(name: "animated_logo")?.data {
                let gif = FLAnimatedImage(animatedGIFData: data, optimalFrameCacheSize: 3, predrawingEnabled: true)
                logo.animatedImage = gif
                startedPlaying = true
                logo.loopCompletionBlock = { _ in
                    self.logo.stopAnimating()
                    self.loadHomeScreen()
                }
            }
        }
    }
    
    private func loadHomeScreen() {
        let mask = CALayer()
        mask.contents = #imageLiteral(resourceName: "500px_logo_dark").cgImage
        mask.frame = calculator.frame
//        mask.anchorPoint = CGPoint(x: 0.5, y: 0.5)
//        mask.position = CGPoint(x: self.view.frame.size.width / 2, y: self.view.frame.size.height / 2)
        maskingView?.layer.mask = mask
        removeFromSuperview()
    }

}
