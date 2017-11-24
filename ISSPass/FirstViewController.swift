//
//  FirstViewController.swift
//  ISSPass
//
//  Created by TAPAN BISWAS on 11/22/17.
//  Copyright © 2017 TAPAN BISWAS. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {

    @IBOutlet weak var btnLaunchDemo: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        btnLaunchDemo.layer.cornerRadius = 20.0
        btnLaunchDemo.layer.borderColor = UIColor.blue.cgColor
        btnLaunchDemo.layer.borderWidth = 2.0
        btnLaunchDemo.layer.shadowOffset = CGSize(width: 5, height: 5)
        btnLaunchDemo.layer.shadowOpacity = 0.6
    }

}
