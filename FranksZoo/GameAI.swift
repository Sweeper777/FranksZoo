/// A protocol that all implementations of GameAI conform to
protocol GameAI {
    /// Returns the next move that should be made in the `game`
    func getNextMove() -> Move
    
    /// The game statte that the AI is given
    var game: Game { get }
    
    /// The index of the player that the AI is acting as
    var playerIndex: Int { get }
}

extension GameAI {
    /// Returns all the opening moves that a hand can make.
    func allPossibleOpeningMoves(for hand: Hand) -> [Move] {
        var retVal = [Move]()
        for kvp in hand.cards {
            for i in 1...kvp.value {
                retVal.append(contentsOf: Move.allVariants(cardType: kvp.key, count: i).filter(hand.canMakeMove(_:)))
            }
        }
        return retVal.filter { $0.isLegal }
    }
    
    /// Returns all the moves that a hand can make in the current `game` state.
    func allPossibleMoves(for hand: Hand) -> [Move] {
        if let lastMove = game.lastMove {
            // if there is a last move, return its defeatable moves that the hand
            // can make
            return lastMove.defeatableMoves.filter(hand.canMakeMove(_:))
                .sorted(by: { (x, y) -> Bool in
                    return x.cardCount > y.cardCount
                })
        } else {
            // otherwise, return the opening moves a hand can make
            return allPossibleOpeningMoves(for: hand)
                .sorted(by: { (x, y) -> Bool in
                    return x.cardCount > y.cardCount
                })
        }
    }
    
    /// The hand of the player that the AI is representing
    var myHand: Hand {
        return game.playerHands[playerIndex]
    }
}

/// An implementation of AI that uses heuristics to determine the next move
class HeuristicAI : GameAI {
    let game: Game
    let playerIndex: Int
    
    /// The weight for each card type
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
    
    init(game: Game, playerIndex: Int) {
        self.game = game
        self.playerIndex = playerIndex
    }
    
    /// Returns whether after making a given move, the player represented by this
    /// AI uses up all his cards.
    func isWinningMove(_ move: Move) -> Bool {
        return isWinningMove(move, forHand: myHand)
    }
    
    /// Returns whether after making a given, the player with the given hand uses
    /// up all his cards.
    func isWinningMove(_ move: Move, forHand hand: Hand) -> Bool {
        var handCopy = hand
        handCopy.makeMove(move)
        return handCopy.isEmpty
    }
    
    /// Returns whether after making a given move, the player represented by this
    /// AI will lose certainly
    func isLosingMove(_ move: Move) -> Bool {
        var hand = myHand
        hand.makeMove(move)
        return hand.cards == [.joker: 1]
    }
    
    /// Returns the sum of the hands of all players, except the player
    /// represented by this AI, as a single `Hand`.
    func opponentHandSum() -> Hand {
        let opponents = (0..<game.playerHands.count).filter { $0 != playerIndex }
                        .map { game.playerHands[$0] }
        let opponentHandSum = opponents.reduce(into: [:]) { (dict, hand) in
            dict.merge(hand.cards, uniquingKeysWith: +)
        }
        return Hand(cards: opponentHandSum)
    }
    
    /// Returns whether a given move is undefeatable given a set of all
    /// available cards.
    func isUndefeatableMove(_ move: Move, allAvailableCards: Hand) -> Bool {
        let defeatableMoves = move.defeatableMoves
        return !defeatableMoves.contains(where: allAvailableCards.canMakeMove(_:))
    }
    
    /// Returns whether a move is the start of a winning sequence.
    ///
    /// A winning sequence is defined recursively as follows :
    /// - a winning sequence is a winning move, or
    /// - a winning sequence is an undefeatable move followed by a winning sequence
    func isStartOfWinningSequence(_ move: Move) -> Bool {
        let allAvailableCards = opponentHandSum()
        if isUndefeatableMove(move, allAvailableCards: allAvailableCards) {
            var handCopy = myHand
            handCopy.makeMove(move)
            return isStartOfWinningSequenceImpl(handCopy, allAvailableCards: allAvailableCards)
        }
        return false
        
    }
    
    private func isStartOfWinningSequenceImpl(_ hand: Hand, allAvailableCards: Hand) -> Bool {
        let possibleOpeningMoves = allPossibleOpeningMoves(for: hand).sorted(by: { $0.cardCount > $1.cardCount })
        for move in possibleOpeningMoves { // for each move that this hand can make
            if isWinningMove(move, forHand: hand) { // if it is a winning move, it is a winning sequence
                return true
            }
            
            if !isUndefeatableMove(move, allAvailableCards: allAvailableCards) {
                continue // if it is not undefeatable, we check the next move
            }
            
            // if it is undefeatable, we simulate making the move
            var handCopy = hand
            handCopy.makeMove(move)
            // return whether the rest is a winning sequence
            if isStartOfWinningSequenceImpl(handCopy, allAvailableCards: allAvailableCards) {
                return true
            }
        }
        return false
    }
    
    /// Returns the weight of a move, taking into account of whether the moves
    /// uses up all the cards of the same type
    func weight(ofMove move: Move) -> Double {
        let divider = move.numberOf(move.mainCardType!) == myHand.numberOf(move.mainCardType!) ? 1.0 : 4.0
        return Double(weightDict[move.mainCardType!]!) / divider
    }
    
    /// Returns the best move for the current `game` state based on weights
    func findMoveByWeights(moves: [Move]) -> Move {
        // these bounds are empirically tuned
        let lowerBound = 15 - Double(game.totalPlayedCardCount * game.playerCount) / 10.0
        let upperBound = max(lowerBound, 30 - Double(game.totalPlayedCardCount * game.playerCount) / 5)
        
        // Remove those moves that have weights less than the lower bound.
        // We want to deal these cards late in the game.
        let capped = moves.map { ($0, weight(ofMove: $0)) }.filter { $0.1 > lowerBound }.sorted { $0.1 > $1.1 }
        
        // The moves which have weights greater than the upper bound are preferred
        // and we should make the preferred move that has the hightest weight.
        // If there are no preferred moves, we choose a random move with a weight
        // between the bounds and make it.
        // If there are no moves between the bounds, we pass.
        let preferred = capped.filter { $0.1 > upperBound }
        let candidates = capped.filter { $0.1 <= upperBound }
        return preferred.first?.0 ?? candidates.randomElement()?.0 ?? .pass
    }
    
    /// Returns the next move that the AI will make in the current `game` state
    func getNextMove() -> Move {
        var possibleMoves = allPossibleMoves(for: myHand)
        if let winningMove = possibleMoves.first(where: isWinningMove) {
            return winningMove
        }
        possibleMoves.removeAll(where: isLosingMove)
        
        if let startOfWinningSequence = possibleMoves.first(where: isStartOfWinningSequence) {
            
            return startOfWinningSequence
        }
        
        return findMoveByWeights(moves: possibleMoves)
    }
}

/// A implementation of an AI that makes random moves.
class RandomAI : GameAI {
    let game: Game
    let playerIndex: Int
    
    func getNextMove() -> Move {
        let moves = allPossibleMoves(for: myHand)
        return moves.randomElement() ?? .pass
    }
    
    init(game: Game, playerIndex: Int) {
        self.game = game
        self.playerIndex = playerIndex
    }
}
