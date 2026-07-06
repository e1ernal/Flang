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

    /// An image for the source at the given height, in the chosen mode, falling
    /// back to the source's system icon or a globe when no flag is known (FR-3).
    func image(for source: InputSource, mode: Mode, height: CGFloat) -> NSImage {
        guard let code = countryCode(for: source) else {
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

    /// Load the source's system icon lazily (only now, when a fallback is needed)
    /// and draw it as a template so a monochrome glyph stays visible on any theme.
    /// If there is no icon, use the globe.
    private func fallbackImage(for source: InputSource, height: CGFloat) -> NSImage {
        // Fallback path (FR-3): draw as a template so a monochrome glyph (e.g. Ainu)
        // stays visible on a dark menu bar.
        if let icon = loadSystemIcon(for: source) {
            return FlagRenderer.icon(icon, height: height, template: true)
        }
        return FlagRenderer.globe(height: height)
    }

    /// The source's own macOS icon rendered in color for the "System" style (FR-4,
    /// "like Apple"), or nil if it has none.
    func systemIcon(for source: InputSource, height: CGFloat) -> NSImage? {
        guard let icon = loadSystemIcon(for: source) else { return nil }
        return FlagRenderer.icon(icon, height: height, template: false)
    }

    private func loadSystemIcon(for source: InputSource) -> NSImage? {
        guard let url = source.systemIconURL else { return nil }
        return NSImage(contentsOf: url)
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

/// Draws flags at a requested height for the menu bar or the drop-down menu.
enum FlagRenderer {
    /// Default flag height inside the drop-down menu (FR-14): about 16 pt.
    static let menuHeight: CGFloat = 16
    private static let cornerRadius: CGFloat = 2

    /// A colored 4:3 flag with rounded corners and a hairline translucent border,
    /// so light flags (e.g. Japan) don't blend into a light menu bar.
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

        // A concrete mid-gray border, NOT a dynamic system color: this image is
        // drawn off-screen (lockFocus), where dynamic colors like labelColor don't
        // resolve and the stroke ends up invisible. A fixed mid-gray reads on both
        // a white menu (light theme) and a dark menu bar, so a solid-white flag
        // (Japan) stays outlined either way.
        NSColor(white: 0.4, alpha: 0.75).setStroke()
        path.lineWidth = 1
        path.stroke()

        output.isTemplate = false
        return output
    }

    /// The emoji flag rendered as an image, sized so the glyph is never clipped.
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

    /// The source's own system icon, scaled to height. Draw as a template for the
    /// fallback path (a monochrome glyph then adapts to the theme instead of a black
    /// blob); draw in color for the "System" style to match how macOS shows it.
    static func icon(_ icon: NSImage, height: CGFloat, template: Bool) -> NSImage {
        let size = NSSize(width: height, height: height)
        let output = NSImage(size: size)
        output.lockFocus()
        defer { output.unlockFocus() }
        icon.draw(in: NSRect(origin: .zero, size: size))
        output.isTemplate = template
        return output
    }

    /// Last-resort globe symbol (template, so it adapts to light/dark menu bars).
    static func globe(height: CGFloat) -> NSImage {
        let configuration = NSImage.SymbolConfiguration(pointSize: height - 3, weight: .regular)
        let globe = NSImage(systemSymbolName: "globe", accessibilityDescription: nil)?
            .withSymbolConfiguration(configuration)
        globe?.isTemplate = true
        return globe ?? NSImage()
    }
}
