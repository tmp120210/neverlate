//
//  AppDelegate.swift
//  AutoLauncher
//
//  Created by Александр Северюхин on 16.07.2021.
//

import Cocoa

class AutoLauncherAppDelegate: NSObject, NSApplicationDelegate {

    struct Constants {
        static let mainAppBundleID = "com.redrazzr.Neverlate"
    }


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        print("launched")
        let runningApps = NSWorkspace.shared.runningApplications
        let isRunning = runningApps.contains{
            $0.bundleIdentifier == Constants.mainAppBundleID
        }
        
        if !isRunning {
            var path = Bundle.main.bundlePath as NSString
            for _ in 1...4 {
                path = path.deletingLastPathComponent as NSString
            }
            let applicationPathString = path as String
            guard let pathURL = URL(string: applicationPathString) else {return}
            NSWorkspace.shared.openApplication(at: pathURL, configuration: NSWorkspace.OpenConfiguration(), completionHandler: nil)
        }
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

