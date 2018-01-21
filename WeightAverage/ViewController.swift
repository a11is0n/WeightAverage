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
    @IBOutlet weak var dataFoundContainer: UIView!
    @IBOutlet weak var dataNotFoundContainer: UIView!
    @IBOutlet weak var averageWeightLabel : UILabel!
    @IBOutlet weak var timeRangeDaysLabel: UILabel!
    
    let defaultTimeRangeDays = 30
    let healthManager = HealthManager()
    
    // MARK: Public Functions

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUp()
    }
    
    // MARK: Private Functions
    
    deinit {
        removeObservers()
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: HealthManager.HealthManagerNotificationKeys.dataNotFound),
                                               object: nil,
                                               queue: nil,
                                               using: handleDataNotFound)
        NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: HealthManager.HealthManagerNotificationKeys.weightAverageAvailable),
                                               object: nil,
                                               queue: nil,
                                               using: handleWeightAverageAvailable)
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setUp() {
        healthKitAvailableContainer.isHidden = !healthManager.isHealthDataAvailable()
        healthKitUnavailableContainer.isHidden = healthManager.isHealthDataAvailable()
        
        if !healthManager.isHealthDataAvailable() {
            return
        }
        
        addObservers()
        
        healthManager.requestPermissions()
        
        timeRangeDaysLabel.text = String(healthManager.timeRangeDays())
    }
    
    private func toggleDataFoundContainers(found: Bool) {
        dataFoundContainer.isHidden = !found;
        dataNotFoundContainer.isHidden = found;
    }
    
    private func handleDataNotFound(notification: Notification) {
        toggleDataFoundContainers(found: false)
    }
    
    private func handleWeightAverageAvailable(notification: Notification) {
        toggleDataFoundContainers(found: true)

        var averageWeight = 0.0
        if notification.userInfo?["averageWeight"] != nil {
            averageWeight = notification.userInfo?["averageWeight"] as! Double
        }
        
        averageWeightLabel.text = String(format: "%.2f", averageWeight)
    }
}
