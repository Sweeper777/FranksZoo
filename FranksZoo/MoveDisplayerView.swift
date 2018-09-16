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
    
    override func draw(_ rect: CGRect) {
        self.subviews.forEach { $0.removeFromSuperview() }
        
        guard let move = displayedMove else {
            return
        }
        
        let cards = move.toArray()
        
        guard cards.count > 0 else { return }
        
        if cards.count > 1 {
            let totalWidth = cardSize.width * cards.count.f
            let whitespace = self.width - totalWidth - 20
            let separator = whitespace / (cards.count.f + 1)
            for i in 0..<cards.count {
                let image = UIImage(named: imageDict[cards[i]]!)
                let x = 10 + (cardSize.width + separator) * i.f
                let y = center.y - cardSize.height / 2
                image?.draw(in: CGRect(origin: CGPoint(x: x, y: y), size: cardSize))
            }
        } else {
        }
    }
}
