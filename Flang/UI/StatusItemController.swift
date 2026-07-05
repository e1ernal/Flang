//
//  StatusItemController.swift
//  Flang
//
//  Created by e1ernal on 05.07.2026.
//

import AppKit

/// Owns the menu bar item: its indicator, the drop-down menu, and switching sources.
/// Reacts to system changes through `InputSourceMonitoring`.
final class StatusItemController: NSObject {
    private let statusItem: NSStatusItem
    private let manager: InputSourceManager

    init(manager: InputSourceManager) {
        self.manager = manager
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        super.init()

        manager.delegate = self
        rebuildMenu()
        updateIndicator(for: manager.currentInputSource)
    }

    // MARK: - Actions

    @objc
    private func inputSourceItemClicked(_ sender: NSMenuItem) {
        // The Source ID travels with the menu item, so switching never depends on the title.
        guard let id = sender.representedObject as? String else { return }
        manager.selectInputSource(id: id)
    }

    @objc
    private func quitClicked() {
        NSApplication.shared.terminate(nil)
    }

    // MARK: - UI updates

    /// Refresh the menu bar indicator to show the given active source.
    /// Leaves the indicator untouched when the source can't be read (`nil`).
    private func updateIndicator(for source: InputSource?) {
        guard let button = statusItem.button else { return }
        guard let source else { return }
        button.title = source.name
        button.image = source.image
    }

    /// Rebuild the whole menu from the current list of enabled sources.
    private func rebuildMenu() {
        let menu = NSMenu()

        for source in manager.inputSources {
            let item = NSMenuItem(
                title: source.name,
                action: #selector(inputSourceItemClicked(_:)),
                keyEquivalent: ""
            )
            item.target = self
            item.image = source.image
            item.representedObject = source.id
            item.state = source.isSelected ? .on : .off
            menu.addItem(item)
        }

        menu.addItem(.separator())

        let quitItem = NSMenuItem(
            title: "Quit Flang",
            action: #selector(quitClicked),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    /// Move the checkmark to the active source without rebuilding the menu.
    private func updateMenuSelection(currentID: String?) {
        guard let menu = statusItem.menu else { return }
        for item in menu.items {
            guard let id = item.representedObject as? String else { continue }
            item.state = (id == currentID) ? .on : .off
        }
    }
}

// MARK: - InputSourceMonitoring

extension StatusItemController: InputSourceMonitoring {
    func selectedInputSourceDidChange() {
        // Read the current source once and reuse it for both UI updates.
        let current = manager.currentInputSource
        updateIndicator(for: current)
        updateMenuSelection(currentID: current?.id)
    }

    func enabledInputSourcesDidChange() {
        rebuildMenu()
        updateIndicator(for: manager.currentInputSource)
    }
}
