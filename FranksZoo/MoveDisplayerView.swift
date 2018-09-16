import UIKit

class MoveDisplayerView: UIView {
    var displayedMove: Move? {
        didSet {
            setNeedsDisplay()
        }
    }
    
}
