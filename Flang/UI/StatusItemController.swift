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
    let flagStore: FlagStore
    private let settings: SettingsStore

    /// Called when the user picks "Settings…" from the right-click menu.
    var onOpenSettings: (() -> Void)?

    /// Palette input source activated for the Keyboard Viewer parity item.
    private let keyboardViewerID = "com.apple.KeyboardViewer"

    /// Longest full-name text shown in the indicator before it is ellipsized
    /// (SPEC section 5: cap the indicator width).
    private let maxIndicatorTitleLength = 16

    /// Flag height for the menu bar indicator: the bar's icon area, so the image
    /// isn't upscaled and clipped by the button.
    private var indicatorHeight: CGFloat {
        max(FlagRenderer.menuHeight, NSStatusBar.system.thickness - 4)
    }

    /// Whether the menu bar is currently rendering in a dark appearance — used to
    /// pick a contrasting badge color for the "System" indicator style (FR-3).
    /// Read from the status item's own button rather than `NSApp.effectiveAppearance`,
    /// since the menu bar can differ from the app's own appearance ("Auto" menu
    /// bar tinting tied to the desktop picture).
    private var isMenuBarDark: Bool {
        let appearance = statusItem.button?.effectiveAppearance ?? NSApp.effectiveAppearance
        return appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
    }

    init(manager: InputSourceManager, settings: SettingsStore) {
        self.manager = manager
        self.settings = settings
        self.flagStore = FlagStore(settings: settings)
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        super.init()

        if let button = statusItem.button {
            button.imageScaling = .scaleProportionallyDown
            button.target = self
            button.action = #selector(statusItemClicked)
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        manager.delegate = self
        updateIndicator(for: manager.currentInputSource)

        NotificationCenter.default.addObserver(
            self, selector: #selector(settingsDidChange),
            name: SettingsStore.didChange, object: settings
        )
    }

    @objc private func settingsDidChange() {
        updateIndicator(for: manager.currentInputSource)
    }

    // MARK: - Click routing

    @objc private func statusItemClicked() {
        let event = NSApp.currentEvent
        let wantsAppMenu = event?.type == .rightMouseUp
            || (event?.modifierFlags.contains(.control) ?? false)
        showMenu(wantsAppMenu ? buildAppMenu() : buildMainMenu())
    }

    private func showMenu(_ menu: NSMenu) {
        statusItem.menu = menu
        statusItem.button?.performClick(nil)
        statusItem.menu = nil
    }

    // MARK: - Actions

    @objc
    private func inputSourceItemClicked(_ sender: NSMenuItem) {
        guard let id = sender.representedObject as? String else { return }
        manager.selectInputSource(id: id)
    }

    @objc private func openSettings() {
        onOpenSettings?()
    }

    @objc private func showKeyboardViewer() {
        DispatchQueue.main.async { [self] in
            manager.activateSource(id: keyboardViewerID)
        }
    }

    @objc private func openKeyboardSettings() {
        guard let url = URL(string: "x-apple.systempreferences:com.apple.Keyboard-Settings.extension") else { return }
        NSWorkspace.shared.open(url)
    }

    @objc private func quitClicked() {
        NSApplication.shared.terminate(nil)
    }

    // MARK: - Indicator (FR-4)

    private func updateIndicator(for source: InputSource?) {
        guard let button = statusItem.button, let source else { return }
        let flag = flagImage(for: source)
        let name = nameText(for: source)

        if flag == nil && name == nil {
            let icon = flagStore.systemIcon(for: source, height: indicatorHeight, dark: isMenuBarDark)
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
        let custom = settings.customization(for: source.id)
        switch settings.nameSetting {
        case .short: return custom.shortName ?? source.shortName
        case .full: return truncated(custom.fullName ?? source.name)
        case .none: return nil
        }
    }

    private func setIndicator(_ button: NSStatusBarButton, image: NSImage?, title: String?, source: InputSource) {
        // When a title is already shown, the image is decorative — clearing its
        // description keeps VoiceOver from announcing the source name twice.
        image?.accessibilityDescription = title == nil ? source.name : nil
        button.image = image
        button.title = title ?? ""
        button.toolTip = source.name
        if image != nil && title != nil {
            button.imagePosition = .imageLeading
        } else if image != nil {
            button.imagePosition = .imageOnly
        } else {
            button.imagePosition = .noImage
        }
    }

    private func truncated(_ text: String) -> String {
        guard text.count > maxIndicatorTitleLength else { return text }
        let kept = maxIndicatorTitleLength - 1
        let head = kept - kept / 2
        let tail = kept / 2
        return text.prefix(head) + "…" + text.suffix(tail)
    }

    // MARK: - Menus (FR-2, FR-5)

    private func buildMainMenu() -> NSMenu {
        let menu = NSMenu()
        let sources = manager.inputSources
        let menuMode = settings.menuFlagMode

        for source in sources {
            let custom = settings.customization(for: source.id)
            let displayName = custom.fullName ?? source.name
            let item = NSMenuItem(
                title: displayName,
                action: #selector(inputSourceItemClicked(_:)),
                keyEquivalent: ""
            )
            item.target = self
            item.image = flagStore.image(for: source, mode: menuMode, height: FlagRenderer.menuHeight)
            item.representedObject = source.id
            item.state = source.isSelected ? .on : .off
            item.toolTip = displayName
            menu.addItem(item)
        }

        menu.addItem(.separator())
        if manager.isSourceAvailable(id: keyboardViewerID) {
            menu.addItem(makeActionItem(
                String(localized: "Show Keyboard Viewer"),
                #selector(showKeyboardViewer),
                icon: parityIcon(sourceID: keyboardViewerID)
            ))
        }
        menu.addItem(.separator())
        menu.addItem(makeActionItem(String(localized: "Open Keyboard Settings…"), #selector(openKeyboardSettings)))

        return menu
    }

    private func buildAppMenu() -> NSMenu {
        let menu = NSMenu()
        let settingsItem = NSMenuItem(
            title: String(localized: "Settings…"), action: #selector(openSettings), keyEquivalent: ","
        )
        settingsItem.target = self
        menu.addItem(settingsItem)
        menu.addItem(.separator())
        let quitItem = NSMenuItem(
            title: String(localized: "Quit Flang"), action: #selector(quitClicked), keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)
        return menu
    }

    private func makeActionItem(_ title: String, _ action: Selector, icon: NSImage? = nil) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: "")
        item.target = self
        item.image = icon
        return item
    }

    private func parityIcon(sourceID: String) -> NSImage? {
        guard let icon = manager.icon(forSourceID: sourceID) else { return nil }
        let maxHeight = FlagRenderer.menuHeight
        let scale = min(1, maxHeight / max(1, icon.size.height))
        let size = NSSize(width: (icon.size.width * scale).rounded(), height: (icon.size.height * scale).rounded())
        let output = NSImage(size: size)
        output.lockFocus()
        icon.draw(in: NSRect(origin: .zero, size: size))
        output.unlockFocus()
        output.isTemplate = true
        return output
    }
}

// MARK: - InputSourceMonitoring

extension StatusItemController: InputSourceMonitoring {
    func selectedInputSourceDidChange() {
        updateIndicator(for: manager.currentInputSource)
    }

    func enabledInputSourcesDidChange() {
        updateIndicator(for: manager.currentInputSource)
    }
}
