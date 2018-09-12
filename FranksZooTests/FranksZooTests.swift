import XCTest
@testable import FranksZoo

class FranksZooTests: XCTestCase {
    
    func testCardPredators() {
        XCTAssertEqual(Card.hedgehog.predators, Set([Card.fox]))
        XCTAssertEqual(Card.whale.predators, Set([]))
    }
    
    func testCardsToArray() {
        let testMove: Move = 5.elephants + 4.whales
        let array = testMove.toArray()
        XCTAssertEqual(array, [.whale, .whale, .whale, .whale, .elephant, .elephant, .elephant, .elephant, .elephant])
    }
    
}
