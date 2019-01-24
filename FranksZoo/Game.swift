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
    
    var ended = false
    
    var currentPlayerHand: Hand {
        get { return playerHands[currentTurn] }
        set { playerHands[currentTurn] = newValue }
    }
    
    var lastMove: Move?
    var lastMoveMadeBy: Int?
    
    var totalPlayedCardCount = 0
    
    init() {
        let cardsForEachHand = AllCards.shared.toArray().shuffled().split(intoChunksOf: 60 / playerCount)
        playerHands = cardsForEachHand.map {
            let dict = Dictionary(grouping: $0, by: { $0 }).mapValues { $0.count }
            return Hand(cards: dict)
        }
    }
    
    private func nextPlayer() {
        repeat {
            currentTurn += 1
            
            if currentTurn == lastMoveMadeBy {
                lastMove = nil
            }
        } while currentPlayerHand.isEmpty
    }
    
    @discardableResult
    func makeMove(_ move: Move) -> Bool {
        guard move.isLegal else { return false }
        
        if move == .pass {
            nextPlayer()
            return true
        }
        
        var isDefeating = true
        if let lastMove = self.lastMove {
            isDefeating = move.canDefeat(lastMove)
        }
        
        guard isDefeating else { return false }
        
        let success = currentPlayerHand.makeMove(move)
        if success {
            lastMove = move
            lastMoveMadeBy = currentTurn
            nextPlayer()
            totalPlayedCardCount += move.cardCount
            return true
        } else {
            return false
        }
    }
    
}
