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
    let url: MeetingLink
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
    let allowedCalendars = UserDefaults.standard.stringArray(forKey: "allowedCalendars") ?? []
    
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
        if event.notes != nil{
            let link = findLink(event: event)
            let status = getParticipantStatus(event)
            if((link) != nil && (status != .declined) && (allowedCalendars.contains(event.calendar.calendarIdentifier) )){
                let formater = DateFormatter()
                formater.dateFormat = "EEEE, d MMMM yyyy"
                let date = formater.string(from: event.startDate)
                if(event.startDate < Date() &&  event.endDate > Date()){
                    ongoing.append(Meeting(id: event.eventIdentifier, title: event.title, startDate: event.startDate, endDate: event.endDate, url: link!))
                }else if dates[date] == nil {
                    dates[date] = []
                    dates[date]?.append(Meeting(id: event.calendarItemIdentifier, title: event.title, startDate: event.startDate, endDate: event.endDate, url: link!))
                }else{
                    dates[date]?.append(Meeting(id: event.calendarItemIdentifier, title: event.title, startDate: event.startDate, endDate: event.endDate, url: link!))
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

func loadNotifications(){
    let eventStore = EKEventStore()
    let center = UNUserNotificationCenter.current()
    center.removeAllPendingNotificationRequests()
    center.removeAllDeliveredNotifications()
    let calendar = Calendar.current
    var events: [EKEvent] = []
    let allowedCalendars = UserDefaults.standard.stringArray(forKey: "allowedCalendars") ?? []
    
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
        if event.notes != nil{
            let status = getParticipantStatus(event)
            let link = findLink(event: event)
            if((link) != nil && (status != .declined) && (allowedCalendars.contains(event.calendar.calendarIdentifier) )){
                let data = calendar.date(byAdding: .minute, value: -1, to: event.startDate)
                let component = calendar.dateComponents([.minute, .hour, . day, .month, .year], from: data!)
                let content = UNMutableNotificationContent()
                content.userInfo["appUrl"] = link?.appLink?.absoluteString
                content.userInfo["browserUrl"] = link?.browserLink.absoluteString
                content.title = event.title
                content.subtitle = "Click to join a meeting"
                content.sound = UNNotificationSound.default
                let trigger = UNCalendarNotificationTrigger(dateMatching: component, repeats: false)
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                center.add(request)
            }
        }
    }
}


func openMeetingLink(appLink: URL?, browserLink: URL){
    if appLink != nil {
        if NSWorkspace.shared.open(appLink!) {
            print("opened in app")
        }else{
            NSWorkspace.shared.open(browserLink)
            print("Cant open in app, open in browser")
        }
    }else{
        NSWorkspace.shared.open(browserLink)
        print("open in browser")
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

func findLink (event: EKEvent) -> MeetingLink? {
    guard let notes = event.notes else {return nil}
    for pattern in patterns{
        let linkRange = notes.range(of: pattern.pattern, options: .regularExpression)
        if linkRange != nil {
            let link = notes[linkRange!]
            guard let url = URL(string: String(link)) else {return nil}
            switch pattern.name {
            case "zoom":
                let urlString = link.replacingOccurrences(of: "?", with: "&").replacingOccurrences(of: "/j/", with: "/join?confno=")
                var zoomAppUrl = URLComponents(url: URL(string: urlString)!, resolvingAgainstBaseURL: false)!
                zoomAppUrl.scheme = "zoommtg"
                return MeetingLink(browserLink: url, appLink: zoomAppUrl.url)
            case "google":
                return MeetingLink(browserLink: url, appLink: nil)
            case "teams":
                var teamsAppURL = URLComponents(url: url, resolvingAgainstBaseURL: false)!
                teamsAppURL.scheme = "msteams"
                return MeetingLink(browserLink: url, appLink: teamsAppURL.url)
            case "msLive":
                let urlString = "\(link.replacingOccurrences(of: "/teams.live.com/", with: ""))?fqdn=teams.live.com"
                var teamsLiveAppUrl = URLComponents(url: URL(string: urlString)!, resolvingAgainstBaseURL: false)!
                teamsLiveAppUrl.scheme = "msteams"
                return MeetingLink(browserLink: url, appLink: teamsLiveAppUrl.url)
            default:
                return nil
            }
        }
    }
    return nil
}
