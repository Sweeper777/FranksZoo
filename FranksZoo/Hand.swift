struct Hand: Cards {
    var cards: [Card : Int]

    init(cards: [Card: Int]) {
        self.cards = cards.filter { $0.value > 0 }
    }
    
}
