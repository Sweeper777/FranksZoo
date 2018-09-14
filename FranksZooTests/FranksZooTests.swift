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
    
    func testMainCardType() {
        var testMove = 1.elephant + 1.mosquito
        XCTAssertEqual(testMove.mainCardType, .elephant)
        testMove = 1.elephant + 1.joker + 2.mosquitoes
        XCTAssertEqual(testMove.mainCardType, .elephant)
        testMove = 3.mosquitoes
        XCTAssertEqual(testMove.mainCardType, .mosquito)
        testMove = 2.mosquitoes + 1.elephant
        XCTAssertEqual(testMove.mainCardType, nil)
        testMove = 1.whale + 1.elephant
        XCTAssertEqual(testMove.mainCardType, nil)
        testMove = 1.joker
        XCTAssertEqual(testMove.mainCardType, nil)
    }
    
    func testDefeatableMoves() {
        var testMove = 3.bears
        var defeatableMoves = testMove.defeatableMoves
        XCTAssertTrue(defeatableMoves.contains([
            4.bears,
            3.bears + 1.joker,
            3.whales,
            2.whales + 1.joker,
            3.elephants,
            2.elephants + 1.joker,
            2.elephants + 1.mosquito,
            1.elephant + 1.mosquito + 1.joker
        ]))
        XCTAssertEqual(defeatableMoves.count, 8)
        
        testMove = 3.whales
        defeatableMoves = testMove.defeatableMoves
        XCTAssertTrue(defeatableMoves.contains([
            4.whales,
            3.whales + 1.joker
        ]))
        XCTAssertEqual(defeatableMoves.count, 2)
    }
    
    func testHandCanMakeMove() {
        var hand = Hand(cards: [.elephant: 3, .whale: 2, .fish: 4])
        XCTAssertTrue(hand.canMakeMove(3.elephants))
        XCTAssertTrue(hand.canMakeMove(2.elephants))
        XCTAssertTrue(hand.canMakeMove(.pass))
        XCTAssertFalse(hand.canMakeMove(4.elephants))
        XCTAssertTrue(hand.canMakeMove(3.elephants + 2.whales))
        hand = Hand(cards: [:])
        XCTAssertFalse(hand.canMakeMove(3.elephants))
        XCTAssertFalse(hand.canMakeMove(2.elephants))
        XCTAssertTrue(hand.canMakeMove(.pass))
        XCTAssertFalse(hand.canMakeMove(4.elephants))
    }
    
    func testHandMakeMove() {
        var hand = Hand(cards: [.elephant: 3, .whale: 2, .fish: 4])
        hand.makeMove(2.elephants)
        XCTAssertEqual(hand.cards, [.elephant: 1, .whale: 2, .fish: 4])
        hand.makeMove(3.whales)
        XCTAssertEqual(hand.cards, [.elephant: 1, .whale: 2, .fish: 4])
        hand.makeMove(2.whales)
        XCTAssertEqual(hand.cards, [.elephant: 1, .fish: 4])
    }
    
    func testGameInit() {
        let game = Game()
        XCTAssertEqual(game.playerHands[0].toArray().count, 15)
        XCTAssertEqual(game.playerHands[1].toArray().count, 15)
        XCTAssertEqual(game.playerHands[2].toArray().count, 15)
        XCTAssertEqual(game.playerHands[3].toArray().count, 15)
        
    }
    
}
