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
        
        session = MCSession(peer: peerID)
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
}
