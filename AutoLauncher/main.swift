//
//  main.swift
//  AutoLauncher
//
//  Created by Александр Северюхин on 16.07.2021.
//

import Cocoa

let delegate = AutoLauncherAppDelegate()
NSApplication.shared.delegate = delegate
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
