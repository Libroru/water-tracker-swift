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
                        (waterLevel / strip_of_unit(input: dailyGoal))
                    }(), strokeWidth: 20, progressColor: Color.blue, backdropColor: Color.cyan)
                        .frame(width: 200)
                    Text(format_string(input: waterLevel, selection: unitPickerSelection))
                        .font(.system(size: 35))
                }
                Spacer()
                    .frame(height: 50)
                HStack {
                    Button {
                        if (amountToAdd != "") {
                            waterLevel -= strip_of_unit(input: amountToAdd)
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
                            waterLevel += strip_of_unit(input: amountToAdd)
                        }
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
func format_string(input: Double, selection: UnitType) -> String {
    if (selection == UnitType.Liters) {
        if ((input / 1000) >= 1.0) {
            return String(format: "%3.1f", input / 1000) + "L"
        } else {
            return String(format: "%3.0f", input) + "ml"
        }
    } else {
        return String(format: "%3.1f", input / 29.574) + "oz"
    }
}

/// Does the opposite to `format_string()`, strips away all units and returns the clean Double
func strip_of_unit(input: String) -> Double {
    if (input.hasSuffix("ml")) {
        return Double(input.replacingOccurrences(of: "ml", with: "").replacingOccurrences(of: ",", with: "."))!
    } else if (input.hasSuffix("L")) {
        return Double(Double(input.replacingOccurrences(of: "L", with: "").replacingOccurrences(of: ",", with: "."))! * 1000)
    } else if (input.hasSuffix("oz")) {
        return Double(Double(input.replacingOccurrences(of: "oz", with: "").replacingOccurrences(of: ",", with: "."))! * 29.574)
    } else {
        return 3000.0
    }
}
