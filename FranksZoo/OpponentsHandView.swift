import UIKit

class OpponentsHandView : UIView {
    @objc enum Orientation: Int {
        case right
        case down
        case left
    }
    
    private var imageViews: [UIImageView] = []
}
