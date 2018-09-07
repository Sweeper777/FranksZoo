extension Move : ExpressibleByDictionaryLiteral {
    typealias Key = Card
    typealias Value = Int
    init(dictionaryLiteral elements: (Card, Int)...) {
        self.init(cards: Dictionary(uniqueKeysWithValues: elements))
    }
}

extension Int {
    var whale: Move {
        return [.whale: self]
    }
    
    var whales: Move {
        return [.whale: self]
    }
    
    var elephant: Move {
        return [.elephant: self]
    }
    
    var elephants: Move {
        return [.elephant: self]
    }
    
    var crocodile: Move {
        return [.crocodile: self]
    }
    
    var crocodiles: Move {
        return [.crocodile: self]
    }
    
    var bear: Move {
        return [.bear: self]
    }
    
    var bears: Move {
        return [.bear: self]
    }
    
    var lion: Move {
        return [.lion: self]
    }
    
    var lions: Move {
        return [.lion: self]
    }
    
}
