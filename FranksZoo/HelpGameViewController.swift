import UIKit
import DVITutorialView
import SCLAlertView

class HelpGameViewController : GameViewControllerBase {
    var currentlyAllowedMove: Move?
    var currentHelpPart = 0
    
    override func viewDidLoad() {
        game = helpGame()
        
        game.delegate = self
        
        super.viewDidLoad()
    }
    
    override func initialAnimationDidEnd() {
        super.initialAnimationDidEnd()
        
        nextHelpPart()
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
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                        [weak self] in
                        self?.nextHelpPart()
                    })
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                [weak self] in
                self?.nextHelpPart()
            })
        }
    }
    
    func helpGame() -> Game {
        let game = Game()
        game.playerHands = [
            Hand(cards: [.fish: 2, .elephant: 1, .mosquito: 1, .fox: 1, .whale: 4, .crocodile: 2, .hedgehog: 2, .mouse: 2]),
            Hand(cards: [.perch: 2, .mouse: 2, .fish: 1, .elephant: 4, .whale: 1, .hedgehog: 1, .lion: 3, .crocodile: 1]),
            Hand(cards: [.hedgehog: 2, .fox: 3, .mosquito: 3, .lion: 2, .bear: 3, .seal: 2]),
            Hand(cards: [.crocodile: 2, .fox: 1, .fish: 2, .joker: 1, .seal: 3, .perch: 3, .bear: 2, .mouse: 1])
        ]
        return game
    }
    
    func nextHelpPart() {
        let helpParts = [helpPart1, helpPart2, helpPart3, helpPart4,
                         helpPart5, helpPart6, helpPart7, helpPart8]
        helpParts[currentHelpPart]()
        currentHelpPart += 1
    }
    
    func animateMoves(_ moves: [Move], completion: @escaping () -> ()) {
        if moves.isEmpty {
            completion()
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            [weak self] in
            let currentPlayer = self?.game.currentTurn
            self?.game.makeMove(moves.first!)
            self?.moveDisplayer.animateMove(moves.first!, forPlayer: currentPlayer ?? 0, completion: {
                [weak self] in
                self?.updateOpponentsHandView()
                self?.updateMoveDisplayer()
                self?.animateMoves(Array(moves.dropFirst()), completion: completion)
            })
        }
    }
}
