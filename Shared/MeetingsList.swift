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
            }
            .padding(.vertical)
            .frame(minWidth: 0, idealWidth: .infinity, maxWidth: .infinity,alignment: .trailing)
                if(ongoing.isEmpty){
                    HStack{
                        Text("No ongoing meetings")
                            .foregroundColor(Color("emptyListText"))
                    }
                    .frame(minWidth: 0, idealWidth: .infinity, maxWidth: .infinity, minHeight: 0, idealHeight: 48, maxHeight: 48)
                    .background(Color("emptyListBackground"))
                    .cornerRadius(8)
                    
                }else{
                    VStack(spacing: 8){
                        ForEach(ongoing){meeting in
                        OngoingRow(meeting: meeting)
                    }
                        
                    }
                    
                }
            if(meetingDates.isEmpty){
                VStack{
                    Image("empty")
                    Text("No meetings found in your\nconnected accounts")
                        .foregroundColor(Color("emptyListText"))
                        .multilineTextAlignment(.center)
                        
                }
                .frame(minWidth: 0, idealWidth: .infinity, maxWidth: .infinity, minHeight: 0, idealHeight: .infinity, maxHeight: .infinity, alignment: .center)
                .background(Color("emptyListBackground"))
                .cornerRadius(8)
            }else{
                ScrollView{
                    VStack(spacing: 8){
                        ForEach(meetingDates){date in
                        DateRow(date: date.date, meetings: date.meetings)
                    }
                        
                    }
                }
            }
            
            
            
        }
        .padding()
        .onReceive(showListPublisher){_ in
            loadData()
        }
        .onReceive(pub) { _ in
            loadData()
            loadNotifications()
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
        if meetings.count != 0 {
            VStack(spacing: 8){
                Text(date.uppercased())
                    .padding(.horizontal)
                    .font(.system(size: 10, weight: .medium))
                    .frame(maxWidth: .infinity, alignment: .leading)
                ForEach(meetings){meeting in
                    MeetingRow(meeting: meeting)
                }
            }
            .padding(.top, 16.0)
        }
    }
}



struct MeetingRow: View {
    var meeting: Meeting
    
    var body: some View {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: meeting.startDate)
        let minutes = calendar.component(.minute, from: meeting.startDate) < 10 ? "0\(calendar.component(.minute, from: meeting.startDate))" : "\(calendar.component(.minute, from: meeting.startDate))"
        let updated = meeting.title.replacingOccurrences(of: "Zoom meeting invitation - ", with: "")
        ZStack{
            HStack(alignment: .center){
                Text("\(hour):\(minutes)")
                    .foregroundColor(meeting.accepted ? Color.primary : Color("declinedText"))
                    .padding()
                    .font(.system(size: 16))
                    .frame(alignment: .leading)
                Text(updated)
                    .foregroundColor(meeting.accepted ? Color.primary : Color("declinedText"))
                    .padding(.trailing)
                    .frame(alignment: .leading)
                    .font(.system(size: 16, weight: .bold))
                    .lineLimit(1)
            }
            .rowStyle(backgroundColor: Color("listBackground"))
            .onTapGesture {
                #if os(macOS)
                guard let url = URL(string: "ical://ekevent/\(meeting.id)") else {return}
                NSWorkspace.shared.openApplication(at: url , configuration: NSWorkspace.OpenConfiguration(), completionHandler: nil)
                #else
                guard let url = URL(string: "calshow:\(meeting.startDate.timeIntervalSinceReferenceDate)") else {return}
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                #endif
            }
            if !meeting.accepted {
                Divider()
                    .background(Color("declinedText"))
                    .padding(.horizontal)
            }
            
        }
        
    }
}

struct OngoingRow: View {
    var meeting: Meeting
    
    var body: some View {
        let updated = meeting.title.replacingOccurrences(of: "Zoom meeting invitation - ", with: "")
        HStack(alignment: .center){
            Text("Now")
                .font(.system(size: 16, weight: .regular))
                .frame(alignment: .leading)
                .foregroundColor(.white)
                .padding()
            Text(updated)
                .frame(minWidth: 0, idealWidth: .infinity, maxWidth: .infinity, alignment: .leading)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(1)
            Image("meeting_icon")
                .padding(.horizontal)
        }
        .rowStyle(backgroundColor: Color.accentColor)
        .onTapGesture {
            openMeetingLink(appLink: meeting.url.appLink, browserLink: meeting.url.browserLink)
        }
    }
}

struct MeetingsScreen_Previews: PreviewProvider {
    static var previews: some View {
        MeetingsScreen(currentPage: .constant("meetings"))
    }
}
