struct Move : Cards, Equatable {
    let cards: [Card : Int]
    static let pass = Move()
    
    init(cards: [Card: Int]) {
        self.cards = cards.filter { $0.value > 0 }
    }
    
    init() {
        self.init(cards: [:])
    }
}

