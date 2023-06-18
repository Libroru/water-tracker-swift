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
    @State public var toAdd: String = ""
    @State public var waterLevel: Double = 0
    @State public var currentWaterLevel: String = ""
    @State public var dailyGoal: Double = 3000

    @State private var unitPickerSelection: UnitType = UnitType.Liters
    
    @AppStorage("CURRENT_LEVEL_KEY") var savedCurrentLevel: Double = 0
    @AppStorage("AMOUNT_TO_ADD_KEY") var savedAmountToAdd: String = ""
    @AppStorage("GOAL_KEY") var savedGoal: Double = 0
    
    @AppStorage("SETTINGS_UNITS_KEY") var savedUnitType: UnitType = UnitType.Liters
    
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
                                    Picker("Unit", selection: $savedUnitType) {
                                        ForEach(UnitType.allCases) { option in
                                            Text(String(describing: option))
                                        }
                                    }
                                }
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
                        (waterLevel / dailyGoal)
                    }(), strokeWidth: 20, progressColor: Color.blue, backdropColor: Color.cyan)
                        .frame(width: 200)
                        .onAppear {
                            if (savedGoal != 0) {
                                dailyGoal = savedGoal
                            }
                        }
                    Text(currentWaterLevel)
                        .font(.system(size: 35))
                        .onAppear {
                            //unitPickerSelection = savedUnitType
                            
                            currentWaterLevel = format_string(input: savedCurrentLevel, selection: unitPickerSelection)
                            waterLevel = savedCurrentLevel
                        }
                        .onChange(of: scenePhase) { phase in
                            if phase == .inactive || phase == .background {
                                savedCurrentLevel = waterLevel
                                savedUnitType = unitPickerSelection
                            }
                        }
                }
                Spacer()
                    .frame(height: 50)
                HStack {
                    Button {
                        waterLevel -= strip_of_unit(input: toAdd, selection: unitPickerSelection)
                        
                        currentWaterLevel = format_string(input: waterLevel, selection: unitPickerSelection)
                    } label: {
                        Text("-")
                            .padding(5)
                            .frame(width: 30)
                    }
                    .buttonStyle(BorderedProminentButtonStyle())
                    .font(.system(size: 25))
                    
                    TextField(text: $toAdd,
                              prompt: Text(unitPickerSelection == UnitType.Liters ? "500ml" : "16oz")) {
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
                    .onChange(of: scenePhase) { phase in
                        if phase == .inactive || phase == .background {
                            savedAmountToAdd = toAdd
                        }
                    }
                    
                    Button {
                        waterLevel += strip_of_unit(input: toAdd, selection: unitPickerSelection)
                        
                        currentWaterLevel = format_string(input: waterLevel, selection: unitPickerSelection)
                    } label: {
                        Text("+")
                            .padding(5)
                            .frame(width: 30)
                    }
                    .buttonStyle(BorderedProminentButtonStyle())
                    .font(.system(size: 25))
                }
                Spacer()
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
func format_string(input: Double, selection: UnitType) -> String {
    if (selection == UnitType.Liters) {
        if ((input / 1000) >= 1.0) {
            return String(input / 1000) + "L"
        } else {
            return String(format: "%3.0f", input) + "ml"
        }
    } else {
        return String(format: "%3.1f", input / 29.574) + "oz"
    }
}

/// Does the opposite to `format_string()`, strips away all units and returns the clean Double
func strip_of_unit(input: String, selection: UnitType) -> Double {
    if (selection == UnitType.Liters) {
        if (input.hasSuffix("ml") == true) {
            return Double(input.replacingOccurrences(of: "ml", with: ""))!
        } else {
            return Double(input.replacingOccurrences(of: "L", with: ""))!
        }
    } else {
        if (input.hasSuffix("ml") == true) {
            return Double(input.replacingOccurrences(of: "ml", with: ""))!
        } else {
            return Double(Double(input.replacingOccurrences(of: "oz", with: ""))! * 29.574)
        }
    }
}
