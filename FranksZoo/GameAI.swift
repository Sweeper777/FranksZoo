class GameAI {
    let game: Game
    let playerIndex: Int
    
    let weightDict: [Card: Int] = [
        .joker: 0,
        .elephant: 2,
        .whale: 8,
        .bear: 14,
        .crocodile: 18,
        .seal: 30,
        .fox: 40,
        .mouse: 46,
        .lion: 48,
        .hedgehog: 62,
        .perch: 70,
        .mosquito: 76,
        .fish: 84
    ]
    
    var myHand: Hand {
        return game.playerHands[playerIndex]
    }
}
