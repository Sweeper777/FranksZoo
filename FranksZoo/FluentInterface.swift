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
    
    var seal: Move {
        return [.seal: self]
    }
    
    var seals: Move {
        return [.seal: self]
    }
    
    var fox: Move {
        return [.fox: self]
    }
    
    var foxes: Move {
        return [.fox: self]
    }
    
    var perch: Move {
        return [.perch: self]
    }
    
    var perches: Move {
        return [.perch: self]
    }
    
    var hedgehog: Move {
        return [.hedgehog: self]
    }
    
    var hedgehogs: Move {
        return [.hedgehog: self]
    }
    
    var fish: Move {
        return [.fish: self]
    }
    
    var mouse: Move {
        return [.mouse: self]
    }
    
    var mice: Move {
        return [.mouse: self]
    }
    
    var mosquito: Move {
        return [.mosquito: self]
    }
    
    var mosquitoes: Move {
        return [.mosquito: self]
    }
    
    var joker: Move {
        return [.joker: self]
    }
}

func +(move1: Move, move2: Move) -> Move {
    return Move(cards: move1.cards.merging(move2.cards, uniquingKeysWith: +))
}
