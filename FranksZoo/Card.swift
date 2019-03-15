
/// An enum representing a type of card. e.g. whale, elephant, joker
enum Card: Int, Comparable, Codable {
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
    
    /// Returns the predators of the receiver's card type
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
    .fox: [.elephant, .crocodile, .bear, .lion],
    .perch: [.whale, .crocodile, .bear, .seal],
    .hedgehog: [.fox],
    .fish: [.whale, .crocodile, .seal, .perch],
    .mouse: [.crocodile, .bear, .lion, .seal, .fox, .hedgehog],
    .mosquito: [.hedgehog, .fish, .mouse],
]

/// A dictionary storing the card types as keys and the name of the image
/// of the card as values.
let imageDict: [Card: String] = [
    .whale: "whale",
    .elephant: "elephant",
    .crocodile: "crocodile",
    .bear: "bear",
    .lion: "lion",
    .seal: "seal",
    .fox: "fox",
    .perch: "perch",
    .hedgehog: "hedgehog",
    .fish: "fish",
    .mouse: "mouse",
    .mosquito: "mosquito",
    .joker: "joker"
]

/// A protocol that represents a collection of cards
protocol Cards {
    
    /// The cards in the collection of cards, and how many of each card type there is
    var cards: [Card: Int] { get }
    
}

extension Cards {
    /// Returns the number of a particular card type in the collection of cards
    func numberOf(_ card: Card) -> Int {
        return cards[card] ?? 0
    }
    
    /// Converts the collection of cards to an array.
    func toArray() -> [Card] {
        return cards.flatMap { Array(repeating: $0.key, count: $0.value) }.sorted()
    }
    
}

/// A class that represents all the cards in a game.
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
