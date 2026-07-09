//
//  SettingsStore.swift
//  Flang
//
//  Created by e1ernal on 05.07.2026.
//

import Combine
import Foundation
import ServiceManagement

/// Per-source overrides for flag and name (FR-7).
struct SourceCustomization: Codable, Equatable {
    var flagImageCode: String?
    var flagEmojiCode: String?
    var fullName: String?
    var shortName: String?

    var isEmpty: Bool {
        flagImageCode == nil && flagEmojiCode == nil && fullName == nil && shortName == nil
    }
}

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
    private let customizationsKey = "SourceCustomizations"
    private let hasLaunchedKey = "HasLaunchedBefore"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    @Published var flagSetting: FlagSetting = .image {
        didSet {
            defaults.set(flagSetting.rawValue, forKey: flagKey)
            NotificationCenter.default.post(name: Self.didChange, object: self)
        }
    }

    @Published var nameSetting: NameSetting = .none {
        didSet {
            defaults.set(nameSetting.rawValue, forKey: nameKey)
            NotificationCenter.default.post(name: Self.didChange, object: self)
        }
    }

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
            } catch {}
        }
    }

    // MARK: - First Launch (FR-9, FR-10)

    var hasLaunchedBefore: Bool {
        defaults.bool(forKey: hasLaunchedKey)
    }

    func markAsLaunched() {
        defaults.set(true, forKey: hasLaunchedKey)
    }

    // MARK: - Per-source customization (FR-7)

    func customization(for sourceID: String) -> SourceCustomization {
        let dict = loadCustomizations()
        return dict[sourceID] ?? SourceCustomization()
    }

    func setCustomization(_ custom: SourceCustomization, for sourceID: String) {
        objectWillChange.send()
        var dict = loadCustomizations()
        if custom.isEmpty {
            dict.removeValue(forKey: sourceID)
        } else {
            dict[sourceID] = custom
        }
        saveCustomizations(dict)
        NotificationCenter.default.post(name: Self.didChange, object: self)
    }

    func resetCustomization(for sourceID: String) {
        objectWillChange.send()
        var dict = loadCustomizations()
        dict.removeValue(forKey: sourceID)
        saveCustomizations(dict)
        NotificationCenter.default.post(name: Self.didChange, object: self)
    }

    private func loadCustomizations() -> [String: SourceCustomization] {
        guard let data = defaults.data(forKey: customizationsKey),
              let dict = try? JSONDecoder().decode([String: SourceCustomization].self, from: data) else {
            return [:]
        }
        return dict
    }

    private func saveCustomizations(_ dict: [String: SourceCustomization]) {
        guard let data = try? JSONEncoder().encode(dict) else { return }
        defaults.set(data, forKey: customizationsKey)
    }

    /// Load persisted values; called once at startup.
    func load() {
        flagSetting = defaults.string(forKey: flagKey).flatMap(FlagSetting.init) ?? .image
        nameSetting = defaults.string(forKey: nameKey).flatMap(NameSetting.init) ?? .none
    }
}
