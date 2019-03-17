import UIKit
import DVITutorialView

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
    
    func helpPart4() {
        animateMoves([.pass]) {
            [weak self] in
            guard let `self` = self else { return }
            
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
                self.opponentHand2,
                UIView(),
                UIView(),
                self.passButton
            ]
            tutorialView.start {
                [weak self] in
                self?.nextTutorialPart()
            }
        }
        
    }
    
    
    func helpPart5() {
        animateMoves([2.crocodiles]) {
            [weak self] in
            guard let `self` = self else { return }
            let tutorialView = DVITutorialView()
            tutorialView.add(to: self.view)
            tutorialView.maskColor = UIColor.black.withAlphaComponent(0.5)
            tutorialView.tutorialStrings = [
                "Now it's your turn again!",
                "Only 2 elephants or 3 crocodiles can be used to defeat 2 crocodiles, but you have neither of those sets of cards!",
                "Luckily, mosquito is a special card that can act as elephants.\nSo you can deal 1 elephant and 1 mosquito to defeat the previous move!",
                "You can only use mosquitoes this way if the number of mosquitos is not greater than the number of elephants",
                "In other words, you can't deal 1 elephant + 2 mosquitoes or 2 elephants + 3 mosquitoes.",
                "Try dealing 1 elephant and 1 mosquito!"
            ]
            tutorialView.tutorialViews = [
                UIView(),
                self.moveDisplayer,
                UIView(),
                UIView(),
                UIView(),
                self.handCollectionView
            ]
            self.currentlyAllowedMove = 1.elephant + 1.mosquito
            tutorialView.start()
        }
    }
    
    func helpPart6() {
        animateMoves([2.mice, 2.hedgehogs, .pass]) {
            [weak self] in
            guard let `self` = self else { return }
            let tutorialView = DVITutorialView()
            tutorialView.add(to: self.view)
            tutorialView.maskColor = UIColor.black.withAlphaComponent(0.5)
            tutorialView.tutorialStrings = [
                "You have no cards that can defeat this move.\nYou can only pass."
            ]
            tutorialView.tutorialViews = [
                self.passButton
            ]
            self.currentlyAllowedMove = .pass
            tutorialView.start()
        }
    }
    
    func helpPart7() {
        animateMoves([.pass]) {
            [weak self] in
            guard let `self` = self else { return }
            let tutorialView = DVITutorialView()
            tutorialView.add(to: self.view)
            tutorialView.maskColor = UIColor.black.withAlphaComponent(0.5)
            tutorialView.tutorialStrings = [
                "Every other player has passed since the player opposite you has dealt 2 hedgehogs. The player opposite you can now deal whatever he likes."
            ]
            tutorialView.tutorialViews = [
                self.opponentHand2
            ]
            tutorialView.start {
                [weak self] in
                self?.nextTutorialPart()
            }
        }
    }
    
    func helpPart8() {
        animateMoves([3.mosquitoes, 2.fish + 1.joker]) {
            [weak self] in
            guard let `self` = self else { return }
            let tutorialView = DVITutorialView()
            tutorialView.add(to: self.view)
            tutorialView.maskColor = UIColor.black.withAlphaComponent(0.5)
            let jokerCardView = self.moveDisplayer.subviews.filter { $0 is UIImageView }.last!
            tutorialView.tutorialStrings = [
                "The player on your right has dealt a joker!",
                "The joker card can act as any animal, but it cannot be dealt on its own.",
                "In other words, if you only have 1 joker left in your hand, you will definitely lose.",
                "Last but not least, there are 5 of each animal, 4 mosquitoes, and 1 joker in each game, a total of 60 cards.",
                "That's the end of the tutorial. You will now be sent back to the main menu, where you can press PLAY to start a new game!"
            ]
            tutorialView.tutorialViews = [
                jokerCardView,
                jokerCardView,
                jokerCardView,
                UIView(),
                UIView()
            ]
            tutorialView.start {
                [weak self] in
                self?.dismiss(animated: true, completion: nil)
            }
        }
    }
}
]
