//
//  ContentView.swift
//  Water Tracker IOS
//
//  Created by Alexander Klann on 17.06.23.
//

import SwiftUI

struct ContentView: View {
    @State public var toAdd: String = "500ml"
    @State public var waterLevel: Double = 0
    @State public var currentWaterLevel: String = ""
    @State public var dailyGoal: Double = 3.0
    
    @AppStorage("NUMBER_KEY") var savedCurrentLevel: Double = 0
    @AppStorage("STRING_KEY") var savedAmountToAdd: String = ""
    @AppStorage("NUMBER_KEY") var savedGoal: Double = 0
    
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        VStack {
            Text("Water Tracker")
                .font(.system(size: 40, weight: Font.Weight.bold))
            Spacer()
                .frame(height: 75)
            ZStack {
                CircularProgressBar(progress: {
                    (waterLevel / dailyGoal)
                }(), strokeWidth: 20, progressColor: Color.blue, backdropColor: Color.cyan)
                    .frame(width: 200)
                    // TO DO:
                    // dailyGoal is 500ml for some reason
                    .onAppear {
                        if (savedGoal != 0) {
                            dailyGoal = savedGoal
                        }
                    }
                Text(currentWaterLevel)
                    .font(.system(size: 35))
                    .onAppear {
                        currentWaterLevel = format_string(input: savedCurrentLevel)
                        waterLevel = savedCurrentLevel
                    }
                    .onChange(of: scenePhase) { phase in
                        if phase == .inactive || phase == .background {
                            savedCurrentLevel = waterLevel
                        }
                    }
            }
            Spacer()
                .frame(height: 50)
            HStack {
                Button {
                    waterLevel -= strip_of_unit(input: toAdd)
                    
                    currentWaterLevel = format_string(input: waterLevel)
                } label: {
                    Text("-")
                        .padding(5)
                        .frame(width: 30)
                }
                .buttonStyle(BorderedProminentButtonStyle())
                .font(.system(size: 25))
                
                TextField(text: $toAdd,
                          prompt: Text("500ml")) {
                    Text("Amount")
                }
                .frame(width: 125, height: 45)
                .multilineTextAlignment(.center)
                .font(.system(size: 25))
                .onAppear {
                    if (savedAmountToAdd != "") {
                        toAdd = savedAmountToAdd
                    }
                }
                
                Button {
                    waterLevel += strip_of_unit(input: toAdd)
                    
                    currentWaterLevel = format_string(input: waterLevel)
                } label: {
                    Text("+")
                        .padding(5)
                        .frame(width: 30)
                }
                .buttonStyle(BorderedProminentButtonStyle())
                .font(.system(size: 25))
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

/// Adds units to the `input` variable and returns a string with added units
func format_string(input: Double) -> String {
    if ((input / 1000) >= 1.0) {
        return String(input / 1000) + "L"
    } else {
        return String(format: "%3.0f", input) + "ml"
    }
}

/// Does the opposite to `format_string()`, strips away all units and returns the clean Double
func strip_of_unit(input: String) -> Double {
    if (input.hasSuffix("ml") == true) {
        return Double(input.replacingOccurrences(of: "ml", with: ""))!
    } else {
        return Double(input.replacingOccurrences(of: "L", with: ""))!
    }
}
