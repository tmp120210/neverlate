//
//  CalendarAccessScreen.swift
//  Neverlate
//
//  Created by Александр Северюхин on 07.07.2021.
//

import SwiftUI
import EventKit

struct CalendarAccessScreen: View {
    let eventStore = EKEventStore()
    @Binding var currentPage: String
    var body : some View {
        VStack() {
            Image("accessCalendar")
                .cornerRadius(10)
                .aspectRatio(contentMode: .fill)
            Spacer()
            VStack(spacing: 16.0){
                Text("Access to a calendar")
                    .font(.system(size: 22))
                    .fontWeight(.heavy)
                Text("We need to monitor ongoing and upcoming ZOOM meetings")
                    .font(.system(size: 18))
                    .multilineTextAlignment(.center)
            }
            Spacer()
            Button(action: {
                eventStore.requestAccess(to: .event, completion:
                      {(granted: Bool, error: Error?) -> Void in
                        if granted, error == nil {
                            #if os(macOS)
                            self.currentPage = "allow"
                            #else
                            self.currentPage = "meeting"
                            #endif
                            loadNotifications()
                          } else {
                            print("Access denied")
                          }
                        #if os(macOS)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            if !popOver.isShown{
                                showPopover()
                            }
                        }
                        #endif
                    })
                
            }, label: {
                Text("Allow access")
                    .fontWeight(.medium)
                    .font(.system(size: 17))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .background(Color("lightButton"))
            })
            .cornerRadius(10)
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 16.0)
        .padding(.vertical, 32.0)
        
    }
}

struct CalendarAccessScreen_Previews: PreviewProvider {
    static var previews: some View {
        CalendarAccessScreen(currentPage: .constant("access"))
    }
}
