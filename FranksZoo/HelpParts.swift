import UIKit
import DVITutorialView

extension HelpGameViewController {
    func helpPart1() {
        let tutorialView = DVITutorialView()
        tutorialView.add(to: self.view)
        tutorialView.maskColor = UIColor.black.withAlphaComponent(0.5)
        tutorialView.tutorialStrings = [
            "Welcome to Frank's Zoo! This tutorial will tell you how to play this game!\nSwipe left to continue",
            "It is now your turn to deal. You can tap on the cards below to select them.",
            "Then tap on the DEAL button to deal them!",
            "You can only deal one kind of animal each time, and you win when you have used up all your cards.",
            "Let's try dealing 2 fish!"
        ]
        tutorialView.tutorialViews = [
            UIView(),
            self.handCollectionView,
            self.dealButton,
            UIView(),
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
    
    func helpPart3() {
        let tutorialView = DVITutorialView()
        tutorialView.add(to: self.view)
        tutorialView.maskColor = UIColor.black.withAlphaComponent(0.5)
        tutorialView.tutorialStrings = [
            "The second player dealt 2 perches!",
            "Now it's the third player's turn."
        ]
        tutorialView.tutorialViews = [
            self.moveDisplayer,
            self.opponentHand2
        ]
        tutorialView.start {
            [weak self] in
            self?.game.makeMove(.pass)
            self?.moveDisplayer.animateMove(.pass, forPlayer: 2, completion: {
                [weak self] in
                self?.updateOpponentsHandView()
                self?.updateMoveDisplayer()
                self?.nextHelpPart()
            })
        }
    }
    
    func helpPart4() {
        let tutorialView = DVITutorialView()
        tutorialView.add(to: self.view)
        tutorialView.maskColor = UIColor.black.withAlphaComponent(0.5)
        tutorialView.tutorialStrings = [
            "The third player passed!",
            "He probably has no cards that can defeat 2 perches.",
            "But it is also possible that he does have cards that can defeat 2 perches, but he just doesn't want to deal them yet.",
            "You can always choose to pass even if you have cards that you can deal."
        ]
        tutorialView.tutorialViews = [
            opponentHand2,
            UIView(),
            UIView(),
            passButton
        ]
        tutorialView.start {
            [weak self] in
            self?.game.makeMove(2.crocodiles)
            self?.moveDisplayer.animateMove(2.crocodiles, forPlayer: 3, completion: {
                [weak self] in
                self?.updateOpponentsHandView()
                self?.updateMoveDisplayer()
                self?.nextHelpPart()
            })
        }
    }
    
}
