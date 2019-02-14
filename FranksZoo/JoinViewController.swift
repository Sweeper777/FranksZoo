import UIKit
import RxCocoa
import RxSwift
import MultipeerConnectivity

enum ConnectionState {
    case connecting
    case connected
    case notConnected
    case error
}

struct PeerIDStateTuple : Equatable {
    let peerID: MCPeerID
    var state: ConnectionState
    
    init(peerID: MCPeerID) {
        self.peerID = peerID
        self.state = .notConnected
    }
    
    static func ==(lhs: PeerIDStateTuple, rhs: PeerIDStateTuple) -> Bool {
        return lhs.peerID == rhs.peerID
    }
}

class JoinViewController : UIViewController {
    @IBOutlet var tableView: UITableView!
    
    let peerID = MCPeerID(displayName: UIDevice.current.name)
    var session: MCSession!
    var browser: MCNearbyServiceBrowser!
    var foundPeers: Variable<[PeerIDStateTuple]> = Variable([])
    var connectionStateWithHost = ConnectionState.notConnected
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        tableView.backgroundColor = .clear
        session = MCSession(peer: peerID)
        session.delegate = self
        browser = MCNearbyServiceBrowser(peer: peerID, serviceType: "frankszoo\(Bundle.main.appBuild)")
        browser.delegate = self
        
    }
}
