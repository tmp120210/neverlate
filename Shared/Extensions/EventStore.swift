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
}
