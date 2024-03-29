/// An object that represents a Move in a game of Frank's Zoo
struct Move : Cards, Equatable, Codable {
    /// The cards that this move consists of
    let cards: [Card : Int]
    
    /// A move representing the move of not dealing any cards
    static let pass = Move()
    
    /// The total number of cards in this move
    let cardCount: Int
    
    init(cards: [Card: Int]) {
        self.cards = cards.filter { $0.value > 0 }
        cardCount = self.cards.values.reduce(0, +)
    }
    
    init() {
        self.init(cards: [:])
    }
    
    static func ==(lhs: Move, rhs: Move) -> Bool {
        return lhs.cards == rhs.cards
    }
    
    /// Returns whether a move is a valid opening move
    var isLegal: Bool {
        // pass is always legal
        if self == .pass {
            return true
        }
        var cardCopy = cards
        
        // only joker is illegal
        if cardCopy.keys.count == 1 && cardCopy.keys.contains(.joker) {
            return false
        }
        
        let jokerCount = cardCopy[.joker] ?? 0
        cardCopy[.joker] = nil
        if cardCopy.keys.count == 2 &&
            cardCopy.keys.contains(.elephant) &&
            cardCopy.keys.contains(.mosquito) {
            let elephantCount = cardCopy[.elephant]!
            let mosquitoCount = cardCopy[.mosquito]!
            
            // mosquito and elephant mechanic
            return elephantCount - mosquitoCount + jokerCount >= 0
        }
        
        // otherwise, legal if only one type
        return cardCopy.keys.count == 1
    }
    
    /// The main card type of the move
    var mainCardType: Card? {
        if !isLegal { return nil }
        
        // elephant and mosquito mechanic
        if cards.keys.contains(.elephant) &&
            cards.keys.contains(.mosquito) {
            return .elephant
        }
        var cardsCopy = cards
        
        // remove the joker (if any)
        cardsCopy[.joker] = nil
        
        // then the only type of card left (if any) is the main card type
        return cardsCopy.keys.first
    }
    
    /// A set of moves that can defeat this move
    var defeatableMoves: [Move] {
        // this does not apply to passing
        guard self != .pass else { return [] }
        guard let mainCardType = mainCardType else { return [] }
        let cardCount = cards.values.reduce(0, +)
        var moves: [Move] = []
        
        // one more of the same animal
        moves.append(contentsOf: Move.allVariants(cardType: mainCardType, count: cardCount + 1))
        
        // same number of predators
        for predatorType in mainCardType.predators {
            moves.append(contentsOf: Move.allVariants(cardType: predatorType, count: cardCount))
        }
        return moves
    }
    
    /// Returns whether this move can defeat another move
    func canDefeat(_ move: Move) -> Bool{
        // both moves must be legal
        guard self.isLegal && move.isLegal else {
            return false
        }
        
        // passing can't defeat anything
        guard self != .pass else {
            return true
        }
        
        // passing can't be defeated
        guard move != .pass else {
            return false
        }
        
        guard let selfMainCardType = self.mainCardType else {
            fatalError()
        }
        
        let selfCardCount = cards.values.reduce(0, +)
        
        guard let moveMainCardType = move.mainCardType else {
            fatalError()
        }
        
        let moveCardCount = move.cards.values.reduce(0, +)
        
        return (selfMainCardType == moveMainCardType && selfCardCount - moveCardCount == 1) || // one more of the same type
            (moveMainCardType.predators.contains(selfMainCardType) && selfCardCount == moveCardCount) // same number of predators
    }
    
    /// Returns all the different sets of cards that can be used to represent a
    /// certain number of a certain animal.
    /// i.e. 2 fish can be represented by 2 fish, or 1 fish + 1 joker
    static func allVariants(cardType: Card, count: Int) -> [Move] {
        if count == 1 {
            return [[cardType: 1]]
        }
        if cardType == .elephant {
            switch count {
            case 2: return [
                2.elephants,
                1.elephant + 1.joker,
                1.elephant + 1.mosquito,
                ]
            case 3: return [
                3.elephants,
                2.elephants + 1.joker,
                1.elephant + 1.joker + 1.mosquito,
                2.elephants + 1.mosquito,
                ]
            case 4: return [
                4.elephants,
                3.elephants + 1.joker,
                2.elephants + 1.mosquito + 1.joker,
                3.elephants + 1.mosquito,
                2.elephants + 2.mosquitoes,
                1.elephant + 1.joker + 2.mosquitoes,
                ]
            case 5: return [
                5.elephants,
                4.elephants + 1.joker,
                3.elephants + 1.mosquito + 1.joker,
                2.elephants + 1.mosquito,
                3.elephants + 2.mosquitoes,
                2.elephants + 1.joker + 2.mosquitoes,
                ]
            default: return []
            }
        }
        return [[cardType: count], [cardType: count - 1, .joker: 1]]
    }
}

extension Move : CustomStringConvertible {
    var description: String {
        if self == .pass {
            return "pass"
        }
        return cards.description
    }
}
