//
//  NeverlateiOS.swift
//  Neverlate (iOS)
//
//  Created by Александр Северюхин on 29.07.2021.
//

import SwiftUI
import UserNotifications
import EventKit

@main
struct NeverlateiOSApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            NavigationContainer(currentPage: EKEventStore.authorizationStatus(for: .event) == EKAuthorizationStatus.authorized ? "meeting" : "welcome")
        }
        
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            
            if let error = error {
                print(error.localizedDescription)
            }else{
                loadNotifications()
            }
            
        }
        UNUserNotificationCenter.current().delegate = self
        return true
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate  {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        var appUrl : String = ""
        if userInfo["appUrl"] as? String != nil {
            appUrl = userInfo["appUrl"] as! String
        }
        let browserUrl = userInfo["browserUrl"] as! String
        openMeetingLink(appLink: URL(string: appUrl) , browserLink: URL(string: browserUrl)!)
    }
}
