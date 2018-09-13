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
    
    func testMoveCanDefeat() {
        XCTAssertTrue((2.elephants).canDefeat(2.crocodiles))
        XCTAssertTrue((1.elephant + 1.joker + 2.mosquitoes).canDefeat(4.crocodiles))
        XCTAssertTrue(2.mice.canDefeat(1.mouse))
        XCTAssertFalse(3.mice.canDefeat(1.mouse))
        XCTAssertFalse(2.mice.canDefeat(2.mice))
        XCTAssertFalse(2.crocodiles.canDefeat(2.elephants))
        XCTAssertFalse((2.mosquitoes + 1.elephant).canDefeat(3.crocodiles))
        XCTAssertFalse((1.elephant + 1.mosquito).canDefeat(2.whales))
    }
    
}
