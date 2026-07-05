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
    private let settings = SettingsStore()

    /// Longest full-name text shown in the indicator before it is ellipsized
    /// (SPEC section 5: styles 4/6 cap the indicator width).
    private let maxIndicatorTitleLength = 16

    /// Flag height for the menu bar indicator: the bar's icon area, so the image
    /// isn't upscaled and clipped by the button.
    private var indicatorHeight: CGFloat {
        max(FlagRenderer.menuHeight, NSStatusBar.system.thickness - 4)
    }

    init(manager: InputSourceManager) {
        self.manager = manager
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        super.init()

        // Never enlarge the flag to fill the button (which cropped tall/light flags);
        // only shrink to fit, preserving aspect ratio.
        statusItem.button?.imageScaling = .scaleProportionallyDown

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
    private func indicatorStyleChanged(_ sender: NSMenuItem) {
        guard let raw = sender.representedObject as? String,
              let style = SettingsStore.IndicatorStyle(rawValue: raw) else { return }
        settings.indicatorStyle = style
        rebuildMenu()
        updateIndicator(for: manager.currentInputSource)
    }

    @objc
    private func flagModeChanged(_ sender: NSMenuItem) {
        guard let raw = sender.representedObject as? String,
              let mode = FlagStore.Mode(rawValue: raw) else { return }
        settings.flagMode = mode
        rebuildMenu()
        updateIndicator(for: manager.currentInputSource)
    }

    @objc
    private func quitClicked() {
        NSApplication.shared.terminate(nil)
    }

    // MARK: - UI updates

    /// Refresh the menu bar indicator for the active source in the selected style
    /// (FR-4). Leaves the indicator untouched when the source can't be read (`nil`).
    private func updateIndicator(for source: InputSource?) {
        guard let button = statusItem.button else { return }
        guard let source else { return }

        let mode = settings.flagMode
        button.image = nil
        button.title = ""

        switch settings.indicatorStyle {
        case .system:
            if let icon = flagStore.systemIcon(for: source, height: indicatorHeight) {
                setIndicator(button, image: icon, title: nil, source: source)
            } else {
                // No system icon (most keyboard layouts): the abbreviation is the
                // closest match to what macOS shows.
                setIndicator(button, image: nil, title: source.shortName, source: source)
            }
        case .flag:
            let flag = flagStore.image(for: source, mode: mode, height: indicatorHeight)
            setIndicator(button, image: flag, title: nil, source: source)
        case .flagShort:
            let flag = flagStore.image(for: source, mode: mode, height: indicatorHeight)
            setIndicator(button, image: flag, title: source.shortName, source: source)
        case .flagFull:
            let flag = flagStore.image(for: source, mode: mode, height: indicatorHeight)
            setIndicator(button, image: flag, title: truncated(source.name), source: source)
        case .short:
            setIndicator(button, image: nil, title: source.shortName, source: source)
        case .full:
            setIndicator(button, image: nil, title: truncated(source.name), source: source)
        }
    }

    private func setIndicator(_ button: NSStatusBarButton, image: NSImage?, title: String?, source: InputSource) {
        image?.accessibilityDescription = source.name
        button.image = image
        button.title = title ?? ""
        if image != nil && title != nil {
            button.imagePosition = .imageLeading
        } else if image != nil {
            button.imagePosition = .imageOnly
        } else {
            button.imagePosition = .noImage
        }
    }

    /// Truncate long text with a middle-less tail ellipsis for the indicator.
    private func truncated(_ text: String) -> String {
        guard text.count > maxIndicatorTitleLength else { return text }
        return String(text.prefix(maxIndicatorTitleLength - 1)) + "…"
    }

    /// Rebuild the whole menu. Menu items always show flag + full name regardless
    /// of the indicator style (FR-2).
    private func rebuildMenu() {
        let menu = NSMenu()

        for source in manager.inputSources {
            let item = NSMenuItem(
                title: source.name,
                action: #selector(inputSourceItemClicked(_:)),
                keyEquivalent: ""
            )
            item.target = self
            item.image = flagStore.image(for: source, mode: settings.flagMode, height: FlagRenderer.menuHeight)
            item.representedObject = source.id
            item.state = source.isSelected ? .on : .off
            item.toolTip = source.name
            menu.addItem(item)
        }

        menu.addItem(.separator())
        menu.addItem(makeIndicatorStyleItem())
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

    /// Temporary indicator-style switcher; moves into the Settings window in Phase 4.
    private func makeIndicatorStyleItem() -> NSMenuItem {
        let options: [(style: SettingsStore.IndicatorStyle, title: String)] = [
            (.system, "System"),
            (.flag, "Flag"),
            (.flagShort, "Flag + short name"),
            (.flagFull, "Flag + full name"),
            (.short, "Short name"),
            (.full, "Full name")
        ]
        let submenu = NSMenu()
        for option in options {
            let item = NSMenuItem(
                title: option.title,
                action: #selector(indicatorStyleChanged(_:)),
                keyEquivalent: ""
            )
            item.target = self
            item.representedObject = option.style.rawValue
            item.state = (option.style == settings.indicatorStyle) ? .on : .off
            submenu.addItem(item)
        }
        let parent = NSMenuItem(title: "Indicator Style (temporary)", action: nil, keyEquivalent: "")
        parent.submenu = submenu
        return parent
    }

    /// Temporary flag-mode switcher; moves into the Settings window in Phase 4.
    private func makeFlagModeItem() -> NSMenuItem {
        let options: [(mode: FlagStore.Mode, title: String)] = [
            (.images, "Images"),
            (.emoji, "Emoji")
        ]
        let submenu = NSMenu()
        for option in options {
            let item = NSMenuItem(
                title: option.title,
                action: #selector(flagModeChanged(_:)),
                keyEquivalent: ""
            )
            item.target = self
            item.representedObject = option.mode.rawValue
            item.state = (option.mode == settings.flagMode) ? .on : .off
            submenu.addItem(item)
        }
        let parent = NSMenuItem(title: "Flag Mode (temporary)", action: nil, keyEquivalent: "")
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
