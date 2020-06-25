//
//  ContentView.swift
//  BetterRest
//
//  Created by Chris Eadie on 24/06/2020.
//  Copyright © 2020 ChrisEadieDesigns. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    // MARK: -
    // MARK: State variables
    @State private var wakeUp = Date()
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showCalculationAlert = false
    
    // MARK: -
    // MARK: View body
    
    var body: some View {
        NavigationView {
            VStack {
                Text("When do you want to wake up?")
                    .font(.headline)
                DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                Text("Desired amount of sleep")
                Stepper(value: $sleepAmount, in: 4...12, step: 0.25) {
                    Text("\(sleepAmount, specifier: "%g") hours")
                }
                Text("Daily coffee intake")
                Stepper(value: $coffeeAmount, in: 1...20) {
                    Text("\(coffeeAmount) \(coffeeAmount == 1 ? "cup" : "cups")")
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
        }
    }
    
    // MARK: -
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
            
            alertTitle = "Your ideal bedtime is..."
            alertMessage = formatter.string(from: sleepTime)
            showCalculationAlert = true
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime."
            showCalculationAlert = true
        }
    }
    
}

// MARK: -
// MARK: Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
