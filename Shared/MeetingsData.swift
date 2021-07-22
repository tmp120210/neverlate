//
//  MeetingsData.swift
//  Neverlate
//
//  Created by Александр Северюхин on 09.07.2021.
//
import SwiftUI
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
    var ongoing: [Meeting]
}

func loadMeetings() -> [MeetingDate]{
    let eventStore = EKEventStore()
    let calendar = Calendar.current
    var dates: [String: [Meeting]] = [:]
    var result: [MeetingDate] = []
    var ongoing: [Meeting] = []
    let pattern = "https?:\\/\\/(?:[a-zA-Z0-9-.]+)?zoom.(?:us|com.cn)\\/(?:j|my|w)\\/[-a-zA-Z0-9()@:%_\\+.~#?&=\\/]*"
    
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
        if let notes = event.notes{
            let zoomLink = notes.range(of: pattern, options: .regularExpression)
            let status = getParticipantStatus(event)
            if((zoomLink) != nil && (status != .declined)){
                let formater = DateFormatter()
                var url : Substring = ""
                if let data = notes.range(of: pattern, options: .regularExpression){
                    url = event.notes?[data] ?? ""
                }
                formater.dateFormat = "EEEE, d MMMM yyyy"
                let date = formater.string(from: event.startDate)
                if(event.startDate < Date() &&  event.endDate > Date()){
                    ongoing.append(Meeting(id: event.eventIdentifier, title: event.title, startDate: event.startDate, endDate: event.endDate, url: String(url)))
                }else if dates[date] == nil {
                    dates[date] = []
                    dates[date]?.append(Meeting(id: event.eventIdentifier, title: event.title, startDate: event.startDate, endDate: event.endDate, url: String(url)))
                }else{
                    dates[date]?.append(Meeting(id: event.calendarItemIdentifier, title: event.title, startDate: event.startDate, endDate: event.endDate, url: event.structuredLocation?.title ?? ""))
                }
            }
        }
        
    }
    for date in dates{
        result.append(MeetingDate(date: date.key, meetings: date.value, ongoing: ongoing))
    }
    result.sort{
        let formater = DateFormatter()
        formater.dateFormat = "EEEE, d MMMM yyyy"
        guard let firstDate = formater.date(from: $0.date) else {return false}
        guard let secondDate = formater.date(from: $1.date) else {return false}
        return firstDate < secondDate ? true : false
    }
    return result
}

func loadNitifications(){
    let eventStore = EKEventStore()
    let center = UNUserNotificationCenter.current()
    center.removeAllPendingNotificationRequests()
    center.removeAllDeliveredNotifications()
    let calendar = Calendar.current
    let pattern = "https?:\\/\\/(?:[a-zA-Z0-9-.]+)?zoom.(?:us|com.cn)\\/(?:j|my|w)\\/[-a-zA-Z0-9()@:%_\\+.~#?&=\\/]*"
    var events: [EKEvent] = []
    
    let todayComponent = DateComponents()
    let oneDayAgo = calendar.date(byAdding: todayComponent, to: Date(), wrappingComponents: true)
    
    var oneMonthFromNowComponents = DateComponents()
    oneMonthFromNowComponents.month = 1
    let oneMonthFromNow = calendar.date(byAdding: oneMonthFromNowComponents, to: Date(),wrappingComponents: true)
    
    var predicate: NSPredicate? = nil
    if let anAgo = oneDayAgo, let aNow = oneMonthFromNow {
        predicate = eventStore.predicateForEvents(withStart: anAgo, end: aNow, calendars: nil)
    }
    if let aPredicate = predicate {
        events = eventStore.events(matching: aPredicate)
    }
    for event in events {
        if let notes = event.notes{
            let status = getParticipantStatus(event)
            let zoomLink = notes.range(of: pattern, options: .regularExpression)
            if((zoomLink) != nil && (status != .declined)){
                let data = calendar.date(byAdding: .minute, value: -1, to: event.startDate)
                let component = calendar.dateComponents([.minute, .hour, . day, .month, .year], from: data!)
                let content = UNMutableNotificationContent()
                if let data = notes.range(of: pattern, options: .regularExpression){
                    content.userInfo["url"] = event.notes?[data] ?? ""
                }
                content.title = "Time to meeting"
                content.subtitle = event.title
                content.sound = UNNotificationSound.default
                let trigger = UNCalendarNotificationTrigger(dateMatching: component, repeats: false)
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                    center.add(request)
            }
        }
    }
}


func openZoomLink(url: String){
    let urlString = url.replacingOccurrences(of: "?", with: "&").replacingOccurrences(of: "/j/", with: "/join?confno=")
    var zoomAppUrl = URLComponents(url: URL(string: urlString)!, resolvingAgainstBaseURL: false)!
    zoomAppUrl.scheme = "zoommtg"
    
    if NSWorkspace.shared.open(zoomAppUrl.url!) {
        print("opened in zoom app")
    }else{
        NSWorkspace.shared.open(URL(string: url)!)
    }
}

func getParticipantStatus(_ event: EKEvent) -> EKParticipantStatus? {
    if event.hasAttendees {
        if let attendees = event.attendees {
            if let currentUser = attendees.first(where: { $0.isCurrentUser }) {
                return currentUser.participantStatus
            }
        }
    }
    return EKParticipantStatus.unknown
}
