//
//  HealthManager.swift
//  WeightAverage
//
//  Created by Allison Ko on 12/27/17.
//  Copyright © 2017 Allison Ko. All rights reserved.
//

import HealthKit

class HealthManager {
    // MARK: Constants
    struct HealthManagerConstants {
        static let selectedTimeRangeDaysKey = "selectedTimeRangeDays"
        static let defaultTimeRangeDays = 30
    }
    
    // MARK: Properties
    
    // MARK: Functions
    
    public func isHealthDataAvailable() -> Bool {
        return HKHealthStore.isHealthDataAvailable()
    }
    
    public func timeRangeDays() -> Int {
        var timeRangeDays = UserDefaults.standard.integer(forKey: HealthManagerConstants.selectedTimeRangeDaysKey)
        if timeRangeDays <= 0 {
            timeRangeDays = HealthManagerConstants.defaultTimeRangeDays
        }
        
        return timeRangeDays
    }
}
