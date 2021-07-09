//
//  MeetingsList.swift
//  Neverlate
//
//  Created by Александр Северюхин on 08.07.2021.
//

import SwiftUI
import EventKit
import UserNotifications

struct Meeting: Codable, Identifiable{
    let id : String
    let title: String
    let startDate: Date
    let endDate: Date
    let url: String
}

struct Meetings: Identifiable {
    let id = UUID()
    let title: String
}

struct MeetingsScreen: View {
    let eventStore = EKEventStore()
    @State var ongoing : [Meeting] = []
    @State var meetings : [Meeting] = []
    @Binding var show: String
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
            .background(Color("listBackground"))
            .cornerRadius(8)
            List(meetings){meeting in
                MeetingRow(meeting: meeting)
            }
            .colorMultiply(Color("listBackground"))
            .cornerRadius(8)
            
        }
        .frame(width: 320, height: 540)
        .padding(.horizontal, 16.0)
        .padding(.vertical, 32.0)
        .onAppear{
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                if success {
                    print("All set!")
                } else if let error = error {
                    print(error.localizedDescription)
                }
            }
            loadMeetings()
        }
    }
    func loadMeetings(){
        let calendar = Calendar.current
        
        let todayComponent = DateComponents()
        let oneDayAgo = calendar.date(byAdding: todayComponent, to: Date(), wrappingComponents: true)
        
        var oneMonthFromNowComponents = DateComponents()
        oneMonthFromNowComponents.month = 1
        let oneMonthFromNow = calendar.date(byAdding: oneMonthFromNowComponents, to: Date(),wrappingComponents: true)
        
        var predicate: NSPredicate? = nil
        if let anAgo = oneDayAgo, let aNow = oneMonthFromNow {
            predicate = eventStore.predicateForEvents(withStart: anAgo, end: aNow, calendars: nil)
        }
        
        var events: [EKEvent] = []
        if let aPredicate = predicate {
            events = eventStore.events(matching: aPredicate)
        }
        for event in events {
            let center = UNUserNotificationCenter.current()
            if(event.title.contains("Zoom meeting")){
                meetings.append(Meeting(id: event.eventIdentifier, title: event.title, startDate: event.startDate, endDate: event.endDate, url: event.structuredLocation?.title ?? ""))
            }
            let data = calendar.date(byAdding: .minute, value: -3, to: event.startDate)
            let component = calendar.dateComponents([.minute, .hour, . day, .month, .year], from: data!)
            let content = UNMutableNotificationContent()
            content.title = "Time to meeting"
            content.subtitle = event.title
            content.userInfo["url"] = event.structuredLocation?.title ?? ""
            content.sound = UNNotificationSound.default
            let trigger = UNCalendarNotificationTrigger(dateMatching: component, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                center.add(request)
            
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
        HStack{
            Text("\(hour):\(minutes)")
                .font(.system(size: 18))
            Text(updated)
                .font(.system(size: 18))
                .fontWeight(.bold)
        }
    }
}

struct MeetingsScreen_Previews: PreviewProvider {
    static var previews: some View {
        MeetingsScreen(show: .constant("meetings"))
    }
}
