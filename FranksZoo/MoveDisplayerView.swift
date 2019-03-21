import UIKit

/// A view responsible for displaying and animating moves, as well as showing
/// "It's your turn!"
class MoveDisplayerView: UIView {
    /// The currently displayed move
    var displayedMove: Move? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// The size of the cards displayed
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
        let label = UIImageView(frame: passLabelRect)
        self.addSubview(label)
        label.contentMode = .scaleAspectFit
        label.image = UIImage(named: "pass")
        label.alpha = 0
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
    
    /// Shows an animation of the given player making the given move
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
    
    /// Shows the "It's your turn" message
    func animateItsYourTurn() {
        let height = UIScreen.height / 2
        let width = UIScreen.width / 2
        let startY = -self.y - height
        let midY = self.bounds.midY - height / 2
        let endY = self.bounds.height + self.cardSize.height
        let x = bounds.midX - width / 2
        let imageView = UIImageView(frame: CGRect(x: x, y: startY, width: width, height: height))
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "itsyourturn")
        self.addSubview(imageView)
        UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseOut], animations: {
            imageView.y = midY
        }) { (_) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseIn], animations: {
                    imageView.y = endY
                }, completion: {_ in})
            })
        }
    }
}
