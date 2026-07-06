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

    /// Palette input sources activated for the parity menu items.
    private let keyboardViewerID = "com.apple.KeyboardViewer"
    private let characterPaletteID = "com.apple.CharacterPaletteIM"

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

        if let button = statusItem.button {
            // Never enlarge the flag to fill the button (which cropped tall/light
            // flags); only shrink to fit, preserving aspect ratio.
            button.imageScaling = .scaleProportionallyDown
            // Handle the click ourselves so left-click opens the main menu and
            // right-click opens the app menu (Quit), instead of a fixed menu.
            button.target = self
            button.action = #selector(statusItemClicked)
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        manager.delegate = self
        updateIndicator(for: manager.currentInputSource)
    }

    // MARK: - Click routing

    @objc private func statusItemClicked() {
        let event = NSApp.currentEvent
        let wantsAppMenu = event?.type == .rightMouseUp
            || (event?.modifierFlags.contains(.control) ?? false)
        showMenu(wantsAppMenu ? buildAppMenu() : buildMainMenu())
    }

    /// Present a menu under the status item, then detach it so the next click routes
    /// back through the button action (left/right detection).
    private func showMenu(_ menu: NSMenu) {
        statusItem.menu = menu
        statusItem.button?.performClick(nil)
        statusItem.menu = nil
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
        updateIndicator(for: manager.currentInputSource)
    }

    @objc
    private func nameSettingChanged(_ sender: NSMenuItem) {
        guard let raw = sender.representedObject as? String,
              let value = SettingsStore.NameSetting(rawValue: raw) else { return }
        settings.nameSetting = value
        updateIndicator(for: manager.currentInputSource)
    }

    @objc private func showEmojiSymbols() {
        // Activating the Character Palette source opens the Emoji & Symbols window
        // system-wide (orderFrontCharacterPalette does nothing for a menu-bar agent).
        manager.activateSource(id: characterPaletteID)
    }

    @objc private func showKeyboardViewer() {
        manager.activateSource(id: keyboardViewerID)
    }

    @objc private func openKeyboardSettings() {
        guard let url = URL(string: "x-apple.systempreferences:com.apple.Keyboard-Settings.extension") else { return }
        NSWorkspace.shared.open(url)
    }

    @objc private func quitClicked() {
        NSApplication.shared.terminate(nil)
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

    // MARK: - Menus (FR-2, FR-5)

    /// The main (left-click) menu: input sources, then the Flag/Name settings, then
    /// the system-parity block. Menu rows always show flag + full name (FR-2).
    private func buildMainMenu() -> NSMenu {
        let menu = NSMenu()
        let sources = manager.inputSources
        let menuMode = settings.menuFlagMode
        let hasKeyboardViewer = manager.isSourceEnabled(id: keyboardViewerID)

        // Right edge for the Flag/Name value, aligned near the submenu arrow like the
        // system menus, computed from the widest item so it hugs the menu's edge.
        let valueEdge = valueRightEdge(sources: sources, hasKeyboardViewer: hasKeyboardViewer)

        for source in sources {
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
        menu.addItem(makeFlagSettingItem(valueEdge: valueEdge))
        menu.addItem(makeNameSettingItem(valueEdge: valueEdge))

        menu.addItem(.separator())
        menu.addItem(makeActionItem(
            "Show Emoji & Symbols",
            #selector(showEmojiSymbols),
            icon: parityIcon(sourceID: characterPaletteID)
        ))
        if hasKeyboardViewer {
            menu.addItem(makeActionItem(
                "Show Keyboard Viewer",
                #selector(showKeyboardViewer),
                icon: parityIcon(sourceID: keyboardViewerID)
            ))
        }
        menu.addItem(.separator())
        menu.addItem(makeActionItem("Open Keyboard Settings…", #selector(openKeyboardSettings)))

        return menu
    }

    /// The app (right-click) menu: application-level items. For now only Quit; the
    /// Settings window entry is added in Phase 4b.
    private func buildAppMenu() -> NSMenu {
        let menu = NSMenu()
        let quitItem = NSMenuItem(title: "Quit Flang", action: #selector(quitClicked), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        return menu
    }

    private func makeFlagSettingItem(valueEdge: CGFloat) -> NSMenuItem {
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
        parent.attributedTitle = menuTitle("Flag", value: current, valueEdge: valueEdge)
        parent.submenu = submenu
        return parent
    }

    private func makeNameSettingItem(valueEdge: CGFloat) -> NSMenuItem {
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
        parent.attributedTitle = menuTitle("Name", value: current, valueEdge: valueEdge)
        parent.submenu = submenu
        return parent
    }

    /// A menu title with the current value right-aligned in gray, just before the
    /// submenu arrow, matching how system menus show a chosen value (FR-5).
    private func menuTitle(_ label: String, value: String, valueEdge: CGFloat) -> NSAttributedString {
        let paragraph = NSMutableParagraphStyle()
        paragraph.tabStops = [NSTextTab(textAlignment: .right, location: valueEdge)]
        let result = NSMutableAttributedString(string: label + "\t", attributes: [.paragraphStyle: paragraph])
        result.append(NSAttributedString(
            string: value,
            attributes: [.foregroundColor: NSColor.secondaryLabelColor, .paragraphStyle: paragraph]
        ))
        return result
    }

    /// Width at which the Flag/Name value is right-aligned: the widest menu row's
    /// text extent, so the value sits at the menu's right edge near the arrow.
    private func valueRightEdge(sources: [InputSource], hasKeyboardViewer: Bool) -> CGFloat {
        let font = NSFont.menuFont(ofSize: 0)
        func width(_ text: String) -> CGFloat {
            (text as NSString).size(withAttributes: [.font: font]).width
        }
        // Approximate leading room (state column + icon) so the value right-aligns
        // hard against the submenu arrow.
        let iconIndent: CGFloat = 44
        var edge: CGFloat = width("Show Emoji & Symbols") + iconIndent
        edge = max(edge, width("Open Keyboard Settings…") + iconIndent)
        if hasKeyboardViewer {
            edge = max(edge, width("Show Keyboard Viewer") + iconIndent)
        }
        for source in sources {
            edge = max(edge, width(source.name) + iconIndent)
        }
        return edge
    }

    private func makeActionItem(_ title: String, _ action: Selector, icon: NSImage? = nil) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: "")
        item.target = self
        item.image = icon
        return item
    }

    /// The source's own macOS icon as a small template glyph, keeping its aspect
    /// ratio (the palette icon is 16x14, so it must not be squished into a square).
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
        // The menu is built on demand at click time, so only the indicator needs
        // refreshing here.
        updateIndicator(for: manager.currentInputSource)
    }
}
