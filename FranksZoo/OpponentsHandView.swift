import UIKit

/// A view that shows only the backsides of a certain number of cards
class OpponentsHandView : UIView {
    /// The possible orientations of the opponent's hand shown
    @objc enum Orientation: Int {
        case right
        case down
        case left
    }
    
    private var imageViews: [UIImageView] = []
    
    /// The number of cards the opponent's hand contains
    @IBInspectable
    var numberOfCards: Int = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// The orientaton of the opponent's hand
    @IBInspectable
    var orientation: Orientation = .right {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// The text shown next to the cards to indicate the name of the opponent.
    @IBInspectable
    var labelText: String = "" {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        repositionViews()
    }
    
    fileprivate func addImageViews() {
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
        // calculate the centers of each image view for each orientation
        switch orientation {
        case .left, .right:
            let x = width / 2
            let cardHeight = width / 7 * 5
            let offset = 10.f / 38 * cardHeight
            let cardsHeight = cardHeight + offset * (numberOfCards.f - 1)
            let top = height / 2 - cardsHeight / 2
            let topCardCenter = top + cardHeight / 2
            for i in 0..<numberOfCards {
                imageCenters.append(CGPoint(x: x, y: topCardCenter + i.f * offset))
            }
        case .down:
            let y = height / 2
            let cardWidth = height / 7 * 5
            let offset = 10.f / 38 * cardWidth
            let cardsWidth = cardWidth + offset * (numberOfCards.f - 1)
            let right = width / 2 - cardsWidth / 2
            let rightCardCenter = right + cardWidth / 2
            for i in 0..<numberOfCards {
                imageCenters.append(CGPoint(x: rightCardCenter + i.f * offset, y: y))
            }
        }
        
        // calculate the angle about which the image views should be rotated
        // for each orientation
        var rotationAngle: CGFloat
        switch orientation {
        case .right:
            rotationAngle = .pi / 2
        case .left:
            rotationAngle = -.pi / 2
            imageCenters.reverse()
        case .down:
            rotationAngle = .pi
            imageCenters.reverse()
        }
        
        zip(imageViews, imageCenters).forEach {
            $0.0.center = $0.1
            $0.0.transform = CGAffineTransform(rotationAngle: rotationAngle)
        }
        imageViews.forEach(addSubview)
    }
    
    fileprivate func addLabel() {
        let height: CGFloat
        let width: CGFloat
        let centerX: CGFloat
        let centerY: CGFloat
        let rotationAngle: CGFloat
        // calculate the frame of the label for each orientation
        switch orientation {
        case .right:
            height = self.width / 5
            width = self.height
            centerX = height + self.bounds.maxX
            centerY = self.bounds.midY
            rotationAngle = .pi / 2
        case .left:
            height = self.width / 5
            width = self.height
            centerX = -height
            centerY = self.bounds.midY
            rotationAngle = -.pi / 2
        case .down:
            height = self.height / 5
            width = self.width
            centerX = self.width / 2
            centerY = height + self.height
            rotationAngle = 0
        }
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: height))
        label.text = labelText
        label.updateFontSizeToFit(size: label.bounds.size, multiplier: 0.75)
        label.center = CGPoint(x: centerX, y: centerY)
        label.textAlignment = .center
        label.textColor = .white
        label.transform = CGAffineTransform(rotationAngle: rotationAngle)
        self.addSubview(label)
    }
    
    func repositionViews() {
        subviews.forEach { $0.removeFromSuperview() }
        imageViews.removeAll()
        
        addImageViews()
        addLabel()
    }
}
