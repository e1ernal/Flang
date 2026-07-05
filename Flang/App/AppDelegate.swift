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
    private var statusItemController: StatusItemController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItemController = StatusItemController(manager: inputSourceManager)
    }
}
