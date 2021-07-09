//
//  CheckCalendarScreen.swift
//  Neverlate
//
//  Created by Александр Северюхин on 07.07.2021.
//

import SwiftUI

struct CalendarScreen: View {
    @Binding var show: String
    var body : some View {
        VStack() {
            Image("checkCalendar")
                .cornerRadius(10)
                .aspectRatio(contentMode: .fill)
            Spacer()
            VStack(spacing: 16.0){
                Text("Checking your calendars")
                    .font(.system(size: 22))
                    .fontWeight(.heavy)
                Text("NeverLate is checking that your scheduled Zoom meetings can be found")
                    .font(.system(size: 18))
                    .multilineTextAlignment(.center)
            }
            Spacer()
            Button(action: {self.show = "access"}, label: {
                Text("Continue")
                    .fontWeight(.regular)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .background(Color("lightButton"))
            })
            .cornerRadius(10)
            .buttonStyle(PlainButtonStyle())
            
        }
        .frame(width: 320, height: 540)
        .padding(.horizontal, 16.0)
        .padding(.vertical, 32.0)
    }
}

struct CalendarScreen_Previews: PreviewProvider {
    static var previews: some View {
        CalendarScreen(show: .constant("calendar"))
    }
}
