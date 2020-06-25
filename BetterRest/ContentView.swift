//
//  ContentView.swift
//  BetterRest
//
//  Created by Chris Eadie on 24/06/2020.
//  Copyright © 2020 ChrisEadieDesigns. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    // MARK: State variables
    
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showCalculationAlert = false
    
    // MARK: Computed variables
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }
    
    
    // MARK: View body
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("When do you want to wake up?")
                            .font(.headline)
                        DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .datePickerStyle(WheelDatePickerStyle())
                    }
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Desired amount of sleep")
                            .font(.headline)
                        Stepper(value: $sleepAmount, in: 4...12, step: 0.25) {
                            Text("\(sleepAmount, specifier: "%g") hours")
                        }
                    }
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Daily coffee intake")
                            .font(.headline)
                        Stepper(value: $coffeeAmount, in: 1...20) {
                            Text("\(coffeeAmount) \(coffeeAmount == 1 ? "cup" : "cups")")
                        }
                    }
                }
                .navigationBarTitle("BetterRest")
                .navigationBarItems(trailing:
                    Button(action: calculateBedtime) {
                        Text("Calculate")
                    }
                )
                .alert(isPresented: $showCalculationAlert) {
                    Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
                Text("\(alertTitle) \(alertMessage)")
                    .font(.caption)
                    .padding(10)
            }
        }
    }
    
    
    // MARK: Methods
    
    private func calculateBedtime() {
        let model = SleepCalculator()
        let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
        
        // Get current hour in seconds
        let hour = (components.hour ?? 0) * 60 * 60
        // Get current minute in seconds
        let minute = (components.minute ?? 0) * 60
        
        do {
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            let sleepTime = wakeUp - prediction.actualSleep
            
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            
            alertTitle = "Your ideal bedtime is"
            alertMessage = formatter.string(from: sleepTime)
            showCalculationAlert = true
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime."
        }
        
        showCalculationAlert = true
        
    }
    
}

// MARK: -
// MARK: Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
