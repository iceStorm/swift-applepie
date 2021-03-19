//
//  GameFinishedViewController.swift
//  applepie
//
//  Created by Nguyen Anh Tuan on 3/19/21.
//  Copyright © 2021 BVU. All rights reserved.
//

import UIKit

class GameFinishedViewController: UIViewController {
    @IBOutlet weak var btnGoHome: UIButton!
    @IBOutlet weak var imvResult: UIImageView!
    @IBOutlet weak var lbScores: UILabel!
    
    var gainedScores: Int!
    var isGameFinished: Bool!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if (isGameFinished) {
            imvResult.image = UIImage(named: "finished")
        }
        
        lbScores.text = "Your scores: \(gainedScores ?? 0)"
    }
    

    @IBAction func btnGoHomeClicked(_ sender: Any) {
        performSegue(withIdentifier: "GoHome", sender: self)
    }
    
}
