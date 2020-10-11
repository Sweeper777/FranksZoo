/// An object that represents all the cards that a player or AI has
struct Hand: Cards, Codable {
    /// The cards in this hand
    var cards: [Card : Int]

    init(cards: [Card: Int]) {
        self.cards = cards.filter { $0.value > 0 }
    }
    
    /// Removes cards in the move from the hand.
    ///
    /// - Returns: whether the removal was successful.
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
    
    /// Returns whether a move can be made by this hand
    func canMakeMove(_ move: Move) -> Bool {
        for (key, value) in move.cards {
            // if the hand does not have this card
            if cards[key] == nil {
                return false
            }
            // if the hand does not have enough of this type of card
            if cards[key]! < value {
                return false
            }
        }
        return true
    }
    
    /// Returns whether the hand has no cards
    var isEmpty: Bool {
        return cards.isEmpty
    }
}
