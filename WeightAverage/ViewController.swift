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
    @IBOutlet weak var permissionsAvailableContainer: UIView!
    @IBOutlet weak var permissionsUnavailableContainer: UIView!
    @IBOutlet weak var timeRangeDaysLabel: UILabel!
    
    let defaultTimeRangeDays = 30
    let healthManager = HealthManager()
    
    // MARK: Functions

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUp()
    }
    
    func setUp() {
        healthKitAvailableContainer.isHidden = !healthManager.isHealthDataAvailable()
        healthKitUnavailableContainer.isHidden = healthManager.isHealthDataAvailable()
        
        if !healthManager.isHealthDataAvailable() {
            return
        }
        
        healthManager.requestPermissions()
        
        timeRangeDaysLabel.text = String(healthManager.timeRangeDays())
    }

}
