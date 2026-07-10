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
    private let updateChecker: UpdateChecker

    init(settings: SettingsStore, flagStore: FlagStore, manager: InputSourceManager, updateChecker: UpdateChecker) {
        self.settings = settings
        self.flagStore = flagStore
        self.manager = manager
        self.updateChecker = updateChecker
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
            manager: manager,
            updateChecker: updateChecker
        )
        let hostingView = NSHostingView(rootView: settingsView)

        let size = FlangSpacing.settingsWindowSize
        let newWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: size.width, height: size.height),
            styleMask: [.titled, .closable, .miniaturizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        // No title bar chrome: the sidebar draws its own "Flang" wordmark, and
        // the content view extends under where the title bar would be so the
        // traffic lights sit directly on the sidebar's own background.
        newWindow.titlebarAppearsTransparent = true
        newWindow.titleVisibility = .hidden
        newWindow.contentView = hostingView
        newWindow.isReleasedWhenClosed = false
        newWindow.center()
        newWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        window = newWindow
    }
}
