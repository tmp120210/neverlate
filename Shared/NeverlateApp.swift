//
//  NeverlateApp.swift
//  Shared
//
//  Created by Mikhail Filippov on 05.07.2021.
//

import SwiftUI
import UserNotifications
import EventKit

@main
struct NeverlateApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    
    
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        let startScreen = EKEventStore.authorizationStatus(for: .event) == EKAuthorizationStatus.authorized ? "meeting" : "welcome"
        let menuView = NavigationContainer(currentPage: startScreen)
        UNUserNotificationCenter.current().delegate = self
        popOver.behavior = .transient
        popOver.animates = true
        popOver.contentViewController = NSViewController()
        popOver.contentViewController?.view = NSHostingView(rootView: menuView)
        
        
        StatusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let MenuButton = StatusItem?.button{
            MenuButton.image = NSImage(systemSymbolName: "icloud.and.arrow.up.fill", accessibilityDescription: nil)
            MenuButton.action = #selector(menuButtonToggle)
            if startScreen != "meeting"{
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    popOver.show(relativeTo: MenuButton.bounds, of: MenuButton, preferredEdge: NSRectEdge.minY)
                    popOver.contentViewController?.view.window?.makeKey()
                }
            }
            
        }
        if let window = NSApplication.shared.windows.first{
            window.close()
        }
        loadNotifications()
        
    }
    @objc func menuButtonToggle(sender: AnyObject){
        if popOver.isShown{
            popOver.performClose(sender)
        }else{
           showPopover()
        }
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
