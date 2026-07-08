//
//  SettingsStore.swift
//  Flang
//
//  Created by e1ernal on 05.07.2026.
//

import Foundation

/// Persists user preferences in `UserDefaults` (SPEC 8). The indicator is composed
/// from two independent settings (FR-4): a flag part and a name part.
final class SettingsStore {
    /// Flag part of the indicator (FR-4). "none" hides the flag.
    enum FlagSetting: String, CaseIterable {
        case image
        case emoji
        case none
    }

    /// Name part of the indicator (FR-4). "none" hides the name.
    enum NameSetting: String, CaseIterable {
        case short
        case full
        case none
    }

    private let defaults: UserDefaults
    private let flagKey = "FlagSetting"
    private let nameKey = "NameSetting"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    /// How the flag is shown in the indicator; defaults to a picture flag (FR-4).
    var flagSetting: FlagSetting {
        get { defaults.string(forKey: flagKey).flatMap(FlagSetting.init) ?? .image }
        set { defaults.set(newValue.rawValue, forKey: flagKey) }
    }

    /// How the source name is shown in the indicator; defaults to hidden (FR-4).
    var nameSetting: NameSetting {
        get { defaults.string(forKey: nameKey).flatMap(NameSetting.init) ?? .none }
        set { defaults.set(newValue.rawValue, forKey: nameKey) }
    }

    /// The flag render mode for the menu rows, which always show a flag: emoji when
    /// the flag setting is emoji, otherwise pictures (FR-2).
    var menuFlagMode: FlagStore.Mode {
        flagSetting == .emoji ? .emoji : .images
    }
}
