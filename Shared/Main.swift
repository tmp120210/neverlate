//
//  App.swift
//  Neverlate
//
//  Created by Александр Северюхин on 07.07.2021.
//

import SwiftUI

struct Main: View{
    @State private var show = ""
    var body: some View {
        ZStack(){
            switch show {
            case "welcome":
                WelcomeScreen(show: $show)
            case "calendar":
                CalendarScreen(show: $show)
            case "access":
                AccessScreen(show: $show)
            case "allow":
                AutoLaunchScreen(show: $show)
            default:
                WelcomeScreen(show: $show)
            }
            
        }
        .background(Color("appBackground"))
        
    }
}

struct Main_Previews: PreviewProvider {
    static var previews: some View {
        Main()
    }
}
