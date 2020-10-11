import UIKit

class CardCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                self.transform = .identity
            } else {
                self.transform = CGAffineTransform(translationX: 0, y: self.bounds.height * 0.1)
            }
        }
    }
}
