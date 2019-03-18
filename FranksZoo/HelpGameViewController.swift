import UIKit
import DVITutorialView
import SCLAlertView

class HelpGameViewController : GameViewControllerBase {
    var currentlyAllowedMove: Move?
    var currentTutorialPart = 0
    
    override func viewDidLoad() {
        game = tutorialGame()
        
        game.delegate = self
        
        super.viewDidLoad()
    }
    
    override func initialAnimationDidEnd() {
        super.initialAnimationDidEnd()
        
        nextTutorialPart()
    }
    
    @IBAction override func dealPress() {
        guard game.currentTurn == 0 && !game.ended else { return }
        
        let selectedCards = (handCollectionView.indexPathsForSelectedItems ?? []).map { cards[$0.item] }
        if selectedCards.count > 0 {
            let moveDict = Dictionary(grouping: selectedCards, by: { $0 }).mapValues { $0.count }
            let move = Move(cards: moveDict)
            
            if move != currentlyAllowedMove && game.canMakeMove(move) {
                let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
                alert.addButton("OK", action: {})
                alert.showWarning("", subTitle: "That is a valid move, but for now, please follow the tutorial.")
                return
            }
            
            let player = game.currentTurn
            if (game.makeMove(move)) {
                moveDisplayer.animateMove(move, forPlayer: player, completion: {
                    [weak self] in
                    self?.handCollectionView.reloadData()
                    self?.updateOpponentsHandView()
                    self?.updateMoveDisplayer()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                        [weak self] in
                        self?.nextTutorialPart()
                    })
                })
            }
        }
    }
    
    @IBAction override func passPress() {
        guard game.currentTurn == 0 && !game.ended else { return }
        if .pass != currentlyAllowedMove {
            let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
            alert.addButton("OK", action: {})
            alert.showWarning("", subTitle: "That is a valid move, but for now, please follow the tutorial.")
            return
        }
        game.makeMove(.pass)
        moveDisplayer.animateMove(.pass, forPlayer: 0) {
            [weak self] in
            self?.handCollectionView.reloadData()
            self?.updateOpponentsHandView()
            self?.updateMoveDisplayer()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                [weak self] in
                self?.nextTutorialPart()
            })
        }
    }
    
    func tutorialGame() -> Game {
        let game = Game()
        game.playerHands = [
            Hand(cards: [.fish: 2, .elephant: 1, .mosquito: 1, .fox: 1, .whale: 4, .crocodile: 2, .hedgehog: 2, .mouse: 2]),
            Hand(cards: [.perch: 2, .mouse: 2, .fish: 1, .elephant: 4, .whale: 1, .hedgehog: 1, .lion: 3, .crocodile: 1]),
            Hand(cards: [.hedgehog: 2, .fox: 3, .mosquito: 3, .lion: 2, .bear: 3, .seal: 2]),
            Hand(cards: [.crocodile: 2, .fox: 1, .fish: 2, .joker: 1, .seal: 3, .perch: 3, .bear: 2, .mouse: 1])
        ]
        return game
    }
    
    func nextTutorialPart() {
        let helpParts = [helpPart1, helpPart2, helpPart3, helpPart4,
                         helpPart5, helpPart6, helpPart7, helpPart8]
        helpParts[currentTutorialPart]()
        currentTutorialPart += 1
    }
    
    func runTutorialPart(_ tutorialPart: TutorialPart) {
        animateMoves(tutorialPart.preTutorialMoves) {
            [weak self] in
            guard let `self` = self else { return }
            let tutorialView = DVITutorialView()
            tutorialView.add(to: self.view)
            tutorialView.maskColor = UIColor.black.withAlphaComponent(0.5)
            tutorialView.tutorialStrings = tutorialPart.texts
            tutorialView.tutorialViews = tutorialPart.views(self)
            self.currentlyAllowedMove = tutorialPart.postTutorialAllowedMove
            tutorialView.start {
                [weak self] in
                guard let `self` = self else { return }
                tutorialPart.postTutorialAction?(self)
            }
        }
    }
    
    func animateMoves(_ moves: [Move], completion: @escaping () -> ()) {
        if moves.isEmpty {
            completion()
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            [weak self] in
            let currentPlayer = self?.game.currentTurn
            self?.game.makeMove(moves.first!)
            self?.moveDisplayer.animateMove(moves.first!, forPlayer: currentPlayer ?? 0, completion: {
                [weak self] in
                self?.updateOpponentsHandView()
                self?.updateMoveDisplayer()
                self?.animateMoves(Array(moves.dropFirst()), completion: completion)
            })
        }
    }
    
    let tutorialParts = [
        // part 1
        TutorialPart(texts: [
            "Welcome to Frank's Zoo! This tutorial will tell you how to play this game!\nSwipe left to continue",
            "It is now your turn to deal. You can tap on the cards below to select them.",
            "Then tap on the DEAL button to deal them!",
            "You can only deal one kind of animal each time, and you win when you have used up all your cards.",
            "Let's try dealing 2 fish!"
            ], views: {
                [
                    UIView(),
                    $0.handCollectionView,
                    $0.dealButton,
                    UIView(),
                    $0.handCollectionView
                ]
        }, postTutorialAllowedMove: 2.fish),
        
        // part 2
        TutorialPart(texts:  [
            "Well done!",
            "The top part of each card shows the predators of that animal.",
            "For example, fish have four predators: seals, perches, whales, and crocodiles.",
            "To defeat someone else's cards, you either deal the same number of predators, or one more of the same animal.",
            """
In other words, the next player can only deal one of the following:
3 fish
2 whales
2 seals
2 perches
2 crocodiles
""",
            "Let's see what cards the next player will deal!"
            ], views: {
                let fishCardView = $0.moveDisplayer.subviews.filter { $0 is UIImageView }.first!
                return [
                    $0.moveDisplayer,
                    fishCardView,
                    fishCardView,
                    UIView(),
                    UIView(),
                    $0.opponentHand1,
                ]
        }, postTutorialAction: { $0.nextTutorialPart() }),
        
        // part 3
        TutorialPart(texts:  [
            "The second player dealt 2 perches!",
            "Now it's the third player's turn."
            ], views: {
                [
                    $0.moveDisplayer,
                    $0.opponentHand2
                ]
        }, preTutorialMoves: [2.perches], postTutorialAction: { $0.nextTutorialPart() }),
        
        // part 4
        TutorialPart(texts:  [
            "The third player passed!",
            "He probably has no cards that can defeat 2 perches.",
            "But it is also possible that he does have cards that can defeat 2 perches, but he just doesn't want to deal them yet.",
            "You can always choose to pass even if you have cards that you can deal."
            ], views: {
                [
                    $0.opponentHand2,
                    UIView(),
                    UIView(),
                    $0.passButton
                ]
        }, preTutorialMoves: [.pass], postTutorialAction: { $0.nextTutorialPart() }),
        
        // part 5
        TutorialPart(texts:  [
            "Now it's your turn again!",
            "Only 2 elephants or 3 crocodiles can be used to defeat 2 crocodiles, but you have neither of those sets of cards!",
            "Luckily, mosquito is a special card that can act as elephants.\nSo you can deal 1 elephant and 1 mosquito to defeat the previous move!",
            "You can only use mosquitoes this way if the number of mosquitos is not greater than the number of elephants",
            "In other words, you can't deal 1 elephant + 2 mosquitoes or 2 elephants + 3 mosquitoes.",
            "Try dealing 1 elephant and 1 mosquito!"
            ], views: {
                [
                    UIView(),
                    $0.moveDisplayer,
                    UIView(),
                    UIView(),
                    UIView(),
                    $0.handCollectionView
                ]
        }, preTutorialMoves: [2.crocodiles], postTutorialAllowedMove: 1.elephant + 1.mosquito),
        
        // part 6
        TutorialPart(texts:  [
            "You have no cards that can defeat this move.\nYou can only pass."
            ], views: {
                [
                    $0.passButton
                ]
        }, preTutorialMoves: [2.mice, 2.hedgehogs, .pass], postTutorialAllowedMove: .pass),
        
        // part 7
        TutorialPart(texts:  [
            "Every other player has passed since the player opposite you has dealt 2 hedgehogs. The player opposite you can now deal whatever he likes."
            ], views: {
                [
                    $0.opponentHand2
                ]
        }, preTutorialMoves: [.pass], postTutorialAction: { $0.nextTutorialPart() }),
        
        // part 8
        TutorialPart(texts:  [
            "The player on your right has dealt a joker!",
            "The joker card can act as any animal, but it cannot be dealt on its own.",
            "In other words, if you only have 1 joker left in your hand, you will definitely lose.",
            "Last but not least, there are 5 of each animal, 4 mosquitoes, and 1 joker in each game, a total of 60 cards.",
            "That's the end of the tutorial. You will now be sent back to the main menu, where you can press PLAY to start a new game!"
            ], views: {
                let jokerCardView = $0.moveDisplayer.subviews.filter { $0 is UIImageView }.last!
                return [
                    jokerCardView,
                    UIView(),
                    UIView(),
                    UIView(),
                    UIView()
                ]
        }, preTutorialMoves: [3.mosquitoes, 2.fish + 1.joker], postTutorialAction: { $0.dismiss(animated: true, completion: nil) }),
        ]

}
