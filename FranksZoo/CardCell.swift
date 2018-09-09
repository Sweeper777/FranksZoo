import UIKit

class CardCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
//                imageView.layer.borderWidth = imageView.width * 0.07
//                imageView.layer.borderColor = UIColor.yellow.cgColor
                self.transform = .identity
            } else {
//                imageView.layer.borderWidth = 0
                self.transform = CGAffineTransform(translationX: 0, y: self.bounds.height * 0.1)
            }
        }
    }
}
