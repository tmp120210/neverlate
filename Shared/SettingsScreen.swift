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
    private var launchAtLogin: Binding<Bool> { Binding (
        get: { return UserDefaults.standard.bool(forKey: "launchAtLogin") },
        set: { value in
            UserDefaults.standard.set(value, forKey: "launchAtLogin")
            SMLoginItemSetEnabled("com.redrazzr.AutoLauncher" as CFString, value)
            print("AutoLaunch set to \(value)")
        }
    )
    }
    @State var accounts : [String: [EKCalendar]] = [:]
    var body : some View {
        VStack() {
            ZStack{
                HStack(alignment: .center, spacing: 8){
                    Button(action: {
                        self.currentPage = "meeting"
                    })
                    {
                        Image("chevron.left")
                            .resizable(resizingMode: .stretch)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 12, height: 20)
                            .foregroundColor(.black)
                        
                    }
                    .buttonStyle(PlainButtonStyle())
                    Text("Back")
                        .font(.system(size: 17, weight: .regular))
                }
                .padding(.vertical)
                .frame(minWidth: 0, idealWidth: .infinity, maxWidth: .infinity,alignment: .leading)
                Text("Settings")
                    .font(.custom("SF Pro Display", size: 25))
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            
            ScrollView(showsIndicators: false){
                Toggle(isOn: launchAtLogin){
                    Text("Launch at System startup")
                        .padding()
                        .font(.system(size: 18, weight: .regular))
                        .frame(minWidth: 0, idealWidth: .infinity, maxWidth: .infinity,alignment: .leading)
                }
                .padding(.trailing)
                .rowStyle(backgroundColor: Color("listBackground"))
                .toggleStyle(SwitchToggleStyle())
                
                Section(header:
                            Text("Connected accounts")
                                .sectionHeader()
                            .padding(.vertical)
                            
                ) {
                    ForEach(Array(accounts.keys), id: \.self){acc in
                        AccountSection(account: acc, calendars: self.accounts[acc]!)
                        
                    }
                }
                .padding(.top, 10.0)
                
                Spacer()
            }
            Button(action: {
                NSApplication.shared.terminate(self)
            })
            {
                Text("Quit the App")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .background(Color.red)
                
            }
            .cornerRadius(10)
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
                .sectionHeader()
                .foregroundColor(.gray)
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
                    .padding()
                    .font(.system(size: 18, weight: .regular))
                    .frame(minWidth: 0, idealWidth: .infinity, maxWidth: .infinity,alignment: .leading)
                
            }
            .padding(.trailing)
            .rowStyle(backgroundColor: Color("listBackground"))
            .toggleStyle(SwitchToggleStyle())
            
            
        }
    }
}

func addAllowedCalendars(id: String){
    var allowedCalendars = UserDefaults.standard.stringArray(forKey: "allowedCalendars") ?? []
    allowedCalendars.append(id)
    UserDefaults.standard.set(allowedCalendars, forKey: "allowedCalendars")
    
}

func removeAllowedCalendars(id: String){
    var allowedCalendars = UserDefaults.standard.stringArray(forKey: "allowedCalendars") ?? []
    allowedCalendars.removeAll(where: {$0 == id})
    UserDefaults.standard.set(allowedCalendars, forKey: "allowedCalendars")
}

struct SettingsScreen_Previews: PreviewProvider {
    static var previews: some View {
        SettingsScreen(currentPage: .constant("settings"))
    }
}

