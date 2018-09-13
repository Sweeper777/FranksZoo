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
    
    func testMoveIsLegal() {
        var testMove = 1.elephant + 1.mosquito
        XCTAssertTrue(testMove.isLegal)
        testMove = 1.elephant + 1.joker + 2.mosquitoes
        XCTAssertTrue(testMove.isLegal)
        testMove = 2.mosquitoes + 1.elephant
        XCTAssertFalse(testMove.isLegal)
        testMove = 1.whale + 1.elephant
        XCTAssertFalse(testMove.isLegal)
        testMove = 1.joker
        XCTAssertFalse(testMove.isLegal)
    }
    
}
