
import UIKit

extension UIView {
    public func addSubviewWithDefaultConstraints(_ subview: UIView) {
        self.addSubviewWithConstraints(subview, achorPoint: CGPoint(x: 0.5, y: 0.5), widthRatio: 1, heightRatio: 1)
    }
    
    public func addSubviewWithConstraints(_ subview: UIView, achorPoint: CGPoint, widthRatio: CGFloat, heightRatio: CGFloat) {
        self.addSubview(subview)
        subview.translatesAutoresizingMaskIntoConstraints = false
        let xConstraint:NSLayoutConstraint = NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.right, multiplier: achorPoint.x, constant: 0)
        let yConstraint:NSLayoutConstraint = NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.bottom, multiplier: achorPoint.y, constant: 0)
        let widthConstraint:NSLayoutConstraint = NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.width, multiplier: widthRatio, constant: 0)
        let heightConstraint:NSLayoutConstraint = NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.height, multiplier: heightRatio, constant: 0)
        self.addConstraint(xConstraint)
        self.addConstraint(yConstraint)
        self.addConstraint(widthConstraint)
        self.addConstraint(heightConstraint)
    }
    
    func initDefaultSubviewFromXib(xibName: String) {
        let view = UINib(nibName: xibName, bundle: nil).instantiate(withOwner: self, options: nil)[0] as! UIView
        self.addSubviewWithDefaultConstraints(view)
    }
}
