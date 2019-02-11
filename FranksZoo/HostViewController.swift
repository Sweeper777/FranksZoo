import UIKit
import RxCocoa
import RxSwift
import MultipeerConnectivity
import SwiftyButton

class HostViewController : UIViewController {
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    
    let disposeBag = DisposeBag()
}
