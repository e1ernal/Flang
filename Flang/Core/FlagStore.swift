//
//  FlagStore.swift
//  Flang
//
//  Created by e1ernal on 05.07.2026.
//

import AppKit

/// Resolves the flag for an input source (FR-6) and renders it for the menu bar
/// in either of the two display modes (FR-5). Personalization (FR-7) is added in
/// Phase 4; for now the lookup order is: exact Source ID -> primary language ->
/// fallback icon.
final class FlagStore {
    /// How flags are drawn everywhere in the app (FR-5).
    enum Mode: String {
        case images
        case emoji
    }

    private let sourceMap: [String: String]
    private let languageMap: [String: String]

    init(bundle: Bundle = .main) {
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

    /// Country code (ISO 3166-1 alpha-2) for a source, or nil when nothing matches.
    func countryCode(for source: InputSource) -> String? {
        if let code = sourceMap[source.id] {
            return code
        }
        if let language = source.languages.first, let code = languageMap[language] {
            return code
        }
        return nil
    }

    /// A menu-bar-ready image for the source in the chosen mode, falling back to
    /// the source's system icon or a globe when no flag is known (FR-3).
    func menuBarImage(for source: InputSource, mode: Mode) -> NSImage {
        guard let code = countryCode(for: source) else {
            return fallbackImage(for: source)
        }
        switch mode {
        case .images:
            if let flag = NSImage(named: code) {
                return FlagRenderer.flag(flag)
            }
        case .emoji:
            if let emoji = FlagStore.emojiFlag(for: code) {
                return FlagRenderer.emoji(emoji)
            }
        }
        return fallbackImage(for: source)
    }

    private func fallbackImage(for source: InputSource) -> NSImage {
        if let icon = source.systemIcon {
            return FlagRenderer.icon(icon)
        }
        return FlagRenderer.globe()
    }

    /// Convert a two-letter country code into its emoji flag via regional indicators.
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

/// Decoded shape of `DefaultFlagMap.json` (the `_comment` key is ignored).
private struct FlagMap: Decodable {
    let sources: [String: String]
    let languages: [String: String]
}

/// Draws flags at a consistent menu-bar size.
enum FlagRenderer {
    /// Flag height in the menu bar (FR-14): about 16 pt.
    static let barHeight: CGFloat = 16
    private static let cornerRadius: CGFloat = 2

    /// A colored 4:3 flag with rounded corners and a hairline translucent border,
    /// so light flags (e.g. Japan) don't blend into a light menu bar.
    static func flag(_ image: NSImage) -> NSImage {
        let size = NSSize(width: (barHeight * 4 / 3).rounded(), height: barHeight)
        let output = NSImage(size: size)
        output.lockFocus()
        defer { output.unlockFocus() }

        let border = NSRect(origin: .zero, size: size).insetBy(dx: 0.5, dy: 0.5)
        let path = NSBezierPath(roundedRect: border, xRadius: cornerRadius, yRadius: cornerRadius)

        NSGraphicsContext.saveGraphicsState()
        path.addClip()
        image.draw(in: NSRect(origin: .zero, size: size))
        NSGraphicsContext.restoreGraphicsState()

        NSColor.labelColor.withAlphaComponent(0.15).setStroke()
        path.lineWidth = 1
        path.stroke()

        output.isTemplate = false
        return output
    }

    /// The emoji flag rendered as an image of the same height as picture flags.
    static func emoji(_ emoji: String) -> NSImage {
        let string = NSAttributedString(string: emoji, attributes: [.font: NSFont.systemFont(ofSize: 14)])
        let textSize = string.size()
        let size = NSSize(width: ceil(textSize.width), height: barHeight)
        let output = NSImage(size: size)
        output.lockFocus()
        defer { output.unlockFocus() }
        string.draw(at: NSPoint(x: 0, y: (barHeight - textSize.height) / 2))
        output.isTemplate = false
        return output
    }

    /// The source's own system icon, scaled to menu-bar height.
    static func icon(_ icon: NSImage) -> NSImage {
        let size = NSSize(width: barHeight, height: barHeight)
        let output = NSImage(size: size)
        output.lockFocus()
        defer { output.unlockFocus() }
        icon.draw(in: NSRect(origin: .zero, size: size))
        output.isTemplate = false
        return output
    }

    /// Last-resort globe symbol (template, so it adapts to light/dark menu bars).
    static func globe() -> NSImage {
        let configuration = NSImage.SymbolConfiguration(pointSize: 13, weight: .regular)
        let globe = NSImage(systemSymbolName: "globe", accessibilityDescription: nil)?
            .withSymbolConfiguration(configuration)
        globe?.isTemplate = true
        return globe ?? NSImage()
    }
}
