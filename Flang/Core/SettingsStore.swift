//
//  SettingsStore.swift
//  Flang
//
//  Created by e1ernal on 05.07.2026.
//

import Combine
import Foundation
import ServiceManagement

/// Persists user preferences in `UserDefaults` (SPEC 8). The indicator is composed
/// from two independent settings (FR-4): a flag part and a name part.
final class SettingsStore: ObservableObject {
    /// Flag part of the indicator (FR-4). "none" hides the flag.
    enum FlagSetting: String, CaseIterable, Identifiable {
        case image, emoji, none
        var id: String { rawValue }
        var title: String {
            switch self {
            case .image: return "Image"
            case .emoji: return "Emoji"
            case .none: return "None"
            }
        }
    }

    /// Name part of the indicator (FR-4). "none" hides the name.
    enum NameSetting: String, CaseIterable, Identifiable {
        case short, full, none
        var id: String { rawValue }
        var title: String {
            switch self {
            case .short: return "Short"
            case .full: return "Full"
            case .none: return "None"
            }
        }
    }

    static let didChange = Notification.Name("SettingsStoreDidChange")

    private let defaults: UserDefaults
    private let flagKey = "FlagSetting"
    private let nameKey = "NameSetting"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    /// How the flag is shown in the indicator; defaults to a picture flag (FR-4).
    @Published var flagSetting: FlagSetting = .image {
        didSet {
            defaults.set(flagSetting.rawValue, forKey: flagKey)
            NotificationCenter.default.post(name: Self.didChange, object: self)
        }
    }

    /// How the source name is shown in the indicator; defaults to hidden (FR-4).
    @Published var nameSetting: NameSetting = .none {
        didSet {
            defaults.set(nameSetting.rawValue, forKey: nameKey)
            NotificationCenter.default.post(name: Self.didChange, object: self)
        }
    }

    /// The flag render mode for the menu rows, which always show a flag: emoji when
    /// the flag setting is emoji, otherwise pictures (FR-2).
    var menuFlagMode: FlagStore.Mode {
        flagSetting == .emoji ? .emoji : .images
    }

    // MARK: - Launch at Login (FR-9)

    var launchAtLogin: Bool {
        get { SMAppService.mainApp.status == .enabled }
        set {
            objectWillChange.send()
            do {
                if newValue {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch { /* System Settings controls this too; silently accept */ }
        }
    }

    /// Load persisted values; called once at startup.
    func load() {
        flagSetting = defaults.string(forKey: flagKey).flatMap(FlagSetting.init) ?? .image
        nameSetting = defaults.string(forKey: nameKey).flatMap(NameSetting.init) ?? .none
    }
}
