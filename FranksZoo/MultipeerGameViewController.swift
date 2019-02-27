import UIKit
import SwiftyButton
import SCLAlertView
import MultipeerConnectivity

class MultipeerGameViewController: GameViewControllerBase {
    
    var isHost = false
    var session: MCSession!
    var playerOrder: [MCPeerID : Int]!
    
    var isAiRunner: Bool {
        let myTurn = playerOrder[session.myPeerID]!
        return playerOrder.values.min() == myTurn
    }
    
    var isAiTurn: Bool {
        if game == nil {
            return false
        }
        
        let myTurn = playerOrder[session.myPeerID]!
        let aiTurnNumbers = Set([0,1,2,3]).subtracting(playerOrder.values).map { ($0 - myTurn) %% 4 }
        return aiTurnNumbers.contains(game.currentTurn)
    }
    
    var nextAiMove: Move?
    
    override func viewDidLoad() {
        session.delegate = self
        if isHost {
            game = Game()
            game.delegate = self
            let peerIDs = [session.myPeerID] + session.connectedPeers
            let orderNumbers = [0,1,2,3]/*.shuffled()*/
            playerOrder = Dictionary(uniqueKeysWithValues: zip(peerIDs, orderNumbers))
            let myTurn = playerOrder[session.myPeerID]!
            if myTurn != 0 {
                game.currentTurn = 4 - myTurn
                game.playerHands = game.playerHands.shifted(by: -myTurn)
            }
        } else {
            try! session.send(Data(bytes: [MultipeerCommands.ready.rawValue]), toPeers: session.connectedPeers, with: .reliable)
            print("Ready signal sent")
        }
        super.viewDidLoad()
    }
    

    override func initialAnimationDidEnd() {
        super.initialAnimationDidEnd()
        runAiIfAble()
        
        if game.currentTurn == 0 {
            moveDisplayer.animateItsYourTurn()
        }
    }
    
    func runAiIfAble() {
        if isAiRunner && isAiTurn {
            if let move = getAiMove() {
                let moveInfo = MoveInfo(move: move, madeByAi: true)
                let encoder = JSONEncoder()
                let data = try! encoder.encode(moveInfo)
                if !session.connectedPeers.isEmpty {
                    try! session.send(data, toPeers: session.connectedPeers, with: .reliable)
                }
                handleMakeMove(moveInfo)
            }
        }
    }
    
    @IBAction override func dealPress() {
        guard game.currentTurn == 0 && !game.ended else { return }
        
        let selectedCards = (handCollectionView.indexPathsForSelectedItems ?? []).map { cards[$0.item] }
        if selectedCards.count > 0 {
            let moveDict = Dictionary(grouping: selectedCards, by: { $0 }).mapValues { $0.count }
            let move = Move(cards: moveDict)
            if game.canMakeMove(move) {
                let moveInfo = MoveInfo(move: move, madeByAi: false)
                let encoder = JSONEncoder()
                let data = try! encoder.encode(moveInfo)
                if !session.connectedPeers.isEmpty {
                    try! session.send(data, toPeers: session.connectedPeers, with: .reliable)
                }
                handleMakeMove(moveInfo)
            }
        }
    }
    
    @IBAction override func passPress() {
        guard game.currentTurn == 0 && !game.ended else { return }
        let moveInfo = MoveInfo(move: .pass, madeByAi: false)
        let encoder = JSONEncoder()
        let data = try! encoder.encode(moveInfo)
        if !session.connectedPeers.isEmpty {
            try! session.send(data, toPeers: session.connectedPeers, with: .reliable)
        }
        handleMakeMove(moveInfo)
    }
    
    func getAiMove() -> Move? {
        guard !game.ended else { return nil }
        
        let move: Move
        switch game.currentTurn {
        case 0:
            return nil
        case 1, 2, 3:
            let ai = GameAI(game: game, playerIndex: game.currentTurn)
            move = ai.getNextMove()
        default:
            fatalError()
        }
        return move
    }
    
    override func quitGame() {
        if !session.connectedPeers.isEmpty {
            try! session.send(Data(bytes: [MultipeerCommands.disconnect.rawValue]), toPeers: session.connectedPeers, with: .reliable)
        }
        super.quitGame()
    }
}

extension MultipeerGameViewController : MCSessionDelegate {
    fileprivate func handleDisconnectOfPeer(_ peerID: MCPeerID) {
        if (!isAiTurn && game.currentTurn != 0) || (isAiTurn && nextAiMove == nil) {
            playerOrder[peerID] = nil
            runAiIfAble()
        } else {
            playerOrder[peerID] = nil
        }
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        guard !game.ended else { return }
        
        if state == .notConnected {
            handleDisconnectOfPeer(peerID)
        }
    }
    
    fileprivate func handleMakeMove(_ moveInfo: MoveInfo) {
        let delay: TimeInterval = moveInfo.madeByAi ? 2 : 0
        if moveInfo.madeByAi {
            nextAiMove = moveInfo.move
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            [weak self] in
            guard let `self` = self else { return }
            let player = self.game.currentTurn
            self.game.makeMove(moveInfo.move)
            self.nextAiMove = nil
            self.moveDisplayer.animateMove(moveInfo.move, forPlayer: player, completion: {
                [weak self] in
                if player == 0 {
                    self?.handCollectionView.reloadData()
                }
                self?.updateOpponentsHandView()
                self?.updateMoveDisplayer()
                self?.runAiIfAble()
            })
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let decoder = JSONDecoder()
        if data.count == 1 {
            if data[0] == MultipeerCommands.ready.rawValue && isHost{
                let gameCopy = Game(copyOf: game)
                gameCopy.playerHands = gameCopy.playerHands.shifted(by: playerOrder[session.myPeerID]!)
                gameCopy.currentTurn = 0
                let gameInfo = GameInfo(game: gameCopy, playerOrder: playerOrder)
                let data = try! JSONEncoder().encode(gameInfo)
                try! session.send(data, toPeers: [peerID], with: .reliable)
            } else if data[0] == MultipeerCommands.disconnect.rawValue {
                handleDisconnectOfPeer(peerID)
            }
        } else if let gameInfo = try? decoder.decode(GameInfo.self, from: data) {
            game = gameInfo.game
            playerOrder = gameInfo.playerOrder
            let myTurn = playerOrder[session.myPeerID]!
            if myTurn != 0 {
                game.currentTurn = 4 - myTurn
                game.playerHands = game.playerHands.shifted(by: -myTurn)
                game.delegate = self
            }
            DispatchQueue.main.async(execute: handCollectionView.reloadData)
        } else if let moveInfo = try? decoder.decode(MoveInfo.self, from: data) {
            handleMakeMove(moveInfo)
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    
}
