//
//  ContentView.swift
//  HeltSUI
//
//  Created by Mete Alp Kizilcay on 9.10.2020.
//

import SwiftUI
import HealthKit

func fetchHealthData() -> Void {
    let healthStore = HKHealthStore()
    if HKHealthStore.isHealthDataAvailable() {
        //set the data we want
        let readData = Set([HKObjectType.quantityType(forIdentifier: .heartRate)!])
        
        //consent request
        healthStore.requestAuthorization(toShare: [], read: readData) { (success, error) in
                if success {
                    let calendar = NSCalendar.current

                    var anchorComponents = calendar.dateComponents([.day, .month, .year, .weekday], from: NSDate() as Date)

                    let offset = (7 + anchorComponents.weekday! - 2) % 7

                    anchorComponents.day! -= offset
                    anchorComponents.hour = 2
                    guard let anchorDate = Calendar.current.date(from: anchorComponents) else {
                        fatalError("*** unable to create a valid date from the given components ***")
                    }
                    let endDate = Date()
                    guard let startDate = calendar.date(byAdding: .month, value: -1, to: endDate) else {
                        fatalError("*** Unable to calculate the start date ***")
                    }
                    let interval = NSDateComponents()
                    interval.minute = 30
                    //define quantity type
                    guard let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate) else {
                        fatalError("*** Unable to create a step count type ***")
                    }

                    let query = HKStatisticsCollectionQuery(quantityType: quantityType,
                                                        quantitySamplePredicate: nil,
                                                        options: .discreteAverage,
                                                        anchorDate: anchorDate,
                                                        intervalComponents: interval as DateComponents)
                    query.initialResultsHandler = {query, results, error in
                        
                        
                        guard let statsCollection = results else {
                                fatalError("*** An error occurred while calculating the statistics: \(String(describing: error?.localizedDescription)) ***")
                        }
                        
                        
                        statsCollection.enumerateStatistics(from: startDate, to: endDate) { statistics, stop in
                            if let quantity = statistics.averageQuantity() {
                                let value = quantity.doubleValue(for: HKUnit(from: "count/min"))
                                let date = statistics.startDate
                                print("done")
                                print(value)
                                print(date)
                            }
                    }
                }
                healthStore.execute(query)
                    
            } else {
                print("Authorization failed")
            }
        }
    }
}

struct ContentView: View {
    var body: some View {
        Button(action: fetchHealthData, label: {
            Text("Fetch Data")
                .font(.title)
                .bold()
                .foregroundColor(.green)
        })
        .frame(width: 300, height: 150, alignment: .center)
        .background(Color.black)
        .cornerRadius(40)
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

