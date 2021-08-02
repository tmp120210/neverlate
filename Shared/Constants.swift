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

let zoomPattern = Pattern(name: "zoom", pattern: "https?:\\/\\/(?:[a-zA-Z0-9-.]+)?zoom.(?:us|com.cn)\\/(?:j|my|w)\\/[-a-zA-Z0-9()@:%_\\+.~#?&=\\/]*")
let googlePattern = Pattern(name: "google", pattern: "https?:\\/\\/meet.google.com\\/[a-z-]+")
let msTeamsPAttern = Pattern(name: "teams", pattern: "https?:\\/\\/teams\\.microsoft\\.com/l/meetup-join/[a-zA-Z0-9_%\\/=\\-\\+\\.?]+")
let msLivePattern = Pattern(name: "msLive", pattern: "https?:\\/\\/teams\\.live\\.com/meet/[0-9]+")

let patterns = [zoomPattern, googlePattern, msTeamsPAttern]


