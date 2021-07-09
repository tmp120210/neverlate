//
//  MeetingsData.swift
//  Neverlate
//
//  Created by Александр Северюхин on 09.07.2021.
//

import Foundation
import EventKit
import UserNotifications

struct Meeting: Codable, Identifiable{
    let id : String
    let title: String
    let startDate: Date
    let endDate: Date
    let url: String
}

struct MeetingDate: Codable, Identifiable{
    var id = UUID()
    var date: String
    var meetings: [Meeting]
}

func loadMeetings() -> [MeetingDate]{
    let eventStore = EKEventStore()
    let calendar = Calendar.current
    var dates: [String: [Meeting]] = [:]
    var result: [MeetingDate] = []
    
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
            let formater = DateFormatter()
            formater.dateFormat = "EEEE, d MMMM yyyy"
            let date = formater.string(from: event.startDate)
            if dates[date] == nil {
                dates[date] = []
                dates[date]?.append(Meeting(id: event.eventIdentifier, title: event.title, startDate: event.startDate, endDate: event.endDate, url: event.structuredLocation?.title ?? ""))
            }else{
                dates[date]?.append(Meeting(id: event.eventIdentifier, title: event.title, startDate: event.startDate, endDate: event.endDate, url: event.structuredLocation?.title ?? ""))
            }
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
    for date in dates{
        result.append(MeetingDate(date: date.key, meetings: date.value))
    }
    return result
}
