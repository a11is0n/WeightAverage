//
//  HealthManager.swift
//  WeightAverage
//
//  Created by Allison Ko on 12/27/17.
//  Copyright © 2017 Allison Ko. All rights reserved.
//

import HealthKit

class HealthManager {
    // MARK: Private Constants
    
    private struct HealthManagerConstants {
        static let selectedTimeRangeDaysKey = "selectedTimeRangeDays"
        static let defaultTimeRangeDays = 30
        static let timeRangePickerDays = [1, 2, 3, 4, 5, 6, 7, 14, 21, 30, 60, 90, 120, 180, 360, 720, 1080]
        static let timeRangePickerDayLabel = "Days"
    }

    // MARK: Public Constants
    
    public struct HealthManagerNotificationKeys {
        static let dataNotFound = "dataNotFound"
        static let weightUnitAvailable = "weightUnitAvailable"
        static let weightAverageAvailable = "weightAverageAvailable"
    }
    
    // MARK: Private Properties
    
    private let healthStore = HKHealthStore()
    
    // MARK: Public Properties
    
    private (set) public var weightUnit = HKUnit.pound()
    private (set) public var averageWeight = 0.0
    
    // MARK: Private Functions
    
    private func requestPermissions() {
        let readDataTypes : Set = [HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!]
        
        healthStore.requestAuthorization(toShare: nil, read: readDataTypes, completion: { (success, error) in
            if success {
                self.fetchData()
            } else {
                self.sendDataNotFoundNotification()
            }
        })
        
    }
    
    private func sendDataNotFoundNotification() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: HealthManagerNotificationKeys.dataNotFound),
                                        object: self)
    }
    
    private func fetchData() {
        fetchWeightUnit()
    }
    
    private func fetchWeightUnit() {
        let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!
        healthStore.preferredUnits(for: [quantityType]) { (unit, error) in
            if let weightUnit = unit[quantityType] {
                DispatchQueue.main.async(execute: {
                    self.weightUnit = weightUnit
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: HealthManagerNotificationKeys.weightUnitAvailable),
                                                    object: self)
                    
                    self.fetchWeightData()
                })
            } else {
                DispatchQueue.main.async(execute: {
                    self.sendDataNotFoundNotification()
                })
            }
        }
    }
    
    private func fetchWeightData() {
        let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!
        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -self.timeRangeDays(), to: endDate)
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate,
                                                    end: endDate,
                                                    options: .strictStartDate)
        let averageWeightQuery = HKStatisticsQuery(quantityType: quantityType,
                                                   quantitySamplePredicate: predicate,
                                                   options: .discreteAverage) { (query, result, error) in
                                                    if let averageQuantity = result?.averageQuantity() {
                                                        DispatchQueue.main.async(execute: {
                                                            self.averageWeight = averageQuantity.doubleValue(for: self.weightUnit)
                                                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: HealthManagerNotificationKeys.weightAverageAvailable),
                                                                                            object: self)
                                                        })
                                                    } else {
                                                        DispatchQueue.main.async(execute: {
                                                            self.sendDataNotFoundNotification()
                                                        })
                                                    }
        }
        
        healthStore.execute(averageWeightQuery)
    }
    
    // MARK: Public Functions
    
    public func isHealthDataAvailable() -> Bool {
        return HKHealthStore.isHealthDataAvailable()
    }
    
    public func handleBecomeActive() {
        requestPermissions()
    }
    
    public func timeRangeDays() -> Int {
        var timeRangeDays = UserDefaults.standard.integer(forKey: HealthManagerConstants.selectedTimeRangeDaysKey)
        if timeRangeDays <= 0 {
            timeRangeDays = HealthManagerConstants.defaultTimeRangeDays
        }
        
        return timeRangeDays
    }
    
    public func timeRangePickerComponentCount() -> Int {
        return 2
    }
    
    public func timeRangePickerRowsInComponent(component: Int) -> Int {
        if (component == 0) {
            return HealthManagerConstants.timeRangePickerDays.count
        } else {
            return 1
        }
    }
    
    public func textForComponentRow(component: Int, row: Int) -> String {
        if (component == 0) {
            return String(HealthManagerConstants.timeRangePickerDays[row])
        } else {
            return HealthManagerConstants.timeRangePickerDayLabel
        }
    }
}
