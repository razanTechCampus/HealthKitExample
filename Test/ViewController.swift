//
//  ViewController.swift
//  Test
//
//  Created by TechCampus on 1/28/19.
//  Copyright © 2019 TechCampus. All rights reserved.
//

import UIKit
import HealthKit

class ViewController: UIViewController {
    
    //MARK: - IBOutlet
    @IBOutlet weak var lblHeartRate: UILabel!
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if HKHealthStore.isHealthDataAvailable() {
            let healthStore = HKHealthStore()
            let heartRateQuantityType = HKObjectType.quantityType(forIdentifier: .heartRate)!
            let allTypes = Set([heartRateQuantityType])
            healthStore.requestAuthorization(toShare: nil, read: allTypes) { (result, error) in
                if error != nil {
                    //deal with the error
                    return
                }
                guard result else {
                    //deal with the failed request
                    return
                }
                self.fetchLatestHeartRateSample(completion: { (heartRate) in
                    if (heartRate == nil) {
                        self.lblHeartRate.text = "No Heart Rate Recorded"
                    } else {
                        //set label text on main thread
                        DispatchQueue.main.async {
                            self.lblHeartRate.text = "Last heart rate recorded \n \(heartRate!.first!.quantity)" //we have to show only the number of heart rate per minute
                        }
                        print("Health rate call succeeded")
                        print(heartRate!.first!) //all heart rate data is printed "check quantity ...count/min"
                    }
                })
            }
        }
    }
    
    //MARK: - Helpers
    public func fetchLatestHeartRateSample(completion: @escaping (_ samples: [HKQuantitySample]?) -> Void) {
        
        /// Create sample type for the heart rate
        guard let sampleType = HKObjectType
            .quantityType(forIdentifier: .heartRate) else {
                completion(nil)
                return
        }
        
        // Predicate for specifiying start and end dates for the query
        let predicate = HKQuery .predicateForSamples(withStart: Date.distantPast, end: Date(), options: .strictEndDate)
        
        // Set sorting by date.
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate,ascending: false)
        
        // Create the query
        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: [sortDescriptor]) { (_, results, error) in
            guard error == nil else {
                print("Error: \(error!.localizedDescription)")
                return
            }
            completion(results as? [HKQuantitySample])
        }
        
        // Execute the query in the health store
        let healthStore = HKHealthStore()
        healthStore.execute(query)
    }
}

