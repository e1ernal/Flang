//
//  FlagStore.swift
//  Flang
//
//  Created by e1ernal on 05.07.2026.
//

import AppKit

/// Resolves the flag for an input source (FR-6) and renders it for the menu bar
/// in either of the two display modes (FR-5). Checks per-source customization
/// (FR-7) before falling back to the default map.
final class FlagStore {
    enum Mode: String {
        case images
        case emoji
    }

    struct Region: Identifiable {
        let code: String
        let name: String
        var id: String { code }
    }

    private let sourceMap: [String: String]
    private let languageMap: [String: String]
    private let settings: SettingsStore

    static let availableRegions: [Region] = {
        let locale = Locale(identifier: "en")
        return Locale.isoRegionCodes
            .compactMap { raw -> Region? in
                let code = raw.lowercased()
                guard NSImage(named: code) != nil else { return nil }
                let name = locale.localizedString(forRegionCode: raw) ?? raw
                return Region(code: code, name: name)
            }
            .sorted { $0.name < $1.name }
    }()

    init(settings: SettingsStore, bundle: Bundle = .main) {
        self.settings = settings
        if let url = bundle.url(forResource: "DefaultFlagMap", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let map = try? JSONDecoder().decode(FlagMap.self, from: data) {
            sourceMap = map.sources
            languageMap = map.languages
        } else {
            sourceMap = [:]
            languageMap = [:]
        }
    }

    /// Country code for a source in a given mode, considering customization (FR-7).
    func countryCode(for source: InputSource, mode: Mode) -> String? {
        let custom = settings.customization(for: source.id)
        switch mode {
        case .images:
            if let code = custom.flagImageCode { return code }
        case .emoji:
            if let code = custom.flagEmojiCode { return code }
        }
        return defaultCountryCode(for: source)
    }

    /// Default country code ignoring customization.
    func defaultCountryCode(for source: InputSource) -> String? {
        if let code = sourceMap[source.id] {
            return code
        }
        if let language = source.languages.first, let code = languageMap[language] {
            return code
        }
        return nil
    }

    func image(for source: InputSource, mode: Mode, height: CGFloat) -> NSImage {
        guard let code = countryCode(for: source, mode: mode) else {
            return fallbackImage(for: source, height: height)
        }
        switch mode {
        case .images:
            if let flag = NSImage(named: code) {
                return FlagRenderer.flag(flag, height: height)
            }
        case .emoji:
            if let emoji = FlagStore.emojiFlag(for: code) {
                return FlagRenderer.emoji(emoji, height: height)
            }
        }
        return fallbackImage(for: source, height: height)
    }

    /// A flag image for a given country code and mode (used by the flag picker preview).
    func image(forCode code: String, mode: Mode, height: CGFloat) -> NSImage? {
        switch mode {
        case .images:
            guard let flag = NSImage(named: code) else { return nil }
            return FlagRenderer.flag(flag, height: height)
        case .emoji:
            guard let emoji = FlagStore.emojiFlag(for: code) else { return nil }
            return FlagRenderer.emoji(emoji, height: height)
        }
    }

    private func fallbackImage(for source: InputSource, height: CGFloat) -> NSImage {
        if let icon = loadSystemIcon(for: source) {
            return FlagRenderer.icon(icon, height: height, template: true)
        }
        return FlagRenderer.globe(height: height)
    }

    func systemIcon(for source: InputSource, height: CGFloat) -> NSImage? {
        guard let icon = loadSystemIcon(for: source) else { return nil }
        return FlagRenderer.icon(icon, height: height, template: false)
    }

    private func loadSystemIcon(for source: InputSource) -> NSImage? {
        guard let url = source.systemIconURL else { return nil }
        return NSImage(contentsOf: url)
    }

    static func emojiFlag(for code: String) -> String? {
        let letters = Array(code.uppercased().unicodeScalars)
        guard letters.count == 2, letters.allSatisfy({ $0.value >= 65 && $0.value <= 90 }) else {
            return nil
        }
        var scalars = String.UnicodeScalarView()
        for letter in letters {
            guard let indicator = UnicodeScalar(0x1F1E6 + letter.value - 65) else { return nil }
            scalars.append(indicator)
        }
        return String(scalars)
    }
}

private struct FlagMap: Decodable {
    let sources: [String: String]
    let languages: [String: String]
}

enum FlagRenderer {
    static let menuHeight: CGFloat = 16
    private static let cornerRadius: CGFloat = 2

    static func flag(_ image: NSImage, height: CGFloat) -> NSImage {
        let size = NSSize(width: (height * 4 / 3).rounded(), height: height)
        let output = NSImage(size: size)
        output.lockFocus()
        defer { output.unlockFocus() }

        let border = NSRect(origin: .zero, size: size).insetBy(dx: 0.5, dy: 0.5)
        let path = NSBezierPath(roundedRect: border, xRadius: cornerRadius, yRadius: cornerRadius)

        NSGraphicsContext.saveGraphicsState()
        path.addClip()
        image.draw(in: NSRect(origin: .zero, size: size))
        NSGraphicsContext.restoreGraphicsState()

        NSColor(white: 0.4, alpha: 0.75).setStroke()
        path.lineWidth = 1
        path.stroke()

        output.isTemplate = false
        return output
    }

    static func emoji(_ emoji: String, height: CGFloat) -> NSImage {
        let string = NSAttributedString(
            string: emoji,
            attributes: [.font: NSFont.systemFont(ofSize: max(1, height - 2))]
        )
        let textSize = string.size()
        let size = NSSize(width: ceil(textSize.width), height: max(height, ceil(textSize.height)))
        let output = NSImage(size: size)
        output.lockFocus()
        defer { output.unlockFocus() }
        string.draw(at: NSPoint(x: 0, y: (size.height - textSize.height) / 2))
        output.isTemplate = false
        return output
    }

    static func icon(_ icon: NSImage, height: CGFloat, template: Bool) -> NSImage {
        let size = NSSize(width: height, height: height)
        let output = NSImage(size: size)
        output.lockFocus()
        defer { output.unlockFocus() }
        icon.draw(in: NSRect(origin: .zero, size: size))
        output.isTemplate = template
        return output
    }

    static func globe(height: CGFloat) -> NSImage {
        let configuration = NSImage.SymbolConfiguration(pointSize: height - 3, weight: .regular)
        let globe = NSImage(systemSymbolName: "globe", accessibilityDescription: nil)?
            .withSymbolConfiguration(configuration)
        globe?.isTemplate = true
        return globe ?? NSImage()
    }
}
