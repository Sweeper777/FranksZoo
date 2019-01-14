import UIKit

class MoveDisplayerView: UIView {
    var displayedMove: Move? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var cardSize: CGSize = .zero {
        didSet {
            setNeedsDisplay()
        }
    }
    
    func calculateCardXs(cards: [Card]) -> [CGFloat] {
        
        var separator = cardSize.width / 4
        if cards.count.f * (separator + cardSize.width) > self.width {
            separator = (self.width - cards.count.f * cardSize.width) / (cards.count.f + 1)
        }
        let leftmostCardX = (self.width - (cards.count.f * cardSize.width + separator * (cards.count.f - 1))) / 2
        return (0..<cards.count).map {
            leftmostCardX + $0.f * (cardSize.width + separator)
        }
    }
    
    override func draw(_ rect: CGRect) {
        self.subviews.forEach { $0.removeFromSuperview() }
        
        guard let move = displayedMove else {
            return
        }
        
        let cards = move.toArray()
        
        guard cards.count > 0 else { return }
        
        let cardY = (self.height - cardSize.height) / 2
        
        for (x, card) in zip(calculateCardXs(cards: cards), cards) {
            let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: x, y: cardY), size: cardSize))
            imageView.image = UIImage(named: imageDict[card]!)
            self.addSubview(imageView)
        }
    }
    
    private func animateMoveVertically(move: Move, startY: CGFloat, completion: @escaping () -> Void) {
        let cards = move.toArray()
        var imageViews = [UIImageView]()
        
        for (x, card) in zip(calculateCardXs(cards: cards), cards) {
            let image = UIImage(named: imageDict[card]!)
            let y = startY
            let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: x, y: y), size: cardSize))
            imageView.image = image
            imageViews.append(imageView)
            self.addSubview(imageView)
        }
        
        UIView.animate(withDuration: 0.5, animations: {
            for imageView in imageViews {
                imageView.y = (self.height - self.cardSize.height) / 2
            }
        }, completion: {
            _ in
            self.displayedMove = move
            completion()
        })
    }
}
