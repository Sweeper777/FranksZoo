import UIKit
import SnapKit
import SwiftyButton
import MultipeerConnectivity

class MainMenuViewController: UIViewController {
    @IBOutlet var buttonContainer: UIView!
    
    var playButton: PressableButton!
    var helpButton: PressableButton!
    var hostButton: PressableButton!
    var joinButton: PressableButton!
    
    var multipeerTransitioning = false
    
    override func viewDidLoad() {
        playButton = PressableButton(frame: .zero)
        buttonContainer.addSubview(playButton)
        playButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(16)
            make.centerX.equalToSuperview()
            make.height.equalToSuperview().dividedBy(4.5).offset(-8)
            make.width.lessThanOrEqualTo(playButton.snp.height).multipliedBy(5)
            make.left.equalToSuperview().offset(8).priority(.high)
            make.right.equalToSuperview().offset(-8).priority(.high)
        }
        playButton.setTitle("PLAY", for: .normal)
        playButton.titleLabel?.font = UIFont(name: "GillSans-UltraBold", size: 10)
        playButton.addTarget(self, action: #selector(playButtonPress), for: .touchUpInside)
        
        helpButton = PressableButton(frame: .zero)
        buttonContainer.addSubview(helpButton)
        helpButton.snp.makeConstraints { (make) in
            make.height.equalTo(playButton.snp.height)
            make.width.equalTo(playButton.snp.width)
            make.centerX.equalTo(playButton.snp.centerX)
            make.top.equalTo(playButton.snp.bottom).offset(16)
        }
        helpButton.setTitle("HELP", for: .normal)
        helpButton.titleLabel?.font = UIFont(name: "GillSans-UltraBold", size: 10)
        
        hostButton = PressableButton(frame: .zero)
        buttonContainer.addSubview(hostButton)
        hostButton.snp.makeConstraints { (make) in
            make.height.equalTo(playButton.snp.height)
            make.width.equalTo(playButton.snp.width)
            make.centerX.equalTo(playButton.snp.centerX)
            make.top.equalTo(helpButton.snp.bottom).offset(16)
        }
        hostButton.setTitle("HOST", for: .normal)
        hostButton.titleLabel?.font = UIFont(name: "GillSans-UltraBold", size: 10)
        hostButton.addTarget(self, action: #selector(hostButtonPress), for: .touchUpInside)
        
        joinButton = PressableButton(frame: .zero)
        buttonContainer.addSubview(joinButton)
        joinButton.snp.makeConstraints { (make) in
            make.height.equalTo(playButton.snp.height)
            make.width.equalTo(playButton.snp.width)
            make.centerX.equalTo(playButton.snp.centerX)
            make.top.equalTo(hostButton.snp.bottom).offset(16)
        }
        joinButton.setTitle("JOIN", for: .normal)
        joinButton.titleLabel?.font = UIFont(name: "GillSans-UltraBold", size: 10)
        joinButton.addTarget(self, action: #selector(joinButtonPress), for: .touchUpInside)
    }
    
    override func overrideTraitCollection(forChildViewController childViewController: UIViewController) -> UITraitCollection? {
        if view.bounds.width < view.bounds.height {
            return UITraitCollection(traitsFrom: [UITraitCollection(horizontalSizeClass: .compact), UITraitCollection(verticalSizeClass: .regular)])
        } else {
            return UITraitCollection(traitsFrom: [UITraitCollection(horizontalSizeClass: .regular), UITraitCollection(verticalSizeClass: .compact)])
        }
    }
    
    override func viewDidLayoutSubviews() {
        playButton.titleLabel?.updateFontSizeToFit(size: playButton.bounds.size)
        helpButton.titleLabel?.updateFontSizeToFit(size: helpButton.bounds.size)
        hostButton.titleLabel?.updateFontSizeToFit(size: hostButton.bounds.size)
        joinButton.titleLabel?.updateFontSizeToFit(size: joinButton.bounds.size)
        
        playButton.updateTitleOffsets()
        helpButton.updateTitleOffsets()
        hostButton.updateTitleOffsets()
        joinButton.updateTitleOffsets()
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if traitCollection.horizontalSizeClass == .regular && traitCollection.verticalSizeClass == .regular {
            return .all
        } else {
            return .landscape
        }
    }
    
    @objc func playButtonPress() {
        if !multipeerTransitioning {
            performSegue(withIdentifier: "showGame", sender: self)
        }
    }
    
    @objc func hostButtonPress() {
        if !multipeerTransitioning {
            performSegue(withIdentifier: "showHost", sender: self)
        }
    }
    
    @objc func joinButtonPress() {
        if !multipeerTransitioning {
            performSegue(withIdentifier: "showJoin", sender: self)
        }
    }
    
    @IBAction func unwindFromGame(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func unwindFromHost(segue: UIStoryboardSegue) {
        if let vc = segue.source as? HostViewController {
            multipeerTransitioning = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                [weak self] in
                guard let `self` = self else { return }
                self.performSegue(withIdentifier: "showMultipeerGame", sender: (vc.session, true))
                self.multipeerTransitioning = false
            }
        }
    }
    
    @IBAction func unwindFromJoin(segue: UIStoryboardSegue) {
        if let vc = segue.source as? JoinViewController {
            multipeerTransitioning = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                [weak self] in
                guard let `self` = self else { return }
                self.performSegue(withIdentifier: "showMultipeerGame", sender: (vc.session, false))
                self.multipeerTransitioning = false
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? MultipeerGameViewController, let (session, isHost) = (sender as? (MCSession, Bool)) {
            vc.session = session
            vc.isHost = isHost
        }
    }
}
