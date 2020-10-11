import Foundation

protocol GameDelegate: class {
    func playerDidWin(game: Game, player: Int, place: Int)
    
    func playerTurnDidChange(to turn: Int, game: Game)
}
