//
//  Constants.swift
//  Neverlate
//
//  Created by Александр Северюхин on 23.07.2021.
//

import Foundation
import SwiftUI

struct MeetingLink: Codable{
    var browserLink: URL
    var appLink: URL?
}
struct Pattern: Codable{
    var name: String
    var pattern: String
}

var popOver = NSPopover()
var StatusItem: NSStatusItem?

func showPopover(){
    if let menuButton = StatusItem?.button{
        NotificationCenter.default.post(name: Notification.showList,
                                                       object: nil)
        popOver.show(relativeTo: menuButton.bounds, of: menuButton, preferredEdge: NSRectEdge.minY)
        popOver.contentViewController?.view.window?.makeKey()
    }
}

let patterns = [
    Pattern(name: "zoom", pattern: "https?:\\/\\/(?:[a-zA-Z0-9-.]+)?zoom.(?:us|com.cn)\\/(?:j|my|w)\\/[-a-zA-Z0-9()@:%_\\+.~#?&=\\/]*"),
    Pattern(name: "google", pattern: "https?:\\/\\/meet.google.com\\/[a-z-]+"),
    Pattern(name: "teams", pattern: "https?:\\/\\/teams\\.microsoft\\.com/l/meetup-join/[a-zA-Z0-9_%\\/=\\-\\+\\.?]+"),
    Pattern(name: "msLive", pattern: "https?:\\/\\/teams\\.live\\.com/meet/[0-9]+"),
]

