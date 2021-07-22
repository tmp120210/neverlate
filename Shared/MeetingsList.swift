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
    let showListPublisher = NotificationCenter.default
        .publisher(for: Notification.showList)
    @State var ongoing : [Meeting] = []
    @State var meetingDates : [MeetingDate] = []
    @Binding var currentPage: String
    var body : some View {
        VStack(spacing: 16.0) {
            HStack(alignment: .top){
                Button(action: {
                    self.currentPage = "settings"
                })
                {
                    Image("settings").renderingMode(.original)
                }
                .buttonStyle(PlainButtonStyle())
            }.padding(.trailing, 2.0).frame(minWidth: 0, idealWidth: .infinity, maxWidth: .infinity,alignment: .trailing)
            VStack{
                if self.ongoing.count < 2 {Spacer()}
                if(ongoing.isEmpty){
                    Text("No ongoing meetings")
                }else{
                    List(ongoing){meeting in
                        OngoingRow(meeting: meeting)
                    }
                    .colorMultiply(Color("listBackground"))
                }
                if self.ongoing.count < 2 {Spacer()}
            }
            .frame(minWidth: 0, idealWidth: .infinity, maxWidth: .infinity, minHeight: 0, idealHeight: 70, maxHeight: 70)
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
        .onReceive(showListPublisher){_ in
            loadData()
        }
        .onReceive(pub) { _ in
            loadData()
            loadNitifications()
        }
        .onAppear{
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                if success {
                    print("All set!")
                } else if let error = error {
                    print(error.localizedDescription)
                }
            }
            loadData()
        }
    }
    
    func loadData() {
        self.meetingDates = loadMeetings()
        self.ongoing = self.meetingDates.first?.ongoing ?? []
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
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.system(size: 16, weight: .bold))
                .lineLimit(1)
        }.onTapGesture {
            guard let url = URL(string: "ical://ekevent/\(meeting.id)") else {return}
            NSWorkspace.shared.openApplication(at: url , configuration: NSWorkspace.OpenConfiguration(), completionHandler: nil)
        }
    }
}

struct OngoingRow: View {
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
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.system(size: 16, weight: .bold))
                .lineLimit(1)
        }
        .onTapGesture {
            openZoomLink(url: meeting.url)
        }
    }
}

struct MeetingsScreen_Previews: PreviewProvider {
    static var previews: some View {
        MeetingsScreen(currentPage: .constant("meetings"))
    }
}
