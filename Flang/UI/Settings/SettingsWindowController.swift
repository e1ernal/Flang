//
//  SettingsWindowController.swift
//  Flang
//
//  Created by e1ernal on 09.07.2026.
//

import AppKit
import SwiftUI

/// Manages the single Settings window (FR-8). Creating it lazily; subsequent
/// calls to `showWindow` bring the existing window to front.
final class SettingsWindowController {
    private var window: NSWindow?

    private let settings: SettingsStore
    private let flagStore: FlagStore
    private let manager: InputSourceManager

    init(settings: SettingsStore, flagStore: FlagStore, manager: InputSourceManager) {
        self.settings = settings
        self.flagStore = flagStore
        self.manager = manager
    }

    func showWindow() {
        if let window, window.isVisible {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let settingsView = SettingsView(
            settings: settings,
            flagStore: flagStore,
            manager: manager
        )
        let hostingView = NSHostingView(rootView: settingsView)

        let newWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 640, height: 420),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        newWindow.title = "Flang Settings"
        newWindow.contentView = hostingView
        newWindow.isReleasedWhenClosed = false
        newWindow.center()
        newWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        window = newWindow
    }
}
