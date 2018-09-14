struct Hand: Cards {
    var cards: [Card : Int]

    init(cards: [Card: Int]) {
        self.cards = cards.filter { $0.value > 0 }
    }
    
    @discardableResult
    mutating func makeMove(_ move: Move) -> Bool {
        if !canMakeMove(move) {
            return false
        }
        for (key, value) in move.cards {
            if cards[key] != nil {
                cards[key]! -= value
                if cards[key]! == 0 {
                    cards[key] = nil
                }
            }
        }
        return true
    }
    
    func canMakeMove(_ move: Move) -> Bool {
        for (key, value) in move.cards {
            if cards[key] == nil {
                return false
            }
            if cards[key]! < value {
                return false
            }
        }
        return true
    }
    
    var isEmpty: Bool {
        return cards.isEmpty
    }
}
