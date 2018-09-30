import UIKit
import SwiftyButton

class ViewController: UIViewController {

    @IBOutlet var opponentHand1: OpponentsHandView!
    @IBOutlet var opponentHand2: OpponentsHandView!
    @IBOutlet var opponentHand3: OpponentsHandView!
    @IBOutlet var handCollectionView: UICollectionView!
    @IBOutlet var bottomStackView: UIStackView!
    @IBOutlet var dealButton: PressableButton!
    @IBOutlet var passButton: PressableButton!
    @IBOutlet var moveDisplayer: MoveDisplayerView!
    
    var initialAnimationPlayed = false
    
    let game = Game()
    
    var cards: [Card] {
        return game.currentPlayerHand.toArray()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        opponentHand1.orientation = .right
        opponentHand2.orientation = .down
        opponentHand3.orientation = .left
        handCollectionView.allowsMultipleSelection = true
        
        opponentHand1.numberOfCards = 0
        opponentHand2.numberOfCards = 0
        opponentHand3.numberOfCards = 0
        bottomStackView.isHidden = true
        
        moveDisplayer.backgroundColor = .clear
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !initialAnimationPlayed {
            startInitialAnimation()
            initialAnimationPlayed = true
        }
        
        self.moveDisplayer.cardSize = CGSize(width: self.opponentHand2.height * 5 / 7 * 1.5, height: self.opponentHand2.height * 1.5)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if traitCollection.horizontalSizeClass == .regular && traitCollection.verticalSizeClass == .regular {
            return .all
        } else {
            return .landscape
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animateAlongsideTransition(in: nil, animation: nil, completion:  {
            [unowned self] _ in
            self.opponentHand1.setNeedsDisplay()
            self.opponentHand2.setNeedsDisplay()
            self.opponentHand3.setNeedsDisplay()
            self.handCollectionView.reloadData()
            self.moveDisplayer.setNeedsDisplay()
            
            self.moveDisplayer.cardSize = CGSize(width: self.opponentHand2.height * 5 / 7, height: self.opponentHand2.height)
        })
    }
    
    func startInitialAnimation() {
        Timer.every(0.1) { [weak self] (timer) in
            self?.opponentHand1.numberOfCards += 1
            self?.opponentHand2.numberOfCards += 1
            self?.opponentHand3.numberOfCards += 1
            if self?.opponentHand1.numberOfCards == 15 {
                timer.invalidate()
                self?.bottomStackView.isHidden = false
            }
        }.start()
    }
    
    @IBAction func dealPress() {
        let selectedCards = (handCollectionView.indexPathsForSelectedItems ?? []).map { cards[$0.item] }
        if selectedCards.count > 0 {
            let moveDict = Dictionary(grouping: selectedCards, by: { $0 }).mapValues { $0.count }
            let move = Move(cards: moveDict)
            if (game.makeMove(move)) {
                moveDisplayer.animateMove(move, completion: {
                    self.handCollectionView.reloadData()
                })
            }
        }
    }
    func updateOpponentsHandView() {
//        func nextPlayer(after index: Int) -> Int {
//            return index + 1 < game.playerCount ? index + 1 : 0
//        }
//
//        var playerIndex = nextPlayer(after: game.currentTurn)
//        opponentHand1.numberOfCards = game.playerHands[playerIndex].toArray().count
//        playerIndex = nextPlayer(after: playerIndex)
//        opponentHand2.numberOfCards = game.playerHands[playerIndex].toArray().count
//        playerIndex = nextPlayer(after: playerIndex)
//        opponentHand3.numberOfCards = game.playerHands[playerIndex].toArray().count
    }
}

extension ViewController : UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CardCell
        if collectionView.indexPathsForSelectedItems?.contains(indexPath) ?? false {
            cell.isSelected = true
        } else {
            cell.isSelected = false
        }
        cell.imageView.image = UIImage(named: imageDict[cards[indexPath.item]]!)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.height / 1.15
        let width = height * 5 / 7
        return CGSize(width: width, height: height)
    }
}
