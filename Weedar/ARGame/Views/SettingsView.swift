//
//  SettingsView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 19.07.2022.
//

import SwiftUI

enum Setting {
    case multiuser
    case peopleOcclusion
    case objectOcclusion
    case lidarDebug
    
    var label: String {
        get {
            switch self {
            case .multiuser:
                return "Multiuser"
            case .peopleOcclusion, .objectOcclusion:
                return "Occlusion"
            case .lidarDebug:
                return "LiDAR"
            }
        }
    }
    
    var systemIconName: String {
        get {
            switch self {
            case .multiuser:
                return "person.2"
            case .peopleOcclusion:
                return "person"
            case .objectOcclusion:
                return "cube.box.fill"
            case .lidarDebug:
                return "light.min"
            }
        }
    }
}

struct SettingsView: View {
    @Binding var showSettings: Bool
    
    var body: some View {
        NavigationView {
            SettingsGrid()
                .navigationBarTitle(Text("Settings"), displayMode: .inline)
                .navigationBarItems(trailing:
                    Button(action: {
                        self.showSettings.toggle()
                    }) {
                        Text("Done").bold()
                    })
        }
    }
}

struct SettingsGrid: View {
    
    @EnvironmentObject var sessionSettings: SessionSettings
    
    private var gridItemLayout = [GridItem(.adaptive(minimum: 100, maximum: 100), spacing: 25)] // Layout grid with square cell (100x100) with horizontal spacing of 25.
    
    var body: some View {

        ScrollView {
            // Vertical grid with vertical spacing of 25.
            LazyVGrid(columns: gridItemLayout, spacing: 25) {
                SettingsToggleButton(setting: .multiuser, isOn: $sessionSettings.isMultiuserEnabled) // NOTE: from Apple Docs - You can get a binding to an observed object, state object, or environment object property by prefixing the name of the object with the dollar sign ($)
                
                SettingsToggleButton(setting: .peopleOcclusion, isOn: $sessionSettings.isPeopleOcclusionEnabled)
                
                SettingsToggleButton(setting: .objectOcclusion, isOn: $sessionSettings.isObjectOcclusionEnabled)
                
                // TODO FIX: only display this button if LiDAR is available
                SettingsToggleButton(setting: .lidarDebug, isOn: $sessionSettings.isLidarDebugEnabled)
            }
        }
        .padding(.top, 35)
    }
}

struct SettingsToggleButton: View {
    let setting: Setting
    @Binding var isOn: Bool
    
    var body: some View {
        Button(action: {
            self.isOn.toggle()
            print("[Session Settings] \(setting): \(self.isOn).")
        }) {
            VStack {
                Image(systemName: setting.systemIconName)
                    .font(.system(size: 35))
                    .foregroundColor(self.isOn ? .green : Color(UIColor.secondaryLabel))
                    .buttonStyle(PlainButtonStyle())
                Text(setting.label)
                    .font(.system(size: 17, weight: .medium, design: .default))
                    .foregroundColor(self.isOn ? Color(UIColor.label) : Color(UIColor.secondaryLabel))
                    .padding(.top, 5)
            }
        }
        .frame(width: 100, height: 100)
        .background(Color(UIColor.secondarySystemFill))
        .cornerRadius(20.0)
    }
}
