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
    private let flagStore = FlagStore()

    /// Temporary flag-mode storage until the Settings window arrives in Phase 4.
    private let flagModeDefaultsKey = "TemporaryFlagMode"
    private var flagMode: FlagStore.Mode {
        get {
            let raw = UserDefaults.standard.string(forKey: flagModeDefaultsKey)
            return raw.flatMap(FlagStore.Mode.init(rawValue:)) ?? .images
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: flagModeDefaultsKey)
        }
    }

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
    private func flagModeChanged(_ sender: NSMenuItem) {
        guard let raw = sender.representedObject as? String,
              let mode = FlagStore.Mode(rawValue: raw) else { return }
        flagMode = mode
        rebuildMenu()
        updateIndicator(for: manager.currentInputSource)
    }

    @objc
    private func quitClicked() {
        NSApplication.shared.terminate(nil)
    }

    // MARK: - UI updates

    /// Refresh the menu bar indicator to show the given active source's flag.
    /// Leaves the indicator untouched when the source can't be read (`nil`).
    private func updateIndicator(for source: InputSource?) {
        guard let button = statusItem.button else { return }
        guard let source else { return }
        let image = flagStore.menuBarImage(for: source, mode: flagMode)
        image.accessibilityDescription = source.name
        button.image = image
        button.imagePosition = .imageOnly
        button.title = ""
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
            item.image = flagStore.menuBarImage(for: source, mode: flagMode)
            item.representedObject = source.id
            item.state = source.isSelected ? .on : .off
            menu.addItem(item)
        }

        menu.addItem(.separator())
        menu.addItem(makeFlagModeItem())
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

    /// Temporary flag-mode switcher; moves into the Settings window in Phase 4.
    private func makeFlagModeItem() -> NSMenuItem {
        let submenu = NSMenu()
        let options: [(mode: FlagStore.Mode, title: String)] = [
            (.images, "Images"),
            (.emoji, "Emoji")
        ]
        for option in options {
            let item = NSMenuItem(
                title: option.title,
                action: #selector(flagModeChanged(_:)),
                keyEquivalent: ""
            )
            item.target = self
            item.representedObject = option.mode.rawValue
            item.state = (option.mode == flagMode) ? .on : .off
            submenu.addItem(item)
        }
        let parent = NSMenuItem(title: "Flag Style (temporary)", action: nil, keyEquivalent: "")
        parent.submenu = submenu
        return parent
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
