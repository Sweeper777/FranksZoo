protocol GameAI {
    func getNextMove() -> Move
    var game: Game { get }
    var playerIndex: Int { get }
}

extension GameAI {
    func allPossibleOpeningMoves(for hand: Hand) -> [Move] {
        var retVal = [Move]()
        for kvp in hand.cards {
            for i in 1...kvp.value {
                retVal.append(contentsOf: Move.allVariants(cardType: kvp.key, count: i).filter(hand.canMakeMove(_:)))
            }
        }
        return retVal.filter { $0.isLegal }
    }
    
    func allPossibleMoves(for hand: Hand) -> [Move] {
        if let lastMove = game.lastMove {
            return lastMove.defeatableMoves.filter(hand.canMakeMove(_:))
                .sorted(by: { (x, y) -> Bool in
                    return x.cardCount > y.cardCount
                })
        } else {
            return allPossibleOpeningMoves(for: hand)
                .sorted(by: { (x, y) -> Bool in
                    return x.cardCount > y.cardCount
                })
        }
    }
    
    var myHand: Hand {
        return game.playerHands[playerIndex]
    }
}

class HeuristicAI : GameAI {
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
    
    init(game: Game, playerIndex: Int) {
        self.game = game
        self.playerIndex = playerIndex
    }
    
    }
    
    }
    
    func isLosingMove(_ move: Move) -> Bool {
        var hand = myHand
        hand.makeMove(move)
        return hand.cards == [.joker: 1]
    }
    
    func opponentHandSum() -> Hand {
        let opponents = (0..<game.playerHands.count).filter { $0 != playerIndex }
                        .map { game.playerHands[$0] }
        let opponentHandSum = opponents.reduce(into: [:]) { (dict, hand) in
            dict.merge(hand.cards, uniquingKeysWith: +)
        }
        return Hand(cards: opponentHandSum)
    }
    
    func isUndefeatableMove(_ move: Move, allAvailableCards: Hand) -> Bool {
        let defeatableMoves = move.defeatableMoves
        return defeatableMoves.testAll(test: allAvailableCards.canMakeMove(_:))
    }
    
    func isStartOfWinningSequence(_ move: Move) -> Bool {
        let allAvailableCards = opponentHandSum()
        if isUndefeatableMove(move, allAvailableCards: allAvailableCards) {
            var handCopy = myHand
            handCopy.makeMove(move)
            return isStartOfWinningSequenceImpl(handCopy, allAvailableCards: allAvailableCards, depth: 3)
        }
        return false
        
    }
    
    private func isStartOfWinningSequenceImpl(_ hand: Hand, allAvailableCards: Hand, depth: Int) -> Bool {
        if depth == 0 {
            return false
        }
        
        let possibleOpeningMoves = allPossibleOpeningMoves(for: hand)
        for move in possibleOpeningMoves {
            if isWinningMove(move) {
                return true
            }
            
            if !isUndefeatableMove(move, allAvailableCards: allAvailableCards) {
                continue
            }
            
            var handCopy = hand
            handCopy.makeMove(move)
            if isStartOfWinningSequenceImpl(handCopy, allAvailableCards: allAvailableCards, depth: depth - 1) {
                return true
            }
        }
        return false
    }
    
    func weight(ofMove move: Move) -> Double {
        let divider = move.numberOf(move.mainCardType!) == myHand.numberOf(move.mainCardType!) ? 1.0 : 4.0
        return Double(weightDict[move.mainCardType!]!) / divider
    }
    
    func findMoveByWeights(moves: [Move]) -> Move {
        let lowerBound = 15 - Double(game.totalPlayedCardCount * game.playerCount) / 10.0
        let upperBound = 30 - Double(game.totalPlayedCardCount * game.playerCount) / 5
        
        let capped = moves.map { ($0, weight(ofMove: $0)) }.filter { $0.1 > lowerBound }.sorted { $0.1 > $1.1 }
        let preferred = capped.filter { $0.1 > upperBound }
        let candidates = capped.filter { $0.1 <= upperBound }
        return preferred.first?.0 ?? candidates.randomElement()?.0 ?? .pass
    }
    
    func getNextMove() -> Move {
        var possibleMoves = allPossibleMoves(for: myHand)
        if possibleMoves.count == 1 {
            return possibleMoves.first!
        }
        
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
