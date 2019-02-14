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
        
        foundPeers.asObservable().bind(to: tableView.rx.items(cellIdentifier: "cell")) {
            row, model, cell in
            cell.textLabel?.text = model.peerID.displayName
            switch model.state {
            case .connected:
                cell.detailTextLabel?.text = "Connected"
            case .connecting:
                cell.detailTextLabel?.text = "Connecting..."
            case .error:
                cell.detailTextLabel?.text = "Unable to connect"
            case .notConnected:
                cell.detailTextLabel?.text = ""
            }
            cell.backgroundColor = .clear
            }.disposed(by: disposeBag)
        
        tableView.rx.modelSelected(PeerIDStateTuple.self).bind { [weak self] (model) in
            guard let `self` = self else { return }
            guard let index = self.foundPeers.value.firstIndex(of: model) else { return }
            self.tableView.deselectRow(at: IndexPath(row: index, section: 0), animated: false)
            if self.foundPeers.value[index].state == .connected {
                self.connectionStateWithHost = .notConnected
                self.session.disconnect()
            } else if self.foundPeers.value[index].state == .connecting {
                return
            } else if self.connectionStateWithHost == .notConnected {
                self.connectionStateWithHost = .connecting
                self.browser.invitePeer(model.peerID, to: self.session, withContext: nil, timeout: 10)
            } else if self.connectionStateWithHost == .connecting || self.connectionStateWithHost == .connected {
                self.connectionStateWithHost = .connecting
                self.session.disconnect()
                self.browser.invitePeer(model.peerID, to: self.session, withContext: nil, timeout: 10)
            }
        }.disposed(by: disposeBag)
    }
    }
}
