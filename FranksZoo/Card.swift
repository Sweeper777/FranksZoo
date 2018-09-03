
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
    
    var predators: Set<Card> {
        return predatorDict[self] ?? []
    }
    
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

protocol Cards {
    var cards: [Card: Int] { get }
    
}

extension Cards {
    func numberOf(_ card: Card) -> Int {
        return cards[card] ?? 0
    }
    
    func toArray() -> [Card] {
        return cards.flatMap { Array(repeating: $0.key, count: $0.value) }.sorted()
    }
    
}

class AllCards : Cards {
    let cards: [Card : Int] = [
        .whale: 5,
        .elephant: 5,
        .crocodile: 5,
        .bear: 5,
        .lion: 5,
        .seal: 5,
        .fox: 5,
        .perch: 5,
        .hedgehog: 5,
        .fish: 5,
        .mouse: 5,
        .mosquito: 4,
        .joker: 1
    ]
    
    static let shared = AllCards()
    
    private init() {}
}
