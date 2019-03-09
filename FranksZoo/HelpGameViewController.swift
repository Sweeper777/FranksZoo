import UIKit
import DVITutorialView
import SCLAlertView

class HelpGameViewController : GameViewControllerBase {
    var currentlyAllowedMove: Move?
    var currentHelpPart = 0
    
    override func viewDidLoad() {
        game = helpGame()
        
        game.delegate = self
        
        super.viewDidLoad()
    }
    
    override func initialAnimationDidEnd() {
        super.initialAnimationDidEnd()
        
        nextHelpPart()
    }
    
    @IBAction override func dealPress() {
        guard game.currentTurn == 0 && !game.ended else { return }
        
        let selectedCards = (handCollectionView.indexPathsForSelectedItems ?? []).map { cards[$0.item] }
        if selectedCards.count > 0 {
            let moveDict = Dictionary(grouping: selectedCards, by: { $0 }).mapValues { $0.count }
            let move = Move(cards: moveDict)
            
            
            let player = game.currentTurn
            if (game.makeMove(move)) {
                moveDisplayer.animateMove(move, forPlayer: player, completion: {
                    [weak self] in
                    self?.handCollectionView.reloadData()
                    self?.updateOpponentsHandView()
                    self?.updateMoveDisplayer()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                        [weak self] in
                        self?.nextHelpPart()
                    })
                })
            }
        }
    }
    
    @IBAction override func passPress() {
        guard game.currentTurn == 0 && !game.ended else { return }
        game.makeMove(.pass)
        moveDisplayer.animateMove(.pass, forPlayer: 0) {
            [weak self] in
            self?.handCollectionView.reloadData()
            self?.updateOpponentsHandView()
            self?.updateMoveDisplayer()
        }
    }
    
    func helpGame() -> Game {
        let game = Game()
        game.playerHands = [
            Hand(cards: [.fish: 2, .elephant: 1, .mosquito: 1, .fox: 1, .whale: 3, .crocodile: 3, .hedgehog: 2, .mouse: 2]),
            Hand(cards: [.perch: 2, .mouse: 2, .fish: 1, .elephant: 4, .whale: 2, .hedgehog: 1, .lion: 3]),
            Hand(cards: [.hedgehog: 2, .fox: 3, .mosquito: 3, .lion: 2, .bear: 3, .seal: 2]),
            Hand(cards: [.crocodile: 2, .fox: 1, .fish: 2, .joker: 1, .seal: 3, .perch: 3, .bear: 2, .mouse: 1])
        ]
        return game
    }
    func helpPart1() {
        let tutorialView = DVITutorialView()
        tutorialView.add(to: self.view)
        tutorialView.maskColor = UIColor.black.withAlphaComponent(0.5)
        tutorialView.tutorialStrings = [
            "Welcome to Frank's Zoo! This tutorial will tell you how to play this game!\nSwipe left to continue",
            "It is now your turn to deal. You can tap on the cards below to select them",
            "Then tap on the DEAL button to deal them!",
            "You can only deal one kind of animal each time. Let's try dealing 2 fish!"
        ]
        tutorialView.tutorialViews = [
            UIView(),
            self.handCollectionView,
            self.dealButton,
            self.handCollectionView
        ]
        currentlyAllowedMove = 2.fish
        tutorialView.start()
    }
    
    func helpPart2() {
        let tutorialView = DVITutorialView()
        tutorialView.add(to: self.view)
        tutorialView.maskColor = UIColor.black.withAlphaComponent(0.5)
        tutorialView.tutorialStrings = [
            "Well done!",
            "The top part of each card shows the predators of that animal.",
            "For example, fish have four predators: seals, perches, whales, and crocodiles.",
            "To defeat someone else's cards, you either deal the same number of predators, or one more of the same animal",
            """
In other words, the next player can only deal one of the following:
3 fish
2 whales
2 seals
2 perches
2 crocodiles
""",
            "Let's see what cards the next player will deal!"
        ]
        let fishCardView = self.moveDisplayer.subviews.filter { $0 is UIImageView }.first!
        tutorialView.tutorialViews = [
            self.moveDisplayer,
            fishCardView,
            fishCardView,
            UIView(),
            UIView(),
            self.opponentHand1,
        ]
        currentlyAllowedMove = nil
        tutorialView.start {
            [weak self] in
            self?.game.makeMove(2.perches)
            self?.moveDisplayer.animateMove(2.perches, forPlayer: 1, completion: {
                [weak self] in
                self?.updateOpponentsHandView()
                self?.updateMoveDisplayer()
                self?.nextHelpPart()
            })
        }
    }
}
