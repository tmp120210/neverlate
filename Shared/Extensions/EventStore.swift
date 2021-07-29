//
//  EventStore.swift
//  Neverlate
//
//  Created by Александр Северюхин on 26.07.2021.
//

import Foundation
import EventKit

extension EKEventStore{
    func getCalendars() -> [String: [EKCalendar]]{
        let calendars = self.calendars(for: .event)
        return Dictionary(grouping: calendars) { $0.source.title }
    }
    
    func getAllowed(){
        let calendars = self.calendars(for: .event)
        let dict = Dictionary(grouping: calendars) { $0.source.title }
        var calendarsList = UserDefaults.standard.stringArray(forKey: "calendarsList") ?? []
        for account in dict {
            if(!calendarsList.contains(account.key)){
                UserDefaults.standard.set(true, forKey: account.key)
                for calendar in account.value{
                    addAllowedCalendars(id: calendar.calendarIdentifier)
                }
                calendarsList.append(account.key)
            }
        }
        UserDefaults.standard.set(calendarsList, forKey: "calendarsList")
    }
}
