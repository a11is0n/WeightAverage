//
//  HealthManager.swift
//  WeightAverage
//
//  Created by Allison Ko on 12/27/17.
//  Copyright © 2017 Allison Ko. All rights reserved.
//

import HealthKit

class HealthManager {
    // MARK: Properties
    
    // MARK: Functions
    
    public func isHealthDataAvailable() -> Bool {
        return HKHealthStore.isHealthDataAvailable()
    }
}
