
import FLAnimatedImage

enum LaunchLogoAnimation {
    static func startLogoTransition(rootView: UIView, targetView: UIView?) {
        let logo = LogoAnimation(targetView: targetView)
        rootView.addSubviewWithDefaultConstraints(logo)
        
        let back = UIView()
        back.backgroundColor = ThemeColor.appWhite
        rootView.addSubviewWithDefaultConstraints(back)
        
        rootView.sendSubview(toBack: back)
        rootView.bringSubview(toFront: logo)
        
        logo.animateDidEnd = { (mask: CALayer) in
            
            UIView.animate(withDuration: 0.5, animations: {
                logo.alpha = 0
            }, completion: { (result: Bool) in
                caAnimate(duration: 2,
                          animate: {
                    mask.transform = CATransform3DMakeScale(500, 500, 1)
                }, onComplete: {
                    logo.removeFromSuperview()
                    back.removeFromSuperview()
                    targetView?.layer.mask = nil
                })
            })
        }
    }
    
    private static func caAnimate(duration: TimeInterval,
                                  animate: @escaping ()->(),
                                  onComplete: @escaping ()->()) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(onComplete)
        CATransaction.setAnimationDuration(duration)
        animate()
        CATransaction.commit()
        
    }
}

fileprivate class LogoAnimation: UIView {
    
    @IBOutlet weak var logo: FLAnimatedImageView!
    
    @IBOutlet weak var calculator: UIImageView!
    
    var targetView: UIView?
    
    var startedPlaying = false
    
    var animateDidEnd: ((CALayer)->())?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    init(targetView: UIView?) {
        super.init(frame: CGRect.zero)
        setup()
        self.targetView = targetView
    }
    
    private func setup() {
        initDefaultSubviewFromXib(xibName: "LogoAnimation")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let _ = animateDidEnd, !startedPlaying {
            if let data = NSDataAsset(name: "animated_logo")?.data {
                let gif = FLAnimatedImage(animatedGIFData: data, optimalFrameCacheSize: 3, predrawingEnabled: true)
                logo.animatedImage = gif
                startedPlaying = true
                logo.loopCompletionBlock = { _ in
                    self.logo.stopAnimating()
                    self.maskTarget()
                }
            }
        }
    }
    
    private func maskTarget() {
        let mask = CALayer()
        mask.contents = #imageLiteral(resourceName: "500px_logo_dark").cgImage
        mask.frame = calculator.frame
        targetView?.layer.mask = mask
        animateDidEnd?(mask)
    }

}
