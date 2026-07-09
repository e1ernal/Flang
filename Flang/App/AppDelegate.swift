//
//  AppDelegate.swift
//  Flang
//
//  Created by e1ernal on 21.05.2025.
//

import AppKit

/// Application lifecycle only. All menu bar UI lives in `StatusItemController`.
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let inputSourceManager = InputSourceManager()
    private let settings = SettingsStore()
    private var statusItemController: StatusItemController?
    private var settingsWindowController: SettingsWindowController?
    private var firstLaunchWindowController: FirstLaunchWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        settings.load()
        let controller = StatusItemController(
            manager: inputSourceManager,
            settings: settings
        )
        statusItemController = controller
        settingsWindowController = SettingsWindowController(
            settings: settings,
            flagStore: controller.flagStore,
            manager: inputSourceManager
        )
        controller.onOpenSettings = { [weak self] in
            self?.settingsWindowController?.showWindow()
        }

        if !settings.hasLaunchedBefore {
            settings.launchAtLogin = true
            settings.markAsLaunched()
            firstLaunchWindowController = FirstLaunchWindowController()
            firstLaunchWindowController?.showWindow()
        }
    }
}
