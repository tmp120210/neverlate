//
//  App.swift
//  Neverlate
//
//  Created by Александр Северюхин on 07.07.2021.
//

import SwiftUI

struct NavigationContainer: View{
    @State var currentPage: String
    var body: some View {
        ZStack(){
            switch currentPage {
            case "welcome":
                WelcomeScreen(currentPage: $currentPage)
            case "access":
                CalendarAccessScreen(currentPage: $currentPage)
            case "allow":
                AutoLaunchScreen(currentPage: $currentPage)
            case "meeting":
                MeetingsScreen(currentPage: $currentPage)
            case "settings":
                SettingsScreen(currentPage: $currentPage)
            default:
                WelcomeScreen(currentPage: $currentPage)
            }
            
        }
        .background(Color("appBackground"))
        
    }
}

struct Main_Previews: PreviewProvider {
    static var previews: some View {
        NavigationContainer(currentPage: "welcome")
    }
}
