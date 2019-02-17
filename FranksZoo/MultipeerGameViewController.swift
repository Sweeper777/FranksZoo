import UIKit
import SwiftyButton
import SCLAlertView
import MultipeerConnectivity

class MultipeerGameViewController: UIViewController {
    
    var isHost = false
    var session: MCSession!
    var playerOrder: [MCPeerID : Int]!
    
    @IBOutlet var opponentHand1: OpponentsHandView!
    @IBOutlet var opponentHand2: OpponentsHandView!
    @IBOutlet var opponentHand3: OpponentsHandView!
    @IBOutlet var handCollectionView: UICollectionView!
    @IBOutlet var bottomStackView: UIStackView!
    @IBOutlet var dealButton: PressableButton!
    @IBOutlet var passButton: PressableButton!
    @IBOutlet var moveDisplayer: MoveDisplayerView!
    
    var quitButton: PressableButton!
    
    var initialAnimationPlayed = false
    
    var game: Game!
    
    var cards: [Card] {
        return game.playerHands[0].toArray()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isHost {
            game = Game()
            let peerIDs = session.connectedPeers + [session.myPeerID]
            let orderNumbers = [0,1,2,3].shuffled()
            playerOrder = Dictionary(uniqueKeysWithValues: zip(peerIDs, orderNumbers))
        } else {
            try! session.send(Data(bytes: [MultipeerCommands.ready.rawValue]), toPeers: session.connectedPeers, with: .reliable)
        }
        
        passButton.colors = PressableButton.ColorSet(button: UIColor.red.darker(), shadow: UIColor.red.darker().darker())
        dealButton.colors = PressableButton.ColorSet(button: UIColor.green.darker(), shadow: UIColor.green.darker().darker())
        
        opponentHand1.orientation = .right
        opponentHand2.orientation = .down
        opponentHand3.orientation = .left
        handCollectionView.allowsMultipleSelection = true
        
        opponentHand1.numberOfCards = 0
        opponentHand2.numberOfCards = 0
        opponentHand3.numberOfCards = 0
        bottomStackView.isHidden = true
        
        moveDisplayer.backgroundColor = .clear
        
        quitButton = PressableButton(frame: .zero)
        quitButton.setTitle("×", for: .normal)
        view.addSubview(quitButton)
        quitButton.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(UIScreen.statusBarHeight + 8)
            make.right.equalTo(view.safeAreaLayoutGuide.snp.right).offset(-8)
            make.width.equalTo(quitButton.snp.height)
            make.height.equalTo(UIScreen.main.nativeBounds.height / UIScreen.main.nativeScale / 20)
        }
        quitButton.addTarget(self, action: #selector(quitButtonPress), for: .touchUpInside)
    }
    
    func updateButtonFontSizes() {
        [dealButton, passButton].forEach {
            $0?.titleLabel?.updateFontSizeToFit(size: $0!.bounds.size, multiplier: 0.7)
        }
        quitButton.titleLabel?.updateFontSizeToFit(size: quitButton.bounds.size, multiplier: 1)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !initialAnimationPlayed {
            startInitialAnimation()
            initialAnimationPlayed = true
        }
        self.moveDisplayer.cardSize = CGSize(width: self.opponentHand2.height * 5 / 7 * 1.5, height: self.opponentHand2.height * 1.5)
        updateButtonFontSizes()
    }
    
    override func viewDidLayoutSubviews() {
        
        quitButton.updateTitleOffsets()
        dealButton.updateTitleOffsets()
        passButton.updateTitleOffsets()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if traitCollection.horizontalSizeClass == .regular && traitCollection.verticalSizeClass == .regular {
            return .all
        } else {
            return .landscape
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animateAlongsideTransition(in: nil, animation: nil, completion:  {
            [unowned self] _ in
            
            self.moveDisplayer.cardSize = CGSize(width: self.opponentHand2.height * 5 / 7 * 1.5, height: self.opponentHand2.height * 1.5)
            self.updateButtonFontSizes()
            self.opponentHand1.setNeedsDisplay()
            self.opponentHand2.setNeedsDisplay()
            self.opponentHand3.setNeedsDisplay()
            self.handCollectionView.reloadData()
        })
    }
    
    func startInitialAnimation() {
        Timer.every(0.1) { [weak self] (timer) in
            self?.opponentHand1.numberOfCards += 1
            self?.opponentHand2.numberOfCards += 1
            self?.opponentHand3.numberOfCards += 1
            if self?.opponentHand1.numberOfCards == 15 {
                timer.invalidate()
                self?.bottomStackView.isHidden = false
            }
            }.start()
    }
    
    @IBAction func dealPress() {
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
//                    let makeMove = self?.aiMakeMove
//                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: makeMove ?? {})
                })
            }
        }
    }
    
    @IBAction func passPress() {
        guard game.currentTurn == 0 && !game.ended else { return }
        game.makeMove(.pass)
        moveDisplayer.animateMove(.pass, forPlayer: 0) {
            [weak self] in
            self?.handCollectionView.reloadData()
            self?.updateOpponentsHandView()
            self?.updateMoveDisplayer()
//            let makeMove = self?.aiMakeMove
//            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: makeMove ?? {})
        }
    }
    
    @objc func didTapCollectionViewCell(tapper: UIGestureRecognizer) {
        if tapper.state == .recognized {
            let touchCount = tapper.numberOfTouches
            for i in 0..<touchCount {
                let point = tapper.location(ofTouch: i, in: self.handCollectionView)
                if let index = handCollectionView.indexPathForItem(at: point) {
                    if handCollectionView.indexPathsForSelectedItems?.contains(index) ?? false {
                        handCollectionView.deselectItem(at: index, animated: false)
                        let cell = handCollectionView.cellForItem(at: index)
                        cell?.isSelected = false
                    }else{
                        handCollectionView.selectItem(at: index, animated: false, scrollPosition: [])
                        let cell = handCollectionView.cellForItem(at: index)
                        cell?.isSelected = true
                    }
                }
            }
        }
    }
    
    @objc func quitButtonPress() {
        let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
        alert.addButton("Yes", action: quitGame)
        alert.addButton("No", action: {})
        alert.showWarning("Confirm", subTitle: "Do you really want to quit?")
        
    }
    
    func updateOpponentsHandView() {
        opponentHand1.numberOfCards = game.playerHands[1].toArray().count
        opponentHand2.numberOfCards = game.playerHands[2].toArray().count
        opponentHand3.numberOfCards = game.playerHands[3].toArray().count
    }
    
    func updateMoveDisplayer() {
        moveDisplayer.displayedMove = game.lastMove
    }
    
    func aiMakeMove() {
        guard !game.ended else { return }
        
        let move: Move
        switch game.currentTurn {
        case 0:
            return
        case 1, 2, 3:
            let ai = GameAI(game: game, playerIndex: game.currentTurn)
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
//            let makeMove = self?.aiMakeMove
//            if nextAITurn {
//                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: makeMove ?? {})
//            }
        })
    }
}

extension MultipeerGameViewController : UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CardCell
        if collectionView.indexPathsForSelectedItems?.contains(indexPath) ?? false {
            cell.isSelected = true
        } else {
            cell.isSelected = false
        }
        cell.imageView.image = UIImage(named: imageDict[cards[indexPath.item]]!)
        cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapCollectionViewCell(tapper:))))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.height / 1.15
        let width = height * 5 / 7
        return CGSize(width: width, height: height)
    }
}

extension MultipeerGameViewController : GameDelegate {
    func playerDidWin(game: Game, player: Int, place: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2, execute: {
            [weak self] in
            self?.handlePlayerWin(game: game, player: player, place: place)
        })
    }
    
    func handlePlayerWin(game: Game, player: Int, place: Int) {
        let placeNames = [1: "first", 2: "second", 3: "third"]
        if player == 0 {
            if place < 3 {
                let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
                alert.addButton("Yes", action: {})
                alert.addButton("No", action: quitGame)
                alert.showInfo("You came \(placeNames[place]!)", subTitle: "Do you want to continue watching the rest of the game?")
            } else {
                let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: true))
                alert.showInfo("You came \(placeNames[place]!)", subTitle: "")
            }
        } else if place == 3 {
            if game.playerHands[0].isEmpty {
                let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
                alert.addButton("Quit", action: quitGame)
                alert.showInfo("Game ended!", subTitle: "")
            } else {
                let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
                alert.addButton("Quit", action: quitGame)
                alert.showInfo("You lost!", subTitle: "")
            }
        }
    }
    
    func quitGame() {
        performSegue(withIdentifier: "unwindToMainMenu", sender: nil)
    }
}

