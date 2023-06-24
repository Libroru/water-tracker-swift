//
//  ContentView.swift
//  Water Tracker watchOS Watch App
//
//  Created by Alexander Klann on 23.06.23.
//

import SwiftUI

enum UnitType: String, CaseIterable, Identifiable {
    var id: Self {
        return self
    }
    
    static var allCases: [UnitType] {
        return [.Liters, .Ounces]
    }
    
    case Liters = "Liters"
    case Ounces = "Ounces"
}

struct ContentView: View {
    @AppStorage("CURRENT_LEVEL_KEY", store: UserDefaults(suiteName: "group.me.libroru.watertracker")) var waterLevel: Double = 0
    @AppStorage("AMOUNT_TO_ADD_KEY", store: UserDefaults(suiteName: "group.me.libroru.watertracker")) var amountToAdd: String = ""
    @AppStorage("GOAL_KEY", store: UserDefaults(suiteName: "group.me.libroru.watertracker")) var dailyGoal: String = "3L"
    @AppStorage("SETTINGS_UNITS_KEY", store: UserDefaults(suiteName: "group.me.libroru.watertracker")) var unitPickerSelection: UnitType = UnitType.Liters
    @AppStorage("LAST_USED_DATE_KEY", store: UserDefaults(suiteName: "group.me.libroru.watertracker")) var lastUsedDate: String = String(NSDate().timeIntervalSince1970)
    
    @AppStorage("FIRST_BUTTON_KEY", store: UserDefaults(suiteName: "group.me.libroru.watertracker")) var firstPresetButton: String = "150ml"
    @AppStorage("SECOND_BUTTON_KEY", store: UserDefaults(suiteName: "group.me.libroru.watertracker")) var secondPresetButton: String = "250ml"
    @AppStorage("THIRD_BUTTON_KEY", store: UserDefaults(suiteName: "group.me.libroru.watertracker")) var thirdPresetButton: String = "500ml"

    var body: some View {
        VStack {
            CircularProgressBar(progress: {
                (waterLevel / stripOfUnit(input: dailyGoal))
            }(), strokeWidth: 5, progressColor: Color.blue, backdropColor: Color.cyan)
            .frame(width: 50)
            Spacer()
                .frame(height: 50)
            VStack{
                HStack {
                    Button {
                        if (amountToAdd != "") {
                            waterLevel -= stripOfUnit(input: amountToAdd)
                        }
                    } label: {
                        Text("-")
                            .padding(2)
                            .frame(width: 15)
                    }
                    .buttonStyle(.borderedProminent)
                    .font(.system(size: 25))
                    
                    TextField(text: $amountToAdd,
                              prompt: Text(unitPickerSelection == UnitType.Liters ? "500ml" : "16oz")) {
                        Text("Amount")
                    }
                    .frame(width: 75, height: 25)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 12))
                    
                    Button {
                        if (amountToAdd != "") {
                            waterLevel += stripOfUnit(input: amountToAdd)
                        }
                    } label: {
                        Text("+")
                            .padding(2)
                            .frame(width: 15)
                    }
                    .buttonStyle(.borderedProminent)
                    .font(.system(size: 25))
                }
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
/// Credits: BingAI for refactoring this code to perfection
func formatString(input: Double, selection: UnitType) -> String {
    let conversionFactors: [UnitType: (threshold: Double, factor: Double, unit: String)] = [
        .Liters: (1000, 1000, "L"),
        .Ounces: (1, 29.574, "oz")
    ]
    
    if let conversion = conversionFactors[selection] {
        if selection == .Ounces || input >= conversion.threshold {
            return String(format: "%3.1f", input / conversion.factor) + conversion.unit
        }
    }
    
    return String(format: "%3.0f", input) + "ml"
}


/// Does the opposite to `formatString()`, strips away all units and returns the clean Double
/// Credits: BingAI for refactoring this code to perfection
func stripOfUnit(input: String) -> Double {
    let input = input.replacingOccurrences(of: ",", with: ".")
    @AppStorage("SETTINGS_UNITS_KEY") var unitPickerSelection: UnitType = UnitType.Liters
    
    let conversionFactors: [String: Double] = [
        "ml": 1,
        "L": 1000,
        "oz": 29.574,
        "": unitPickerSelection == .Liters ? 1 : 29.574
    ]
    
    for (unit, factor) in conversionFactors {
        if input.hasSuffix(unit) {
            let valueString = input.replacingOccurrences(of: unit, with: "")
            if let value = Double(valueString) {
                return value * factor
            }
        }
    }
        
    return 0
}
