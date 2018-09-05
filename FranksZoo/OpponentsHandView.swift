import UIKit

class OpponentsHandView : UIView {
    @objc enum Orientation: Int {
        case right
        case down
        case left
    }
    
    private var imageViews: [UIImageView] = []
    @IBInspectable
    var orientation: Orientation = .right {
        didSet {
            setNeedsDisplay()
        }
    }
    
    func repositionViews() {
        subviews.forEach { $0.removeFromSuperview() }
        imageViews.removeAll()
        
        for _ in 0..<numberOfCards {
            let imageView = UIImageView()
            imageView.image = #imageLiteral(resourceName: "flipside")
            imageView.contentMode = .scaleToFill
            if orientation == .down {
                imageView.frame = CGRect(x: 0, y: 0, width: height / 7 * 5, height: height)
            } else {
                imageView.frame = CGRect(x: 0, y: 0, width: width / 7 * 5, height: width)
            }
            imageViews.append(imageView)
        }
    }
}
