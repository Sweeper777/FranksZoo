struct Move : Cards, Equatable {
    let cards: [Card : Int]
    static let pass = Move()
    
    init(cards: [Card: Int]) {
        self.cards = cards.filter { $0.value > 0 }
    }
    
    init() {
        self.init(cards: [:])
    }
    
    static func ==(lhs: Move, rhs: Move) -> Bool {
        return lhs.cards == rhs.cards
    }
    
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
    
    var mainCardType: Card? {
        if !isLegal { return nil }
        
        
        if cards.keys.contains(.elephant) &&
            cards.keys.contains(.mosquito) {
            return .elephant
        }
        var cardsCopy = cards
        cardsCopy[.joker] = nil
        return cards.keys.first
    }
    
    var defeatableMoves: [Move] {
        var moves: [Move] = []
        return moves
    }
}

