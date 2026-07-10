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
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate

_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
