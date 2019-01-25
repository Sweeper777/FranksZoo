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
    
    private func animateMoveHorizontally(move: Move, startX: CGFloat, completion: @escaping () -> Void) {
        let cards = move.toArray()
        var imageViews = [UIImageView]()
        
        let xCoordinates = calculateCardXs(cards: cards)
        for (x, card) in zip(xCoordinates, cards) {
            let image = UIImage(named: imageDict[card]!)
            let y = (self.height - self.cardSize.height) / 2
            let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: x - startX, y: y), size: cardSize))
            imageView.image = image
            imageViews.append(imageView)
            self.addSubview(imageView)
        }
        
        UIView.animate(withDuration: 0.5, animations: {
            for imageView in imageViews {
                imageView.x += startX
            }
        }, completion: {
            _ in
            self.displayedMove = move
            completion()
        })
    }
    
    private func animateMoveForPlayer0(move: Move, completion: @escaping () -> Void) {
        animateMoveVertically(move: move, startY: bounds.height + cardSize.height, completion: completion)
    }
    
    private func animateMoveForPlayer1(move: Move, completion: @escaping () -> Void) {
        animateMoveHorizontally(move: move, startX: bounds.width, completion: completion)
    }
    
    private func animateMoveForPlayer2(move: Move, completion: @escaping () -> Void) {
        animateMoveVertically(move: move, startY: -cardSize.height, completion: completion)
    }
    
    private func animateMoveForPlayer3(move: Move, completion: @escaping () -> Void) {
        animateMoveHorizontally(move: move, startX: -bounds.width, completion: completion)
    }
    
    private func animatePass(forPlayer player: Int, completion: @escaping () -> Void) {
        let passLabelRect: CGRect
        switch player {
        case 0:
            let y = bounds.height - cardSize.width * 0.7
            let x = bounds.midX - cardSize.height / 2
            passLabelRect = CGRect(x: x, y: y, width: cardSize.height, height: cardSize.width)
        case 1:
            let x = 0.f
            let y = bounds.midY - cardSize.width / 2
            passLabelRect = CGRect(x: x, y: y, width: cardSize.height, height: cardSize.width)
        case 2:
            let y = -cardSize.width * 0.3
            let x = bounds.midX - cardSize.height / 2
            passLabelRect = CGRect(x: x, y: y, width: cardSize.height, height: cardSize.width)
        case 3:
            let x = bounds.width - cardSize.height
            let y = bounds.midY - cardSize.width / 2
            passLabelRect = CGRect(x: x, y: y, width: cardSize.height, height: cardSize.width)
        default:
            passLabelRect = .zero
        }
        let label = UILabel(frame: passLabelRect)
        self.addSubview(label)
        label.text = "PASS"
        label.font = label.font.withSize(fontSizeThatFits(size: passLabelRect.size, text: label.text! as NSString, font: label.font) * 0.7)
        label.alpha = 0
        label.textColor = .white
        UIView.animate(withDuration: 0.5, animations: {
            label.alpha = 1
        }) { (_) in
            UIView.animate(withDuration: 0.5, animations: {
                label.alpha = 0
            }, completion: { (_) in
                label.removeFromSuperview()
                completion()
            })
        }
    }
    
    func animateMove(_ move: Move, forPlayer player: Int, completion: @escaping () -> Void) {
        guard move != .pass else {
            animatePass(forPlayer: player, completion: completion)
            return
        }
        
        switch player {
        case 0:
            animateMoveForPlayer0(move: move, completion: completion)
        case 1:
            animateMoveForPlayer1(move: move, completion: completion)
        case 2:
            animateMoveForPlayer2(move: move, completion: completion)
        case 3:
            animateMoveForPlayer3(move: move, completion: completion)
        default:
            fatalError("Invalid Player!")
        }
    }
}
