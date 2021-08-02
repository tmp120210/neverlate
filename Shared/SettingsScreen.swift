//
//  SettingsScreen.swift
//  Neverlate
//
//  Created by Александр Северюхин on 19.07.2021.
//

import SwiftUI
#if os(macOS)
import ServiceManagement
#endif
import EventKit

struct SettingsScreen: View {
    let eventStore = EKEventStore()
    @Binding var currentPage: String
    #if os(macOS)
    private var launchAtLogin: Binding<Bool> { Binding (
        get: { return UserDefaults.standard.bool(forKey: "launchAtLogin") },
        set: { value in
            UserDefaults.standard.set(value, forKey: "launchAtLogin")
            SMLoginItemSetEnabled("com.redrazzr.AutoLauncher" as CFString, value)
            print("AutoLaunch set to \(value)")
        }
    )
    }
    #endif
    @State var accounts : [String: [EKCalendar]] = [:]
    var body : some View {
        VStack() {
            ZStack{
                HStack(alignment: .center, spacing: 8){
                    Button(action: {
                        self.currentPage = "meeting"
                    })
                    {
                        HStack{
                            Image("chevron.left")
                                .resizable(resizingMode: .stretch)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 12, height: 20)
                                .foregroundColor(.primary)
                            Text("Back")
                                .font(.system(size: 17, weight: .regular))
                        }
                        
                        
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.vertical)
                .frame(minWidth: 0, idealWidth: .infinity, maxWidth: .infinity,alignment: .leading)
                Text("Settings")
                    .font(.custom("SF Pro Display", size: 25))
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            
            ScrollView(showsIndicators: false){
                #if os(macOS)
                Toggle(isOn: launchAtLogin){
                    Text("Launch at System startup")
                        .padding()
                        .font(.system(size: 18, weight: .regular))
                        .frame(minWidth: 0, idealWidth: .infinity, maxWidth: .infinity,alignment: .leading)
                }
                .padding(.trailing)
                .rowStyle(backgroundColor: Color("listBackground"))
                .toggleStyle(SwitchToggleStyle())
                #endif
                Section(header:
                            Text("CONNECTED ACCOUNTS")
                            .foregroundColor(.gray)
                            .font(.system(size: 10, weight: .medium))
                            .padding(.top)
                            .sectionHeader()
                        
                ) {
                    ForEach(Array(accounts.keys), id: \.self){acc in
                        AccountSection(account: acc, calendars: self.accounts[acc]!)
                        
                    }
                }
                .padding(.top, 10.0)
                
                Spacer()
            }
            #if os(macOS)
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
            #endif
        }
        .onAppear{
            self.accounts = eventStore.getCalendars()
        }
        .padding(.horizontal, 16.0)
        .padding(.vertical, 32.0)
        
    }
}

struct AccountSection: View {
    var account: String
    var calendars: [EKCalendar]
    private var isAllow: Binding<Bool> { Binding (
        get: {
            return UserDefaults.standard.bool(forKey: account)
            
        },
        set: { value in
            UserDefaults.standard.set(value, forKey: account)
            if(value){
                for calendar in calendars{
                    addAllowedCalendars(id: calendar.calendarIdentifier)
                }
                
                
            }else{
                for calendar in calendars{
                    removeAllowedCalendars(id: calendar.calendarIdentifier)
                }
                
            }
            loadNotifications()
        }
    )
    }
    var body: some View {
        HStack{
            Toggle(isOn: isAllow){
                Text(account)
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

