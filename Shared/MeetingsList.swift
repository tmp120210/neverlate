//
//  MeetingsList.swift
//  Neverlate
//
//  Created by Александр Северюхин on 08.07.2021.
//

import SwiftUI
import EventKit
import UserNotifications



struct MeetingsScreen: View {
    let eventStore = EKEventStore()
    let pub = NotificationCenter.default
        .publisher(for: Notification.Name.EKEventStoreChanged)
    @State var ongoing : [Meeting] = []
    @State var meetingDates : [MeetingDate] = []
    @Binding var currentPage: String
    var body : some View {
        VStack() {
            VStack{
                if(ongoing.isEmpty){
                    Text("No ongoing meetings")
                }else{
                    List(ongoing){meeting in
                        MeetingRow(meeting: meeting)
                    }
                    .colorMultiply(Color("listBackground"))
                }
            }
            .frame(minWidth: 0, idealWidth: .infinity, maxWidth: .infinity, minHeight: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, idealHeight: 70, maxHeight: 70)
            .background(Color("emptyListBackground"))
            .cornerRadius(8)
            List(meetingDates){date in
                DateRow(date: date.date, meetings: date.meetings)
            }
            .colorMultiply(Color("listBackground"))
            .cornerRadius(8)
            
        }
        .frame(width: 320, height: 540)
        .padding(.horizontal, 16.0)
        .padding(.vertical, 32.0)
        .onReceive(pub) { _ in
            self.meetingDates = loadMeetings()
        }
        .onAppear{
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                if success {
                    print("All set!")
                } else if let error = error {
                    print(error.localizedDescription)
                }
            }
            self.meetingDates = loadMeetings()
        }
    }
    
}

struct DateRow: View {
    var date: String = ""
    var meetings: [Meeting] = []
    
    var body: some View {
        VStack(spacing: 16.0){
            Text(date)
                .font(.system(size: 10, weight: .medium))
                .frame(maxWidth: .infinity, alignment: .leading)
            ForEach(meetings){meeting in
                MeetingRow(meeting: meeting)
            }
        }
        .padding(.top, 16.0)
    }
}



struct MeetingRow: View {
    var meeting: Meeting
    
    var body: some View {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: meeting.startDate)
        let minutes = calendar.component(.minute, from: meeting.startDate) < 10 ? "0\(calendar.component(.minute, from: meeting.startDate))" : "\(calendar.component(.minute, from: meeting.startDate))"
        let updated = meeting.title.replacingOccurrences(of: "Zoom meeting invitation - ", with: "")
        HStack(alignment: .center){
            Text("\(hour):\(minutes)")
                .font(.system(size: 16))
                .frame(alignment: .leading)
            Text(updated)
                .frame(maxWidth: .infinity)
                .font(.system(size: 16, weight: .bold))
                .lineLimit(1)
        }
    }
}

struct MeetingsScreen_Previews: PreviewProvider {
    static var previews: some View {
        MeetingsScreen(currentPage: .constant("meetings"))
    }
}
