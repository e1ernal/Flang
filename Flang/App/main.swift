//
//  main.swift
//  Flang
//
//  Created by e1ernal on 21.05.2025.
//

import AppKit

// Menu-bar-only, no Dock icon (LSUIElement = YES, set declaratively via
// INFOPLIST_KEY_LSUIElement in the build settings) — no need to call
// setActivationPolicy(.accessory) at runtime.

// After a reboot, the Login Items entry (SMAppService) and macOS's own
// "Reopen windows when logging back in" can both relaunch the app
// independently, producing two menu bar icons. Bail out if we're not alone.
if let bundleID = Bundle.main.bundleIdentifier,
   NSRunningApplication.runningApplications(withBundleIdentifier: bundleID).count > 1 {
    exit(0)
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate

_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
