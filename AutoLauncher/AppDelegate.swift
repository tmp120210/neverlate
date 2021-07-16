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
        static let mainAppName = "Neverlate.app"
    }


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        print("launched")
        let runningApps = NSWorkspace.shared.runningApplications
        let isRunning = runningApps.contains{
            $0.bundleIdentifier == Constants.mainAppBundleID
        }
        
        if !isRunning {
            let path = Bundle.main.bundlePath as NSString
            var components = path.pathComponents
            components.removeLast()
            components.append(Constants.mainAppName)
            let applicationPathString = NSString.path(withComponents: components)
            guard let pathURL = URL(string: "file://\(applicationPathString)") else {return}
            NSWorkspace.shared.openApplication(at: pathURL, configuration: NSWorkspace.OpenConfiguration(), completionHandler: nil)
        }
        
    }
}

