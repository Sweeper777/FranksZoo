import UIKit

class CardCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
//                imageView.layer.borderWidth = imageView.width * 0.07
//                imageView.layer.borderColor = UIColor.yellow.cgColor
            } else {
//                imageView.layer.borderWidth = 0
            }
        }
    }
}
