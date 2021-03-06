//
//  AutoLaunch.swift
//  Neverlate
//
//  Created by Александр Северюхин on 07.07.2021.
//

import SwiftUI
import ServiceManagement

struct AutoLaunchScreen: View {
    @Binding var currentPage: String
    var body : some View {
        VStack() {
            Image("allowAccess")
                .aspectRatio(contentMode: .fill)
            Spacer()
            VStack(spacing: 16.0){
                Text("You are all set!")
                    .font(.system(size: 22))
                    .fontWeight(.heavy)
                Text("To never miss a meeting it is recommended that you allow app to launch automatically")
                    .font(.system(size: 18))
                    .multilineTextAlignment(.center)
            }
            Spacer()
            VStack(spacing: 22.0){
                Button(action: {
                    UserDefaults.standard.set(true, forKey: "launchAtLogin")
                    SMLoginItemSetEnabled("com.redrazzr.AutoLauncher" as CFString, true)
                    self.currentPage = "meeting"
                }, label: {
                    Text("Allow and continue")
                        .fontWeight(.medium)
                        .font(.system(size: 17))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(Color("lightButton"))
                })
                .cornerRadius(10)
                .buttonStyle(PlainButtonStyle())
                Button(action: {self.currentPage = "meeting"}, label: {
                    Text("Skip")
                        .fontWeight(.regular)
                        .foregroundColor(Color("secondaryButton"))
                        .font(.system(size: 18))
                })
                .buttonStyle(PlainButtonStyle())
            }
            
        }
        .padding(.horizontal, 16.0)
        .padding(.vertical, 32.0)
        
    }
}

struct AutoLaunchScreen_Previews: PreviewProvider {
    static var previews: some View {
        AutoLaunchScreen(currentPage: .constant("auto"))
    }
}
