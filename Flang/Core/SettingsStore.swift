//
//  SettingsStore.swift
//  Flang
//
//  Created by e1ernal on 05.07.2026.
//

import Foundation

/// Persists user preferences in `UserDefaults` (SPEC 8). For now: indicator style
/// and flag display mode; personalization (FR-7) is added in Phase 4.
final class SettingsStore {
    /// The six menu-bar indicator styles (FR-4). Raw values are the storage keys.
    enum IndicatorStyle: String, CaseIterable {
        case system
        case flag
        case flagShort
        case flagFull
        case short
        case full
    }

    private let defaults: UserDefaults
    private let styleKey = "IndicatorStyle"
    private let flagModeKey = "FlagMode"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    /// Menu-bar indicator style; defaults to "flag" (SPEC FR-4).
    var indicatorStyle: IndicatorStyle {
        get { defaults.string(forKey: styleKey).flatMap(IndicatorStyle.init) ?? .flag }
        set { defaults.set(newValue.rawValue, forKey: styleKey) }
    }

    /// Whether flags are shown as pictures or emoji; defaults to pictures (FR-5).
    var flagMode: FlagStore.Mode {
        get { defaults.string(forKey: flagModeKey).flatMap(FlagStore.Mode.init) ?? .images }
        set { defaults.set(newValue.rawValue, forKey: flagModeKey) }
    }
}
