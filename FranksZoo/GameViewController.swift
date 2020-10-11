import UIKit
import SwiftyButton
import SCLAlertView

class GameViewController: GameViewControllerBase {
    
    override func viewDidLoad() {
        game = Game()
        
        game.currentTurn = Int.random(in: 0..<4)
        game.delegate = self
        
        super.viewDidLoad()
        
        if game.currentTurn != 0 {
            let delay = Double(60 / game.playerCount) * 0.01 + 2.0
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: self.aiMakeMove)
        }
    }
    
    override func initialAnimationDidEnd() {
        super.initialAnimationDidEnd()
        if self.game.currentTurn == 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                [weak self] in
                self?.moveDisplayer.animateItsYourTurn()
            }
        }
    }
    
    @IBAction override func dealPress() {
        guard game.currentTurn == 0 && !game.ended else { return }
        
        let selectedCards = (handCollectionView.indexPathsForSelectedItems ?? []).map { cards[$0.item] }
        if selectedCards.count > 0 {
            let moveDict = Dictionary(grouping: selectedCards, by: { $0 }).mapValues { $0.count }
            let move = Move(cards: moveDict)
            let player = game.currentTurn
            if (game.makeMove(move)) {
                moveDisplayer.animateMove(move, forPlayer: player, completion: {
                    [weak self] in
                    self?.handCollectionView.reloadData()
                    self?.updateOpponentsHandView()
                    self?.updateMoveDisplayer()
                    let makeMove = self?.aiMakeMove
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: makeMove ?? {})
                })
            }
        }
    }
    
    @IBAction override func passPress() {
        guard game.currentTurn == 0 && !game.ended else { return }
        game.makeMove(.pass)
        moveDisplayer.animateMove(.pass, forPlayer: 0) {
            [weak self] in
            self?.handCollectionView.reloadData()
            self?.updateOpponentsHandView()
            self?.updateMoveDisplayer()
            let makeMove = self?.aiMakeMove
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: makeMove ?? {})
        }
    }
    
    func aiMakeMove() {
        guard !game.ended else { return }
        
        let move: Move
        switch game.currentTurn {
        case 0:
            return
        case 1, 2, 3:
            let ai = HeuristicAI(game: game, playerIndex: game.currentTurn)
            move = ai.getNextMove()
        default:
            fatalError()
        }
        let player = game.currentTurn
        game.makeMove(move)
        let nextAITurn = game.currentTurn != 0
        moveDisplayer.animateMove(move, forPlayer: player, completion: {
            [weak self] in
            self?.updateOpponentsHandView()
            self?.updateMoveDisplayer()
            let makeMove = self?.aiMakeMove
            if nextAITurn {
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: makeMove ?? {})
            }
        })
    }
}
