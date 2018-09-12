import XCTest
@testable import FranksZoo

class FranksZooTests: XCTestCase {
    
    func testCardPredators() {
        XCTAssertEqual(Card.hedgehog.predators, Set([Card.fox]))
        XCTAssertEqual(Card.whale.predators, Set([]))
    }
    
}
