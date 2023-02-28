//
//  ContentView.swift
//  BetterRest
//
//  Created by Rob Ranf on 2/19/23.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var sleepAmount = 8.0
    @State private var wakeUp = defaultWakeTime
    @State private var coffeeAmount = 1
//    @State private var alertTitle = ""
//    @State private var alterMessage = ""
//    @State private var showingAlert = false
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    var sleepResults: String {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            let prediction = try model.prediction(wake: Double(hour + minute),
                                                  estimatedSleep: sleepAmount,
                                                  coffee: Double(coffeeAmount))
            let sleepTime = wakeUp - prediction.actualSleep
            return "Your ideal bedtime is " + sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            return "Error: Sorry, there was a problem calculating your bedtime."
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    DatePicker("Please enter a time", selection: $wakeUp,
                               displayedComponents: .hourAndMinute)
                    .labelsHidden()
                } header: {
                    Text("When do you want to wake up?")
                        .font(.headline)
                }
                
                Section {
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount,
                            in: 4...12, step: 0.25)
                    
                } header: { Text("Desired amount of sleep")
                        .font(.headline)
                }
                
                Section {
                //Stepper(coffeeAmount == 1 ? "1 cup" : "\(coffeeAmount) cups",
                //value: $coffeeAmount, in: 1...20)
                    Picker("Cups", selection: $coffeeAmount) {
                        ForEach(1..<21) { n in
                            Text("\(n)")
                        }
                    }
                } header: {
                    Text("Daily coffee intake")
                        .font(.headline)
                }
                
                Text(sleepResults)
                    .font(.title3)
            }
            .navigationTitle("BetterRest")
//            .toolbar {
//                Button("Calculate", action: calculateBedtime)
//            }
//            .alert(alertTitle, isPresented: $showingAlert) {
//                Button("OK") {}
//            } message: {
//                Text(alterMessage)
//            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
