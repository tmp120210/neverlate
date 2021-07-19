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
        
        let runningApps = NSWorkspace.shared.runningApplications
        let isRunning = runningApps.contains{
            $0.bundleIdentifier == Constants.mainAppBundleID
        }
        
        if !isRunning {
            let killAutoLauncherNotificationName = Notification.Name(rawValue: "killAutoLauncher")
                        DistributedNotificationCenter.default().addObserver(self,
                                                                            selector: #selector(self.terminateApp),
                                                                            name: killAutoLauncherNotificationName,
                                                                            object: Constants.mainAppBundleID)
            let path = Bundle.main.bundlePath as NSString
            var components = path.pathComponents
            for _ in 1...4{
                components.removeLast()
            }
            
            let applicationPathString = NSString.path(withComponents: components)
            guard let pathURL = URL(string: "file://\(applicationPathString)") else {return}
            NSWorkspace.shared.openApplication(at: pathURL, configuration: NSWorkspace.OpenConfiguration(), completionHandler: nil)
        }else{
            self.terminateApp()
        }
        
        
    }
    @objc
        private func terminateApp() {
            NSApp.terminate(nil)
        }
}

