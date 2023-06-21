//
//  ContentView.swift
//  Water Tracker IOS
//
//  Created by Alexander Klann on 17.06.23.
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
    @AppStorage("CURRENT_LEVEL_KEY") var waterLevel: Double = 0
    @AppStorage("AMOUNT_TO_ADD_KEY") var amountToAdd: String = ""
    @AppStorage("GOAL_KEY") var dailyGoal: String = "3L"
    @AppStorage("SETTINGS_UNITS_KEY") var unitPickerSelection: UnitType = UnitType.Liters
    @AppStorage("LAST_USED_DATE_KEY") var lastUsedDate: String = String(NSDate().timeIntervalSince1970)
    
    @AppStorage("FIRST_BUTTON_KEY") var firstPresetButton: String = "150ml"
    @AppStorage("SECOND_BUTTON_KEY") var secondPresetButton: String = "250ml"
    @AppStorage("THIRD_BUTTON_KEY") var thirdPresetButton: String = "500ml"

    @State private var showWarningBox: Bool = false
    
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("Water Tracker")
                        .font(.system(size: 35, weight: .bold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(18)
                        .fixedSize(horizontal: true, vertical: true)
                    NavigationLink {
                        VStack {
                            HStack {
                                Text("Settings")
                                    .font(.system(size: 35, weight: .bold))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(18)
                                Spacer()
                            }
                            Form {
                                Section(header: Text("General Settings")) {
                                    Picker("Unit", selection: $unitPickerSelection) {
                                        ForEach(UnitType.allCases) { option in
                                            Text(String(describing: option))
                                        }
                                    }
                                    TextField("Daily Goal", text: $dailyGoal)
                                    TextField("Preset Button 1", text: $firstPresetButton)
                                    TextField("Preset Button 2", text: $secondPresetButton)
                                    TextField("Preset Button 3", text: $thirdPresetButton)
                                    Button("Reset Today's Progress", role: .destructive) {
                                        self.showWarningBox = true
                                    }
                                }
                            }
                        }
                        .alert("Are you sure?", isPresented: $showWarningBox) {
                            Button("Delete Data", role: .destructive) {
                                waterLevel = 0
                            }
                            
                            Button("Cancel", role: .cancel) {
                                self.showWarningBox = false
                            }
                        }
                    } label: {
                        HStack {
                            Spacer()
                            Image(systemName: "gear")
                                .resizable()
                                .frame(width: 35, height: 35)
                                .padding(.trailing, 12)
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(.leading, 18)
                }
                
                Spacer()
                
                ZStack {
                    CircularProgressBar(progress: {
                        (waterLevel / stripOfUnit(input: dailyGoal))
                    }(), strokeWidth: 20, progressColor: Color.blue, backdropColor: Color.cyan)
                        .frame(width: 200)
                    Text(formatString(input: waterLevel, selection: unitPickerSelection))
                        .font(.system(size: 35))
                }
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
                                .padding(5)
                                .frame(width: 30)
                        }
                        .buttonStyle(BorderedProminentButtonStyle())
                        .font(.system(size: 25))
                        
                        TextField(text: $amountToAdd,
                                  prompt: Text(unitPickerSelection == UnitType.Liters ? "500ml" : "16oz")) {
                            Text("Amount")
                        }
                        .frame(width: 125, height: 45)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 25))
                        
                        Button {
                            if (amountToAdd != "") {
                                waterLevel += stripOfUnit(input: amountToAdd)
                            }
                        } label: {
                            Text("+")
                                .padding(5)
                                .frame(width: 30)
                        }
                        .buttonStyle(BorderedProminentButtonStyle())
                        .font(.system(size: 25))
                    }
                    HStack {
                        Button("\(firstPresetButton)") {
                            waterLevel += stripOfUnit(input: firstPresetButton)
                        }
                        .buttonStyle(.borderedProminent)
                        .frame(width: 81)
                        
                        Button("\(secondPresetButton)") {
                            waterLevel += stripOfUnit(input: secondPresetButton)
                        }
                        .buttonStyle(.borderedProminent)
                        .frame(width: 81)
                        
                        Button("\(thirdPresetButton)") {
                            waterLevel += stripOfUnit(input: thirdPresetButton)
                        }
                        .buttonStyle(.borderedProminent)
                        .frame(width: 81)
                    }
                }
                Spacer()
            }
            .onAppear {
                let formatter = DateFormatter()
                    formatter.dateFormat = "dd"
                
                let earlierDay = formatter.string(from: Date(timeIntervalSince1970: Double(lastUsedDate)!))
                let today = formatter.string(from: Date(timeIntervalSince1970: Double(NSDate().timeIntervalSince1970)))
                
                if (earlierDay != today) {
                    waterLevel = 0
                }
                lastUsedDate = String(NSDate().timeIntervalSince1970)
            }
        }
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
