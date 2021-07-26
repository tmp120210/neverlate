//
//  SettingsScreen.swift
//  Neverlate
//
//  Created by Александр Северюхин on 19.07.2021.
//

import SwiftUI
import ServiceManagement

struct SettingsScreen: View {
    @Binding var currentPage: String
    @AppStorage("launchAtLogin") var launchAtLogin = false
    var body : some View {
        VStack() {
            HStack(alignment: .center, spacing: 16.0){
                Button(action: {
                    self.currentPage = "meeting"
                })
                {
                    Image(systemName: "chevron.left")
                        .resizable(resizingMode: .stretch)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 15, height: 26)
                        .foregroundColor(.primary)
                    
                }
                .buttonStyle(PlainButtonStyle())
                Text("Settings")
                    .font(.system(size: 32, weight: .bold))
            }
            .padding(.leading, 0.0)
            .frame(minWidth: 0, idealWidth: .infinity, maxWidth: .infinity,alignment: .leading)
            VStack{
                Toggle(isOn: $launchAtLogin){
                    Text("Launch at System startup")
                        .font(.system(size: 18, weight: .regular))
                        .frame(minWidth: 0, idealWidth: .infinity, maxWidth: .infinity,alignment: .leading)
                }
                    .onChange(of: self.launchAtLogin, perform: { value in
                        SMLoginItemSetEnabled("com.redrazzr.AutoLauncher" as CFString, value)
                        print("AutoLaunch set to \(value)")
                })
                    .toggleStyle(SwitchToggleStyle(tint: .primary))
                Spacer()
            }
            Button(action: {
                NSApplication.shared.terminate(self)
            })
            {
                Text("Quit the App")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(.red)
                
            }
            .buttonStyle(PlainButtonStyle())
        }
        .frame(width: 320, height: 540)
        .padding(.horizontal, 16.0)
        .padding(.vertical, 32.0)
        
    }
}

struct SettingsScreen_Previews: PreviewProvider {
    static var previews: some View {
        SettingsScreen(currentPage: .constant("settings"))
    }
}

