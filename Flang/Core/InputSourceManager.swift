//
//  InputSourceManager.swift
//  Flang
//
//  Created by e1ernal on 24.05.2025.
//

import AppKit
import Carbon
import os

/// Unified logging for input-source handling (visible in Console.app / `log stream`).
private let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier ?? "Flang",
    category: "InputSource"
)

/// A single keyboard input source (layout or input method), reduced to what Flang shows.
struct InputSource {
    /// Stable Source ID, e.g. "com.apple.keylayout.ABC". Used for switching.
    let id: String
    /// Localized display name, e.g. "ABC" or "Spanish".
    let name: String
    let isSelected: Bool
    /// Most representative language first; used by `FlagStore`'s country fallback.
    let languages: [String]
    /// URL of the source's system icon. Kept as a URL, not an image, so
    /// building sources stays cheap — `FlagStore` loads it lazily if needed.
    let systemIconURL: URL?

    /// macOS has no public API for the menu-bar abbreviation, so this
    /// approximates one: short names pass through as-is, otherwise the
    /// primary language subtag uppercased ("Spanish" -> "ES"), falling back
    /// to a prefix of the name. Users can override it per-source.
    var shortName: String {
        if name.count <= 4 {
            return name
        }
        if let language = languages.first, !language.isEmpty {
            let base = language.split(separator: "-").first.map(String.init) ?? language
            return base.uppercased()
        }
        return String(name.prefix(3)).uppercased()
    }
}

/// Notified when the active source or the set of enabled sources changes.
protocol InputSourceMonitoring: AnyObject {
    func selectedInputSourceDidChange()
    func enabledInputSourcesDidChange()
}

/// The only place in the app that talks to the Carbon Text Input Sources (TIS)
/// API. `ObservableObject` so the SwiftUI Settings window can refresh its
/// source list live, alongside the AppKit menu's `InputSourceMonitoring` delegate.
final class InputSourceManager: ObservableObject {
    weak var delegate: InputSourceMonitoring?

    private let notificationCenter: CFNotificationCenter

    init() {
        notificationCenter = CFNotificationCenterGetDistributedCenter()
        registerForNotifications()
        registerForActivationRefresh()
    }

    deinit {
        CFNotificationCenterRemoveEveryObserver(
            notificationCenter,
            Unmanaged.passUnretained(self).toOpaque()
        )
    }

    /// The currently active input source, or nil if the system value can't be read.
    var currentInputSource: InputSource? {
        guard let source = TISCopyCurrentKeyboardInputSource()?.takeRetainedValue() else {
            return nil
        }
        return makeInputSource(from: source, currentID: source.id)
    }

    /// All enabled, selectable keyboard input sources, in system order.
    var inputSources: [InputSource] {
        let currentID = TISCopyCurrentKeyboardInputSource()?.takeRetainedValue().id
        guard let list = TISCreateInputSourceList(nil, false)?.takeRetainedValue() as? [TISInputSource] else {
            return []
        }
        let all = list
            .filter {
                $0.category == kTISCategoryKeyboardInputSource as String
                    && $0.isSelectable
                    && $0.isEnabled
            }
            // The bulk list can keep listing a source for a while after it's
            // deleted in System Settings, so cross-check each one with a
            // filtered single-ID query, which reflects deletions promptly.
            .filter { source in
                guard let id = source.id else { return false }
                return isActuallyEnabled(id: id)
            }
            .compactMap { makeInputSource(from: $0, currentID: currentID) }

        // Collapse sources that share a localized name (e.g. two Japanese
        // input methods both shown as "Hiragana"), preferring the selected
        // variant so the active source keeps its checkmark.
        var order: [String] = []
        var byName: [String: InputSource] = [:]
        for source in all {
            if let existing = byName[source.name] {
                if source.isSelected && !existing.isSelected {
                    byName[source.name] = source
                }
            } else {
                byName[source.name] = source
                order.append(source.name)
            }
        }
        return order.compactMap { byName[$0] }
    }

    /// Switch the system to the input source with the given Source ID. No-op if not found.
    func selectInputSource(id: String) {
        guard let list = TISCreateInputSourceList(nil, false)?.takeRetainedValue() as? [TISInputSource],
              let match = list.first(where: { $0.id == id }) else {
            return
        }
        let status = TISSelectInputSource(match)
        if status != noErr {
            logger.error("Failed to switch to input source \(id, privacy: .public): OSStatus \(status)")
        }
    }

    /// Whether an installed (not necessarily enabled) source exists — used to
    /// detect Keyboard Viewer on macOS versions where it's a palette source
    /// that isn't in the enabled list.
    func isSourceAvailable(id: String) -> Bool {
        installedSource(id: id) != nil
    }

    /// Opens System Settings → Keyboard → Input Sources, where macOS handles
    /// adding and removing input sources directly.
    static func openSystemKeyboardSettings() {
        guard let url = URL(string: "x-apple.systempreferences:com.apple.Keyboard-Settings.extension") else { return }
        NSWorkspace.shared.open(url)
    }

    /// Activate an enabled source by id — used for the Keyboard Viewer palette source.
    func activateSource(id: String) {
        guard let source = enabledSource(id: id) ?? installedSource(id: id) else { return }
        let status = TISSelectInputSource(source)
        if status != noErr {
            logger.error("Failed to activate source \(id, privacy: .public): OSStatus \(status)")
        }
    }

    /// Look up a source among the enabled ones. Deliberately not the unfiltered
    /// `(nil, true)` query — that re-enables every installed source as a side
    /// effect, which made removed layouts reappear in the menu.
    private func enabledSource(id: String) -> TISInputSource? {
        guard let list = TISCreateInputSourceList(nil, false)?.takeRetainedValue() as? [TISInputSource] else {
            return nil
        }
        return list.first { $0.id == id }
    }

    /// Look up a source among all installed sources, including disabled ones.
    /// Filtering by a specific ID avoids the mass re-enable side effect an
    /// unfiltered `(nil, true)` query would have.
    private func installedSource(id: String) -> TISInputSource? {
        let filter = [kTISPropertyInputSourceID: id] as CFDictionary
        guard let list = TISCreateInputSourceList(filter, true)?.takeRetainedValue() as? [TISInputSource] else {
            return nil
        }
        return list.first
    }

    /// Filtered single-ID re-check of a source the bulk list just returned.
    /// Unlike that bulk query, this reflects a just-deleted source promptly.
    private func isActuallyEnabled(id: String) -> Bool {
        installedSource(id: id)?.isEnabled ?? false
    }

    /// The system icon of an enabled or installed source, for parity menu items.
    func icon(forSourceID id: String) -> NSImage? {
        guard let source = enabledSource(id: id) ?? installedSource(id: id),
              let url = source.iconImageURL else { return nil }
        return NSImage(contentsOf: url)
    }

    /// Build an `InputSource`; returns nil when a source lacks an id or name.
    private func makeInputSource(from source: TISInputSource, currentID: String?) -> InputSource? {
        guard let id = source.id, let name = source.name else { return nil }
        return InputSource(
            id: id,
            name: name,
            isSelected: id == currentID,
            languages: source.languages,
            systemIconURL: source.iconImageURL
        )
    }

    /// `kTISNotifyEnabledKeyboardInputSourcesChanged` can arrive slightly
    /// before TIS's own list catches up, so retry shortly after — deletions
    /// seem to settle slower than a plain enable/disable, hence two retries.
    private func notifyEnabledSourcesChanged() {
        delegate?.enabledInputSourcesDidChange()
        objectWillChange.send()
        for delay in [0.3, 1.5] {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                guard let self else { return }
                self.delegate?.enabledInputSourcesDidChange()
                self.objectWillChange.send()
            }
        }
    }

    /// Deleting a source outright doesn't reliably trigger the TIS
    /// notification the way disabling one does, so also refresh whenever
    /// Flang regains focus — the common flow after a System Settings change.
    private func registerForActivationRefresh() {
        NotificationCenter.default.addObserver(
            forName: NSApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.notifyEnabledSourcesChanged()
        }
    }

    private func registerForNotifications() {
        let observer = Unmanaged.passUnretained(self).toOpaque()
        let selected = kTISNotifySelectedKeyboardInputSourceChanged as String
        let enabled = kTISNotifyEnabledKeyboardInputSourcesChanged as String

        let callback: CFNotificationCallback = { _, observer, name, _, _ in
            guard let observer, let rawName = name?.rawValue as String? else { return }
            let manager = Unmanaged<InputSourceManager>.fromOpaque(observer).takeUnretainedValue()
            DispatchQueue.main.async {
                if rawName == (kTISNotifySelectedKeyboardInputSourceChanged as String) {
                    manager.delegate?.selectedInputSourceDidChange()
                    manager.objectWillChange.send()
                } else if rawName == (kTISNotifyEnabledKeyboardInputSourcesChanged as String) {
                    manager.notifyEnabledSourcesChanged()
                }
            }
        }

        for notification in [selected, enabled] {
            CFNotificationCenterAddObserver(
                notificationCenter,
                observer,
                callback,
                notification as CFString,
                nil,
                .deliverImmediately
            )
        }
    }
}

// MARK: - Safe TISInputSource accessors

private extension TISInputSource {
    /// Read a TIS property and bridge it to `T`, returning nil instead of crashing
    /// on a missing value or an unexpected type.
    func property<T>(_ key: CFString, as type: T.Type) -> T? {
        guard let pointer = TISGetInputSourceProperty(self, key) else { return nil }
        return Unmanaged<AnyObject>.fromOpaque(pointer).takeUnretainedValue() as? T
    }

    var id: String? { property(kTISPropertyInputSourceID, as: String.self) }
    var name: String? { property(kTISPropertyLocalizedName, as: String.self) }
    var category: String? { property(kTISPropertyInputSourceCategory, as: String.self) }
    var isSelectable: Bool { property(kTISPropertyInputSourceIsSelectCapable, as: Bool.self) ?? false }
    var isEnabled: Bool { property(kTISPropertyInputSourceIsEnabled, as: Bool.self) ?? false }
    var languages: [String] { property(kTISPropertyInputSourceLanguages, as: [String].self) ?? [] }

    /// URL of the source's icon (`kTISPropertyIconImageURL`), if the system provides one.
    /// The image itself is loaded lazily by `FlagStore` only when needed.
    var iconImageURL: URL? { property(kTISPropertyIconImageURL, as: URL.self) }
}
