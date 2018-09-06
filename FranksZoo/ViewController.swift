//
//  ViewController.swift
//  FranksZoo
//
//  Created by Mulang Su on 2018/09/01.
//  Copyright © 2018年 Mulang Su. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var opponentHand1: OpponentsHandView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
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
    
}

