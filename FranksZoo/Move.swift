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
    }
}

