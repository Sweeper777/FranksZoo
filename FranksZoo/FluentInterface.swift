extension Move : ExpressibleByDictionaryLiteral {
    typealias Key = Card
    typealias Value = Int
    init(dictionaryLiteral elements: (Card, Int)...) {
        self.init(cards: Dictionary(uniqueKeysWithValues: elements))
    }
}
