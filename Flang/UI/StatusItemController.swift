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

    /// Palette input source that opens the Keyboard Viewer window.
    private let keyboardViewerID = "com.apple.KeyboardViewer"

    /// Longest full-name text shown in the indicator before it is ellipsized
    /// (SPEC section 5: cap the indicator width).
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
    private func flagSettingChanged(_ sender: NSMenuItem) {
        guard let raw = sender.representedObject as? String,
              let value = SettingsStore.FlagSetting(rawValue: raw) else { return }
        settings.flagSetting = value
        rebuildMenu()
        updateIndicator(for: manager.currentInputSource)
    }

    @objc
    private func nameSettingChanged(_ sender: NSMenuItem) {
        guard let raw = sender.representedObject as? String,
              let value = SettingsStore.NameSetting(rawValue: raw) else { return }
        settings.nameSetting = value
        rebuildMenu()
        updateIndicator(for: manager.currentInputSource)
    }

    @objc private func showEmojiSymbols() {
        NSApp.orderFrontCharacterPalette(nil)
    }

    @objc private func showKeyboardViewer() {
        manager.activateSource(id: keyboardViewerID)
    }

    @objc private func editTextSubstitutions() {
        // Deep link to Text Replacements; System Settings falls back to the Keyboard
        // pane when the anchor is unknown on this macOS (FR-2 degradation).
        openSystemSettings(anchor: "com.apple.Keyboard-Settings.extension?TextReplacement")
    }

    @objc private func openKeyboardSettings() {
        openSystemSettings(anchor: "com.apple.Keyboard-Settings.extension")
    }

    @objc private func quitClicked() {
        NSApplication.shared.terminate(nil)
    }

    private func openSystemSettings(anchor: String) {
        guard let url = URL(string: "x-apple.systempreferences:\(anchor)") else { return }
        NSWorkspace.shared.open(url)
    }

    // MARK: - Indicator (FR-4)

    /// Refresh the menu bar indicator for the active source, composed from the flag
    /// and name settings (FR-4). Leaves it untouched when the source can't be read.
    private func updateIndicator(for source: InputSource?) {
        guard let button = statusItem.button, let source else { return }
        let flag = flagImage(for: source)
        let name = nameText(for: source)

        if flag == nil && name == nil {
            // "None" + "None": show the source's system icon ("like Apple"); the
            // indicator is never empty. If there is no icon, fall back to the
            // abbreviation, which is what macOS itself shows.
            let icon = flagStore.systemIcon(for: source, height: indicatorHeight)
            setIndicator(button, image: icon, title: icon == nil ? source.shortName : nil, source: source)
        } else {
            setIndicator(button, image: flag, title: name, source: source)
        }
    }

    private func flagImage(for source: InputSource) -> NSImage? {
        switch settings.flagSetting {
        case .image: return flagStore.image(for: source, mode: .images, height: indicatorHeight)
        case .emoji: return flagStore.image(for: source, mode: .emoji, height: indicatorHeight)
        case .none: return nil
        }
    }

    private func nameText(for source: InputSource) -> String? {
        switch settings.nameSetting {
        case .short: return source.shortName
        case .full: return truncated(source.name)
        case .none: return nil
        }
    }

    private func setIndicator(_ button: NSStatusBarButton, image: NSImage?, title: String?, source: InputSource) {
        image?.accessibilityDescription = source.name
        button.image = image
        button.title = title ?? ""
        // The full name is always reachable on hover (SPEC section 5).
        button.toolTip = source.name
        if image != nil && title != nil {
            button.imagePosition = .imageLeading
        } else if image != nil {
            button.imagePosition = .imageOnly
        } else {
            button.imagePosition = .noImage
        }
    }

    /// Truncate long text with a middle ellipsis (SPEC section 5: "посередине").
    private func truncated(_ text: String) -> String {
        guard text.count > maxIndicatorTitleLength else { return text }
        let kept = maxIndicatorTitleLength - 1
        let head = kept - kept / 2
        let tail = kept / 2
        return text.prefix(head) + "…" + text.suffix(tail)
    }

    // MARK: - Menu (FR-2, FR-5)

    /// Rebuild the whole menu: the app submenu ("…"), the input sources, and the
    /// system-parity block. Menu rows always show flag + full name (FR-2).
    private func rebuildMenu() {
        let menu = NSMenu()

        menu.addItem(makeAppSubmenuItem())
        menu.addItem(.separator())

        let menuMode = settings.menuFlagMode
        for source in manager.inputSources {
            let item = NSMenuItem(
                title: source.name,
                action: #selector(inputSourceItemClicked(_:)),
                keyEquivalent: ""
            )
            item.target = self
            item.image = flagStore.image(for: source, mode: menuMode, height: FlagRenderer.menuHeight)
            item.representedObject = source.id
            item.state = source.isSelected ? .on : .off
            item.toolTip = source.name
            menu.addItem(item)
        }

        menu.addItem(.separator())
        for item in makeParityItems() {
            menu.addItem(item)
        }

        statusItem.menu = menu
    }

    /// The "…" app submenu (FR-5): flag and name settings, then Quit. The Settings
    /// window entry is added in Phase 4b once the window exists.
    private func makeAppSubmenuItem() -> NSMenuItem {
        let submenu = NSMenu()
        submenu.addItem(makeFlagSettingItem())
        submenu.addItem(makeNameSettingItem())
        submenu.addItem(.separator())

        let quitItem = NSMenuItem(title: "Quit Flang", action: #selector(quitClicked), keyEquivalent: "q")
        quitItem.target = self
        submenu.addItem(quitItem)

        let parent = NSMenuItem()
        parent.attributedTitle = NSAttributedString(
            string: "…",
            attributes: [.foregroundColor: NSColor.secondaryLabelColor]
        )
        parent.submenu = submenu
        return parent
    }

    private func makeFlagSettingItem() -> NSMenuItem {
        let options: [(value: SettingsStore.FlagSetting, title: String)] = [
            (.image, "Image"),
            (.emoji, "Emoji"),
            (.none, "None")
        ]
        let current = options.first { $0.value == settings.flagSetting }?.title ?? ""
        let submenu = NSMenu()
        for option in options {
            let item = NSMenuItem(title: option.title, action: #selector(flagSettingChanged(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = option.value.rawValue
            item.state = (option.value == settings.flagSetting) ? .on : .off
            submenu.addItem(item)
        }
        let parent = NSMenuItem()
        parent.attributedTitle = menuTitle("Flag", value: current)
        parent.submenu = submenu
        return parent
    }

    private func makeNameSettingItem() -> NSMenuItem {
        let options: [(value: SettingsStore.NameSetting, title: String)] = [
            (.short, "Short"),
            (.full, "Full"),
            (.none, "None")
        ]
        let current = options.first { $0.value == settings.nameSetting }?.title ?? ""
        let submenu = NSMenu()
        for option in options {
            let item = NSMenuItem(title: option.title, action: #selector(nameSettingChanged(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = option.value.rawValue
            item.state = (option.value == settings.nameSetting) ? .on : .off
            submenu.addItem(item)
        }
        let parent = NSMenuItem()
        parent.attributedTitle = menuTitle("Name", value: current)
        parent.submenu = submenu
        return parent
    }

    /// A menu title with the current value right-aligned in gray, like system menus
    /// (FR-5), so the choice is visible without opening the submenu.
    private func menuTitle(_ label: String, value: String) -> NSAttributedString {
        let paragraph = NSMutableParagraphStyle()
        paragraph.tabStops = [NSTextTab(textAlignment: .right, location: 150)]
        let result = NSMutableAttributedString(string: label + "\t", attributes: [.paragraphStyle: paragraph])
        result.append(NSAttributedString(
            string: value,
            attributes: [.foregroundColor: NSColor.secondaryLabelColor, .paragraphStyle: paragraph]
        ))
        return result
    }

    /// The bottom parity block (FR-2): same names and actions as the system menu.
    /// Items whose mechanism is unavailable on this macOS are hidden (degradation).
    private func makeParityItems() -> [NSMenuItem] {
        var items: [NSMenuItem] = []

        items.append(makeActionItem("Show Emoji & Symbols", #selector(showEmojiSymbols)))
        if manager.isSourceInstalled(id: keyboardViewerID) {
            items.append(makeActionItem("Show Keyboard Viewer", #selector(showKeyboardViewer)))
        }
        items.append(makeActionItem("Edit Text Substitutions…", #selector(editTextSubstitutions)))
        items.append(makeActionItem("Open Keyboard Settings…", #selector(openKeyboardSettings)))

        return items
    }

    private func makeActionItem(_ title: String, _ action: Selector) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: "")
        item.target = self
        return item
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
