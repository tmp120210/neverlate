//
//  NeverlateApp.swift
//  Shared
//
//  Created by Mikhail Filippov on 05.07.2021.
//

import SwiftUI

@main
struct NeverlateApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate{
    
    var StatusItem: NSStatusItem?
    var popOver = NSPopover()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        let menuView = Main()
        
        popOver.behavior = .transient
        popOver.animates = true
        popOver.contentViewController = NSViewController()
        popOver.contentViewController?.view = NSHostingView(rootView: menuView)
        
        popOver.contentViewController?.view.window?.makeKey()
        
        StatusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let MenuButton = StatusItem?.button{
            MenuButton.image = NSImage(systemSymbolName: "icloud.and.arrow.up.fill", accessibilityDescription: nil)
            MenuButton.action = #selector(menuButtonToggle)
        }
        
        if let window = NSApplication.shared.windows.first{
            window.close()
        }
        
    }
    @objc func menuButtonToggle(sender: AnyObject){
        if popOver.isShown{
            popOver.performClose(sender)
        }else{
            if let menuButton = StatusItem?.button{
                self.popOver.show(relativeTo: menuButton.bounds, of: menuButton, preferredEdge: NSRectEdge.minY)
            }
        }
    }
}

