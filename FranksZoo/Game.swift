import SwiftyUtils

class Game : Codable {
    enum CodingKeys : CodingKey {
        case playerHands
        case currentTurn
        case ended
        case lastMove
        case lastMoveMadeBy
        case totalPlayedCardCount
    }
    
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
    
    weak var delegate: GameDelegate?
    
    init() {
        let cardsForEachHand = AllCards.shared.toArray().shuffled().split(intoChunksOf: 60 / playerCount)
        playerHands = cardsForEachHand.map {
            let dict = Dictionary(grouping: $0, by: { $0 }).mapValues { $0.count }
            return Hand(cards: dict)
        }
    }
    
    init(copyOf game: Game) {
        playerHands = game.playerHands
        currentTurn = game.currentTurn
        ended = game.ended
        lastMove = game.lastMove
        lastMoveMadeBy = game.lastMoveMadeBy
        totalPlayedCardCount = game.totalPlayedCardCount
    }
    
    private func nextPlayer() {
        repeat {
            currentTurn += 1
            
            if currentTurn == lastMoveMadeBy {
                lastMove = nil
            }
        } while currentPlayerHand.isEmpty
        delegate?.playerTurnDidChange(to: currentTurn, game: self)
    }
    
    @discardableResult
    func makeMove(_ move: Move) -> Bool {
        if ended {
            return false
        }
        
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
            totalPlayedCardCount += move.cardCount
            if (playerHands.filter { !$0.isEmpty }).count <= 1 {
                ended = true
                delegate?.playerDidWin(game: self, player: currentTurn, place: playerCount - 1)
                return true
            } else if currentPlayerHand.isEmpty {
                delegate?.playerDidWin(game: self, player: currentTurn, place: playerHands.filter { $0.isEmpty }.count)
            }
            nextPlayer()
            return true
        } else {
            return false
        }
    }
    
}
