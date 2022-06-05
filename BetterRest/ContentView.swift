//
//  ContentView.swift
//  BetterRest
//
//  Created by אדיר נוימן on 04/06/2022.
//

import CoreML
import SwiftUI

struct ContentView: View {
    
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    static var defaultWakeTime: Date {
        
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
        
    }
    
    
    var body: some View {
        
        NavigationView {
            Form {
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("When do you want to wake up?")
                        .font(.headline)
                        .padding()
                    
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        
                }
                .padding()
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("Desired amount of sleep")
                        .font(.headline)
                    
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                .padding()
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    Text("Daily coffe intake")
                        .font(.headline)
                    
                    Stepper(coffeAmount == 1 ? "1 cup" : "\(coffeAmount) cups", value: $coffeAmount, in: 1...20)
                }
                .padding()
                
            }
            
            .navigationTitle("BetterRest")
            .toolbar {
                
                Button("Calculate", action: calculateBedTime)
            }
            .alert(alertTitle, isPresented: $showingAlert) {
                
                Button("OK") {}
            } message: {
                
                Text(alertMessage)
            }
        }
            
    }
    
    func calculateBedTime() {
        
        do {
            let config = MLModelConfiguration()
            // Output a prediction of how many hour of sleep you need based on the config
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour,.minute], from: wakeUp )
            // Multiply by 60 and again by 60, to get the number of seconds
            let hour = (components.hour ?? 0) * 60 * 60
            // Multiply by 60 to get the number of seconds
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            alertTitle = "Your ideal bedtime is..."
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
            
            
        } catch {
            
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime 😩"
        }
        
        showingAlert = true
        
    }
  
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
