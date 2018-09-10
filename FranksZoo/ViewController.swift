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
    @IBOutlet var opponentHand2: OpponentsHandView!
    @IBOutlet var opponentHand3: OpponentsHandView!
    @IBOutlet var handCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        opponentHand1.orientation = .right
        opponentHand2.orientation = .down
        opponentHand3.orientation = .left
        handCollectionView.allowsMultipleSelection = true
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
        DispatchQueue.main.async {
            [unowned self] in
            self.opponentHand1.setNeedsDisplay()
            self.opponentHand2.setNeedsDisplay()
            self.opponentHand3.setNeedsDisplay()
            self.handCollectionView.reloadData()
        }
    }
}

