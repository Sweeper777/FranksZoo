import SwiftyUtils

/// An object that represents the state of a game of Frank's Zoo
class Game : Codable {
    enum CodingKeys : CodingKey {
        case playerHands
        case currentTurn
        case ended
        case lastMove
        case lastMoveMadeBy
        case totalPlayedCardCount
    }
    
    /// The number of players in the game iniitally
    let playerCount = 4
    
    /// The hands of each of the player
    var playerHands: [Hand]
    
    /// The player index of the current player
    var currentTurn = 0 {
        didSet {
            if currentTurn > playerCount - 1 {
                currentTurn = 0
            }
        }
    }
    
    /// Whether the game has ended i.e. only one player left
    var ended = false
    
    /// Returns the hand of current player
    var currentPlayerHand: Hand {
        get { return playerHands[currentTurn] }
        set { playerHands[currentTurn] = newValue }
    }
    
    /// The last non-pass move made by a player. This property is nil when the
    /// current player is eligible for an opening move
    var lastMove: Move?
    
    /// The player index of the player who made the move stored in `lastMove`
    var lastMoveMadeBy: Int?
    
    /// The total number of cards dealt in this game
    var totalPlayedCardCount = 0
    
    weak var delegate: GameDelegate?
    
    init() {
        let cardsForEachHand = AllCards.shared.toArray().shuffled().split(intoChunksOf: 60 / playerCount)
        playerHands = cardsForEachHand.map {
            let dict = Dictionary(grouping: $0, by: { $0 }).mapValues { $0.count }
            return Hand(cards: dict)
        }
    }
    
    /// Creates a shallow copy of a Game object. The `delegate` is not copied
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
    
    /// Cause the current player to make a move if possible.
    /// Otherwise this has no effect.
    /// - Returns: Whether the move was successfully made
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
    
    /// Returns whether a move can be made by the current player.
    func canMakeMove(_ move: Move) -> Bool {
        if ended {
            return false
        }
        
        guard move.isLegal else { return false }
        
        var isDefeating = true
        if let lastMove = self.lastMove {
            isDefeating = move.canDefeat(lastMove)
        }
        
        guard isDefeating else { return false }
        
        return currentPlayerHand.canMakeMove(move)
    }
}
