import SwiftyUtils

class Game {
    let playerCount = 4
    var playerHands: [Hand]
    var currentTurn = 0 {
        didSet {
            if currentTurn > playerCount - 1 {
                currentTurn = 0
            }
        }
    }
    
    var currentPlayerHand: Hand {
        get { return playerHands[currentTurn] }
        set { playerHands[currentTurn] = newValue }
    }
    
    var lastMove: Move?
    var lastMoveMadeBy: Int?
    
    init() {
        let cardsForEachHand = AllCards.shared.toArray().shuffled().split(intoChunksOf: 60 / playerCount)
        playerHands = cardsForEachHand.map {
            let dict = Dictionary(grouping: $0, by: { $0 }).mapValues { $0.count }
            return Hand(cards: dict)
        }
    }
}
