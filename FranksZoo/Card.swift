
enum Card: Int, Comparable {
    case whale
    case elephant
    case crocodile
    case bear
    case lion
    case seal
    case fox
    case perch
    case hedgehog
    case fish
    case mouse
    case mosquito
    case joker
    
    
    static func <(lhs: Card, rhs: Card) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

fileprivate let predatorDict: [Card: Set<Card>] = [
    .elephant: [.mouse],
    .crocodile: [.elephant],
    .bear: [.whale, .elephant],
    .lion: [.elephant],
    .seal: [.bear, .whale],
    .fox: [.elephant, .crocodile, .bear, .elephant],
    .perch: [.whale, .crocodile, .bear, .seal],
    .hedgehog: [.fox],
    .fish: [.whale, .crocodile, .seal, .perch],
    .mouse: [.crocodile, .bear, .lion, .seal, .fox, .hedgehog],
    .mosquito: [.hedgehog, .fish, .mouse],
]
}
