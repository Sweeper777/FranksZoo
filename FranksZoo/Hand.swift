struct Hand: Cards {
    var cards: [Card : Int]

    init(cards: [Card: Int]) {
        self.cards = cards.filter { $0.value > 0 }
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
}
