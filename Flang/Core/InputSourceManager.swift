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
    /// Whether this source is the currently active one.
    let isSelected: Bool
    /// Input languages, most representative first (`kTISPropertyInputSourceLanguages`).
    /// Used by `FlagStore` for the language -> country fallback (FR-6, step 3).
    let languages: [String]
    /// The source's own system icon, used as a last-resort fallback flag (FR-3).
    let systemIcon: NSImage?
}

/// Delegate notified when the active source or the set of enabled sources changes.
/// `AnyObject` + `weak` reference below break the retain cycle with the owner.
protocol InputSourceMonitoring: AnyObject {
    /// The active input source changed (hotkey, menu, automatic switch, or Flang itself).
    func selectedInputSourceDidChange()
    /// The list of enabled input sources changed (added/removed in System Settings).
    func enabledInputSourcesDidChange()
}

/// The only place in the app that talks to the Carbon Text Input Sources (TIS) API.
final class InputSourceManager {
    weak var delegate: InputSourceMonitoring?

    private let notificationCenter: CFNotificationCenter

    init() {
        notificationCenter = CFNotificationCenterGetDistributedCenter()
        registerForNotifications()
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
        return list
            .filter { $0.category == kTISCategoryKeyboardInputSource as String && $0.isSelectable }
            .compactMap { makeInputSource(from: $0, currentID: currentID) }
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

    /// Build an `InputSource`; returns nil when a source lacks an id or name.
    private func makeInputSource(from source: TISInputSource, currentID: String?) -> InputSource? {
        guard let id = source.id, let name = source.name else { return nil }
        return InputSource(
            id: id,
            name: name,
            isSelected: id == currentID,
            languages: source.languages,
            systemIcon: source.systemIcon
        )
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
                } else if rawName == (kTISNotifyEnabledKeyboardInputSourcesChanged as String) {
                    manager.delegate?.enabledInputSourcesDidChange()
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
    var languages: [String] { property(kTISPropertyInputSourceLanguages, as: [String].self) ?? [] }

    /// The source's icon loaded from `kTISPropertyIconImageURL`, if the system provides one.
    var systemIcon: NSImage? {
        guard let url = property(kTISPropertyIconImageURL, as: URL.self) else { return nil }
        return NSImage(contentsOf: url)
    }
}
