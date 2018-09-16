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
        
    }
}
