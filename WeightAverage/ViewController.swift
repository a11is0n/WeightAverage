//
//  ViewController.swift
//  WeightAverage
//
//  Created by Allison Ko on 11/18/17.
//  Copyright © 2017 Allison Ko. All rights reserved.
//

import HealthKit
import UIKit

class ViewController: UIViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var healthKitAvailableContainer: UIView!
    @IBOutlet weak var healthKitUnavailableContainer: UIView!
    
    let healthManager = HealthManager()
    
    // MARK: Functions

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUp()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUp() {
        healthKitAvailableContainer.isHidden = !healthManager.isHealthDataAvailable()
        healthKitUnavailableContainer.isHidden = healthManager.isHealthDataAvailable()
    }

}
