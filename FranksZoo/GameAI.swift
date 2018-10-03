class GameAI {
    let game: Game
    let playerIndex: Int
    
    let weightDict: [Card: Int] = [
        .joker: 0,
        .elephant: 2,
        .whale: 8,
        .bear: 14,
        .crocodile: 18,
        .seal: 30,
        .fox: 40,
        .mouse: 46,
        .lion: 48,
        .hedgehog: 62,
        .perch: 70,
        .mosquito: 76,
        .fish: 84
    ]
    
    var myHand: Hand {
        return game.playerHands[playerIndex]
    }
    
    init(game: Game, playerIndex: Int) {
        self.game = game
        self.playerIndex = playerIndex
    }
    
    func allPossibleOpeningMoves(for hand: Hand) -> [Move] {
        var retVal = [Move]()
        for kvp in hand.cards {
            for i in 1...kvp.value {
                retVal.append(contentsOf: Move.allVariants(cardType: kvp.key, count: i))
            }
        }
        return retVal.filter { $0.isLegal }
    }
}
