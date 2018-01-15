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
    struct HealthManagerNotificationKeys {
        static let weightDataAvailable = "weightDataAvailable"
    }
    
    private struct HealthManagerConstants {
        static let selectedTimeRangeDaysKey = "selectedTimeRangeDays"
        static let defaultTimeRangeDays = 30
    }
    
    // MARK: Properties
    
    let healthStore = HKHealthStore()
    var weightUnit = HKUnit.pound() // TODO: get unit from health kit
    var averageWeight = 0.0
    
    // MARK: Public Functions
    
    public func isHealthDataAvailable() -> Bool {
        return HKHealthStore.isHealthDataAvailable()
    }
    
    public func requestPermissions() {
        let readDataTypes : Set = [HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!]
        
        healthStore.requestAuthorization(toShare: nil, read: readDataTypes, completion: { (success, error) in
            if success {
                self.fetchWeightData()
            } else {
                // TODO: change UI if error
                print("Authorization error: \(String(describing: error?.localizedDescription))")
            }
        })
        
    }
    
    public func timeRangeDays() -> Int {
        var timeRangeDays = UserDefaults.standard.integer(forKey: HealthManagerConstants.selectedTimeRangeDaysKey)
        if timeRangeDays <= 0 {
            timeRangeDays = HealthManagerConstants.defaultTimeRangeDays
        }
        
        return timeRangeDays
    }
    
    // MARK: Private functions

    func fetchWeightData() {
        let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!
        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -30, to: endDate)
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate,
                                                    end: endDate,
                                                    options: .strictStartDate)
        let weightQuery = HKSampleQuery.init(sampleType: quantityType,
                                             predicate: predicate,
                                             limit: HKObjectQueryNoLimit,
                                             sortDescriptors: nil,
                                             resultsHandler: { (query, results, error) in
                                                DispatchQueue.main.async(execute: {
                                                    self.handleWeightDataReceived(data: results as! [HKQuantitySample])
                                                })
        })
        healthStore.execute(weightQuery)
    }
    
    func handleWeightDataReceived(data: Array<HKQuantitySample>) {
        var weightSum = 0.0
        for sample in data {
            weightSum += sample.quantity.doubleValue(for: weightUnit)
            
        }
        
        averageWeight = weightSum / Double(data.count)
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: HealthManagerNotificationKeys.weightDataAvailable),
                                        object: averageWeight)
    }
}
