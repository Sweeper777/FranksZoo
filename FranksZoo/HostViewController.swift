import UIKit
import RxCocoa
import RxSwift
import MultipeerConnectivity
import SwiftyButton

class HostViewController : UIViewController {
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    
    var startButton: PressableButton!
    
    let peerID = MCPeerID(displayName: UIDevice.current.name)
    var session: MCSession!
    var advertiser: MCNearbyServiceAdvertiser!
    var connectedPeers: Variable<[MCPeerID]> = Variable([])
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        tableView.backgroundColor = .clear
        descriptionLabel.text = descriptionLabel.text?.replacingOccurrences(of: "DEVICE NAME", with: UIDevice.current.name)
        
        session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .optional)
        session.delegate = self
        advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: "frankszoo\(Bundle.main.appBuild)")
        advertiser.delegate = self
        
        connectedPeers.asObservable().bind(to: tableView.rx.items(cellIdentifier: "cell")) {
            row, model, cell in
            cell.textLabel?.text = model.displayName
            cell.detailTextLabel?.text = "Tap to remove"
            cell.backgroundColor = .clear
            }.disposed(by: disposeBag)
        
        tableView.rx.modelSelected(MCPeerID.self).bind { [weak self] (model) in
            guard let `self` = self else { return }
            guard let index = self.connectedPeers.value.firstIndex(of: model) else { return }
            self.tableView.deselectRow(at: IndexPath(row: index, section: 0), animated: false)
            try? self.session.send(Data(bytes: [MultipeerCommands.disconnect.rawValue]), toPeers: [self.connectedPeers.value[index]], with: .reliable)
            
        }.disposed(by: disposeBag)
        
        startButton = PressableButton(frame: .zero)
        view.addSubview(startButton)
        startButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().dividedBy(5)
            make.bottom.equalTo(descriptionLabel.snp.top).offset(-8)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
        }
        startButton.colors = PressableButton.ColorSet(button: UIColor.green.darker(), shadow: UIColor.green.darker().darker())
        startButton.setTitle("START", for: .normal)
        startButton.addTarget(self, action: #selector(startPress), for: .touchUpInside)
        
        connectedPeers.asObservable().map { (peers) -> CGFloat in
            return (1..<4).contains(peers.count) ? 1 : 0
        }.bind(to: startButton.rx.alpha).disposed(by: disposeBag)
    }
    
    override func viewDidLayoutSubviews() {
        startButton.titleLabel?.updateFontSizeToFit(size: startButton.bounds.size, multiplier: 0.7)
        startButton.updateTitleOffsets()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        advertiser.startAdvertisingPeer()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        advertiser.stopAdvertisingPeer()
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if traitCollection.horizontalSizeClass == .regular && traitCollection.verticalSizeClass == .regular {
            return .all
        } else {
            return .landscape
        }
    }
    
    @IBAction func closePress() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func startPress() {
        performSegue(withIdentifier: "unwindToMainMenu", sender: nil)
        try! session.send(Data(bytes: [MultipeerCommands.startGame.rawValue]), toPeers: session.connectedPeers, with: .reliable)
    }
}

extension HostViewController : MCSessionDelegate, MCNearbyServiceAdvertiserDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        if state == .connected {
            connectedPeers.value.append(peerID)
        } else if state == .notConnected {
            _ = connectedPeers.value.remove(object: peerID)
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        if session.connectedPeers.count < 4 {
            invitationHandler(true, session)
        } else {
            invitationHandler(false, nil)
        }
    }
    
    
}
