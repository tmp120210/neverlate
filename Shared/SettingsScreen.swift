//
//  SettingsScreen.swift
//  Neverlate
//
//  Created by Александр Северюхин on 19.07.2021.
//

import SwiftUI
import ServiceManagement
import EventKit

struct SettingsScreen: View {
    let eventStore = EKEventStore()
    @Binding var currentPage: String
    @AppStorage("launchAtLogin") var launchAtLogin = false
    @State var accounts : [String: [EKCalendar]] = [:]
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
            ScrollView{
                Toggle(isOn: $launchAtLogin){
                    Text("Launch at System startup")
                        .font(.system(size: 18, weight: .regular))
                        .frame(minWidth: 0, idealWidth: .infinity, maxWidth: .infinity,alignment: .leading)
                }
                .padding(.trailing, 16.0)
                .onChange(of: self.launchAtLogin, perform: { value in
                    SMLoginItemSetEnabled("com.redrazzr.AutoLauncher" as CFString, value)
                    print("AutoLaunch set to \(value)")
                })
                .toggleStyle(SwitchToggleStyle(tint: .primary))
                VStack() {
                    ForEach(Array(accounts.keys), id: \.self){acc in
                        AccountSection(account: acc, calendars: self.accounts[acc]!)
                        
                    }
                }
                .padding(.top, 10.0)
                .padding(.trailing, 16)
                
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
        .onAppear{
            self.accounts = eventStore.getCalendars()
        }
        .frame(width: 320, height: 540)
        .padding(.horizontal, 16.0)
        .padding(.vertical, 32.0)
        
    }
}

struct AccountSection: View {
    var account: String
    var calendars: [EKCalendar]
    var body: some View {
        Section(
            header: Text(account)
                .foregroundColor(.gray)
                .frame(minWidth: 0, idealWidth: .infinity, maxWidth: .infinity, minHeight: 0, idealHeight: 10, maxHeight: .infinity, alignment: .leading)
        )
        {
            ForEach(calendars, id: \.self){calendar in
                Calendars(calendar: calendar)
            }
            
            
        }
        
    }
}

struct Calendars: View {
    var calendar: EKCalendar
    @State private var allowedCalendars: [String] = UserDefaults.standard.stringArray(forKey: "allowedCalendars") ?? []
    @State private var allowCalendar = true
    private var isAllow: Binding<Bool> { Binding (
        get: { return UserDefaults.standard.bool(forKey: calendar.title) },
        set: { value in
            UserDefaults.standard.set(value, forKey: calendar.title)
            if(value){
                addAllowedCalendars(id: calendar.calendarIdentifier)
            }else{
                removeAllowedCalendars(id: calendar.calendarIdentifier)
            }
            loadNotifications()
        }
    )
    }
    var body: some View {
        HStack{
            Toggle(isOn: isAllow){
                Text(calendar.title)
                    .font(.system(size: 18, weight: .regular))
                    .frame(minWidth: 0, idealWidth: .infinity, maxWidth: .infinity,alignment: .leading)
                
            }
            .toggleStyle(SwitchToggleStyle(tint: .primary))
        }
    }
}


struct SettingsScreen_Previews: PreviewProvider {
    static var previews: some View {
        SettingsScreen(currentPage: .constant("settings"))
    }
}

