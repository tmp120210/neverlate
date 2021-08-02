//
//  NavigationContainer.swift
//  Neverlate (iOS)
//
//  Created by Александр Северюхин on 29.07.2021.
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
            case "meeting":
                MeetingsScreen(currentPage: $currentPage)
            case "settings":
                SettingsScreen(currentPage: $currentPage)
            default:
                WelcomeScreen(currentPage: $currentPage)
            }

        }
        .padding()
        .background(Color("appBackground"))

    }
}

struct Main_Previews: PreviewProvider {
    static var previews: some View {
        NavigationContainer(currentPage: "welcome")
    }
}
