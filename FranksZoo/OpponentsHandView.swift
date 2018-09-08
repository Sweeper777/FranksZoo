import UIKit

class OpponentsHandView : UIView {
    @objc enum Orientation: Int {
        case right
        case down
        case left
    }
    
    private var imageViews: [UIImageView] = []
    
    @IBInspectable
    var numberOfCards: Int = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var orientation: Orientation = .right {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        repositionViews()
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
        
        var imageCenters = [CGPoint]()
        switch orientation {
        case .left, .right:
            let x = width / 2
            let cardHeight = width / 7 * 5
            let offset = 10.f
            let cardsHeight = cardHeight + offset * (numberOfCards.f - 1)
            let top = height / 2 - cardsHeight / 2
            let topCardCenter = top + cardHeight / 2
            for i in 0..<numberOfCards {
                imageCenters.append(CGPoint(x: x, y: topCardCenter + i.f * offset))
            }
        case .down:
            let y = height / 2
            let cardWidth = height / 7 * 5
            let offset = 10.f
            let cardsWidth = cardWidth + offset * (numberOfCards.f - 1)
            let right = width / 2 - cardsWidth / 2
            let rightCardCenter = right + cardWidth / 2
            for i in 0..<numberOfCards {
                imageCenters.append(CGPoint(x: rightCardCenter + i.f * offset, y: y))
            }
            break
        }
        
        var rotationAngle: CGFloat
        switch orientation {
        case .right:
            rotationAngle = .pi / 2
        case .left:
            rotationAngle = .pi / 2 * 3
            imageCenters.reverse()
        case .down:
            rotationAngle = .pi
        }
        
        zip(imageViews, imageCenters).forEach {
            $0.0.center = $0.1
            $0.0.transform = CGAffineTransform(rotationAngle: rotationAngle)
        }
        imageViews.forEach(addSubview)
        
    }
}
