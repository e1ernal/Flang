//
//  DesignSystem.swift
//  Flang
//
//  Created by e1ernal on 10.07.2026.
//

import SwiftUI

/// Named spacing constants, so paddings match `_local/design/INDEX.md`
/// instead of being re-typed per file.
enum FlangSpacing {
    /// Every value here is a multiple of 8, rounded from the original mockup
    /// measurements (`_local/design/INDEX.md`) to a consistent 8pt grid.
    /// `screenTop` is shared by every tab's title AND the sidebar's own
    /// header, so both align at the same height as the window's traffic
    /// lights (a titlebar-less, full-size-content-view window — see
    /// `SettingsWindowController`).
    static let screenTop: CGFloat = 40
    static let screenSides: CGFloat = 32

    static let cardPadding: CGFloat = 16

    static let heroPadding: CGFloat = 24
    static let heroButtonInset: CGFloat = 24
    /// Large logo mark shared by the First Launch card and the About tab —
    /// one size for both keeps them visually consistent.
    static let heroIconSize: CGFloat = 80

    static let settingsWindowSize = CGSize(width: 640, height: 424)
    static let sidebarWidth: CGFloat = 176

    /// Side padding for the sidebar's own content, and reused as each item row's
    /// own horizontal/vertical padding.
    static let sidebarPadding: CGFloat = 8
    static let sidebarPaddingBottom: CGFloat = 16
    static let sidebarHeaderGap: CGFloat = 16

    /// Inner inset for a box nested inside a card row — smaller than the
    /// outer `cardPadding` so nested content reads as a distinct, tighter
    /// group (e.g. the Flag/Emoji/Reset boxes inside an expanded Input
    /// Source row).
    static let nestedPadding: CGFloat = 8

    /// Square icon-only control (e.g. the "+" add-source button).
    static let iconButtonSize: CGFloat = 24
}

/// Two independent radius scales: `card`/`sidebarItem`/`field` for the
/// Settings window, `hero*` for the First Launch card — the mockups use a
/// visibly larger scale there, not a mistake to reconcile. Values of 8 or
/// more sit on the 8pt grid; `sidebarItem`/`card`/`field` converge on the
/// same step, which is expected on a grid this coarse, not a bug to "fix" by
/// merging them into one constant — each still names a distinct role. Values
/// under 8 round to the nearest larger *even* number instead — collapsing
/// them onto the 8pt grid would zero out small radii that still need to read
/// as "slightly rounded" rather than "square."
enum FlangRadius {
    static let sidebarItem: CGFloat = 8
    static let card: CGFloat = 8
    static let field: CGFloat = 8
    /// The flag swatch in the First Launch menu bar preview is 12pt tall —
    /// already an even number under 8, so it stays as-is rather than
    /// collapsing to 0 or jumping up to the 8pt grid.
    static let flagImage: CGFloat = 2

    /// The Flag/Name dropdown pill in the Indicator tab — already an even
    /// number under 8, stays as-is (see the rounding rule above).
    static let chip: CGFloat = 6

    /// Outer grouping panel — the About tab's "app info" and "footer links"
    /// sections. Bigger than `card` since it wraps a whole group rather than
    /// sitting flush inside one.
    static let panel: CGFloat = 16

    static let heroCard: CGFloat = 40
    static let heroButton: CGFloat = 16
    static let heroIcon: CGFloat = field

    /// macOS's own app-icon corner radius is ~22.37% of the canvas size (the
    /// "squircle" ratio behind every Big Sur+ icon template). Applied to
    /// `FlangAppIcon` so the logo mark reads as a proper app icon without
    /// going through `NSApp.applicationIconImage`, which additionally bakes
    /// in system padding around the art — shrinking it inside its frame.
    static let appIconCornerRatio: CGFloat = 0.2237
}

/// Font combinations that repeat across Settings tabs and the First Launch
/// card, named after their role rather than their size+weight pair.
enum FlangFont {
    static let screenTitle = Font.system(size: 22, weight: .bold)
    static let sectionSubtitle = Font.system(size: 12.5)
    static let label = Font.system(size: 13)
    static let caption = Font.system(size: 12)
    static let captionSmall = Font.system(size: 11)
    static let chevron = Font.system(size: 11, weight: .semibold)
    static let sidebarApp = Font.system(size: 15, weight: .semibold)
    static let sidebarItem = Font.system(size: 13, weight: .medium)
    static let heroTitle = Font.system(size: 20, weight: .semibold)
    static let heroButton = Font.system(size: 14, weight: .medium)
    static let tinyLabel = Font.system(size: 9)

    /// App name in the About tab's info card — bigger than `screenTitle`,
    /// used once as the hero moment of that tab.
    static let appName = Font.system(size: 26, weight: .bold)
}

enum FlangMotion {
    static let tabTransition: Animation = .easeInOut(duration: 0.2)
}

/// Theme-aware color palette matching `_local/design/INDEX.md`. Compute once
/// per view from `@Environment(\.colorScheme)`.
struct FlangColor {
    let isDark: Bool

    init(_ scheme: ColorScheme) {
        isDark = scheme == .dark
    }

    var windowBackground: Color {
        isDark ? Color(red: 0.141, green: 0.141, blue: 0.149) : Color(red: 0.961, green: 0.953, blue: 0.941)
    }

    var cardBackground: Color {
        isDark ? Color(red: 0.118, green: 0.118, blue: 0.118) : .white
    }

    var sidebarBackground: Color {
        isDark ? Color.white.opacity(0.04) : Color.white.opacity(0.55)
    }

    var sidebarSelection: Color {
        Color(red: 0.184, green: 0.435, blue: 0.929)
    }

    var primaryText: Color {
        isDark ? Color.white.opacity(0.88) : Color.black.opacity(0.85)
    }

    var secondaryText: Color {
        isDark ? Color.white.opacity(0.4) : Color.black.opacity(0.4)
    }

    var separator: Color {
        isDark ? Color.white.opacity(0.06) : Color.black.opacity(0.06)
    }

    /// "Flang" wordmark in the sidebar header — very slightly brighter than
    /// `primaryText`, matching the mockup's own distinct value for it.
    var sidebarTitleText: Color {
        isDark ? Color.white.opacity(0.92) : Color.black.opacity(0.85)
    }

    /// Icon + label of an unselected sidebar item — dimmer than `primaryText`,
    /// which is reserved for card row labels.
    var sidebarItemText: Color {
        isDark ? Color.white.opacity(0.6) : Color.black.opacity(0.5)
    }

    /// Background of the tip/hint row under a card (e.g. GeneralTab's
    /// right-click hint) — distinct from `separator`, which is for hairlines.
    var tipBackground: Color {
        isDark ? Color.white.opacity(0.04) : Color.black.opacity(0.03)
    }

    /// Highlight fill for the selected row in a picker list (e.g. Interface
    /// Language). The opacity differs per theme in the mockup, not just a
    /// flat `accent.opacity()` reused verbatim.
    var pickerSelectedBackground: Color {
        accent.opacity(isDark ? 0.18 : 0.12)
    }

    /// Selected picker row's own label text — white in dark mode, accent blue
    /// in light mode (the mockup does not use the same color for both).
    var pickerSelectedText: Color {
        isDark ? .white : accent
    }

    /// Background of the Flag/Name dropdown pill in the Indicator tab — a
    /// subtler fill than `tipBackground`, since it sits on a card row rather
    /// than directly on the window background.
    var chipBackground: Color {
        isDark ? Color.white.opacity(0.08) : Color.black.opacity(0.05)
    }

    /// Dropdown pill's own value text — slightly dimmer than `primaryText`.
    var chipText: Color {
        isDark ? Color.white.opacity(0.85) : Color.black.opacity(0.8)
    }

    /// Dropdown pill's chevron glyph — dimmer still, matching the mockup.
    var chipChevron: Color {
        isDark ? Color.white.opacity(0.35) : Color.black.opacity(0.3)
    }

    /// Highlight tint behind an expanded Input Source row, distinguishing it
    /// from its collapsed siblings in the same list.
    var rowHighlight: Color {
        isDark ? Color.white.opacity(0.05) : Color.black.opacity(0.02)
    }

    /// Background of the inset mini-groups inside an expanded Input Source
    /// row (Flag+Emoji / Full+Short name / Reset+Delete) — a stronger
    /// overlay than `tipBackground`, needed for contrast against the row's
    /// own subtle highlight tint.
    var sectionBackground: Color {
        isDark ? Color.black.opacity(0.2) : Color.black.opacity(0.035)
    }

    /// Background of the About tab's two outer panels (app info, footer
    /// links) — a very faint overlay, one step lighter than the window
    /// itself but distinct from `cardBackground`'s solid fill.
    var outerPanelBackground: Color {
        isDark ? Color.white.opacity(0.03) : Color.black.opacity(0.02)
    }

    /// Footer link text (Quit Flang, Acknowledgements, Report a Bug,
    /// GitHub) — dimmer than `primaryText` but brighter than `secondaryText`,
    /// matching the mockup's own distinct value for these rows.
    var linkText: Color {
        isDark ? Color.white.opacity(0.7) : Color.black.opacity(0.65)
    }

    var accent: Color {
        isDark ? Color(red: 0.039, green: 0.518, blue: 1) : Color(red: 0, green: 0.478, blue: 1)
    }

    var destructive: Color {
        isDark ? Color(red: 1, green: 0.271, blue: 0.227) : Color(red: 1, green: 0.231, blue: 0.188)
    }

    var toggleOn: Color {
        isDark ? Color(red: 0.188, green: 0.820, blue: 0.345) : Color(red: 0.204, green: 0.780, blue: 0.349)
    }

    /// Text/icon drawn on top of a solid accent fill — always white, not
    /// theme-dependent (matches every colored button/pill in the mockups).
    var onAccent: Color { .white }

    // MARK: - Hero (First Launch card)

    // The First Launch card is visually distinct from Settings cards (a
    // "hero" moment, not a grouped list) — its own color roles, matching the
    // exact values already tuned against the mockup (screen 7) this session.

    var heroCardBackground: Color {
        isDark ? Color(red: 0.157, green: 0.157, blue: 0.157) : .white
    }
    var heroTitleText: Color {
        isDark ? Color.white.opacity(0.92) : Color.black.opacity(0.85)
    }
    var heroSubtitleText: Color {
        isDark ? Color.white.opacity(0.5) : Color.black.opacity(0.45)
    }
    var heroCaptionText: Color {
        isDark ? Color.white.opacity(0.3) : Color.black.opacity(0.32)
    }
    var heroMenuText: Color {
        isDark ? Color.white.opacity(0.85) : Color.black.opacity(0.85)
    }
    var heroMenuBackground: Color {
        isDark ? Color.black.opacity(0.72) : Color.white.opacity(0.85)
    }
    var heroMenuStroke: Color {
        isDark ? .clear : Color.black.opacity(0.08)
    }
    var heroFlagStroke: Color {
        isDark ? Color.white.opacity(0.25) : Color.black.opacity(0.15)
    }
    var heroIconBackground: Color {
        isDark ? Color.white.opacity(0.06) : Color.black.opacity(0.04)
    }
    var heroTipBackground: Color {
        isDark ? Color.white.opacity(0.04) : Color.black.opacity(0.025)
    }
    var heroTipTitleText: Color {
        isDark ? Color.white.opacity(0.85) : Color.black.opacity(0.8)
    }
    var heroTipSubtitleText: Color {
        isDark ? Color.white.opacity(0.4) : Color.black.opacity(0.38)
    }
}

/// The repeated "grouped card" background that `GeneralTab`, `IndicatorTab`,
/// and `InputSourcesTab` each reimplemented.
struct FlangCard: ViewModifier {
    let theme: FlangColor

    func body(content: Content) -> some View {
        content
            .padding(FlangSpacing.cardPadding)
            .background(theme.cardBackground, in: RoundedRectangle(cornerRadius: FlangRadius.card))
    }
}

extension View {
    func flangCard(_ theme: FlangColor) -> some View {
        modifier(FlangCard(theme: theme))
    }
}

/// A theme-colored 1pt separator, since `Divider()` can't be recolored directly.
struct FlangSeparator: View {
    let theme: FlangColor

    var body: some View {
        theme.separator.frame(height: 1)
    }
}

/// The app's logo mark, drawn at `size` with macOS's own app-icon corner
/// ratio. Uses the plain `AppLogo` image asset (edge-to-edge art, no system
/// padding) rather than `NSApp.applicationIconImage` — that call applies the
/// system's automatic squircle mask *and* a safe-area inset around the art,
/// which left visible gaps inside the frame at every call site.
struct FlangAppIcon: View {
    let size: CGFloat

    var body: some View {
        Image("AppLogo")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: size * FlangRadius.appIconCornerRatio, style: .continuous))
    }
}
