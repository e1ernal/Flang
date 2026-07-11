//
//  DesignSystem.swift
//  Flang
//
//  Created by e1ernal on 10.07.2026.
//

import SwiftUI

/// Spacing constants shared across Settings and First Launch, matching `_local/design/INDEX.md`.
enum FlangSpacing {
    // screenTop lines up every tab's title with the sidebar header and the
    // window's traffic lights (titlebar-less window, see SettingsWindowController).
    static let screenTop: CGFloat = 40
    static let screenSides: CGFloat = 32

    static let cardPadding: CGFloat = 16

    static let heroPadding: CGFloat = 24
    static let heroButtonInset: CGFloat = 24
    static let heroIconSize: CGFloat = 80

    static let settingsWindowSize = CGSize(width: 640, height: 424)
    static let sidebarWidth: CGFloat = 176

    static let sidebarPadding: CGFloat = 8
    static let sidebarPaddingBottom: CGFloat = 16
    static let sidebarHeaderGap: CGFloat = 16

    // Tighter than cardPadding, for boxes nested inside a card row (e.g. the
    // Flag/Emoji/Reset groups inside an expanded Input Source row).
    static let nestedPadding: CGFloat = 8

    static let iconButtonSize: CGFloat = 24
}

// Two radius scales on purpose: card/sidebarItem/field for Settings, hero* for
// the First Launch card, which the mockup draws at a visibly larger scale.
enum FlangRadius {
    static let sidebarItem: CGFloat = 8
    static let card: CGFloat = 8
    static let field: CGFloat = 8
    static let flagImage: CGFloat = 2
    static let chip: CGFloat = 6
    static let panel: CGFloat = 16

    static let heroCard: CGFloat = 40
    static let heroButton: CGFloat = 16
    static let heroIcon: CGFloat = field

    /// macOS's app-icon corner ratio (~22.37% of canvas) — used by
    /// `FlangAppIcon` to round our logo mark the same way Big Sur+ icons are.
    static let appIconCornerRatio: CGFloat = 0.2237
}

/// Font combinations reused across Settings and First Launch, named by role.
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
    static let appName = Font.system(size: 26, weight: .bold)
}

enum FlangMotion {
    static let tabTransition: Animation = .easeInOut(duration: 0.2)
}

/// Theme-aware colors matching `_local/design/INDEX.md`. Compute once per
/// view from `@Environment(\.colorScheme)`.
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

    var sidebarTitleText: Color {
        isDark ? Color.white.opacity(0.92) : Color.black.opacity(0.85)
    }

    var sidebarItemText: Color {
        isDark ? Color.white.opacity(0.6) : Color.black.opacity(0.5)
    }

    var tipBackground: Color {
        isDark ? Color.white.opacity(0.04) : Color.black.opacity(0.03)
    }

    var pickerSelectedBackground: Color {
        accent.opacity(isDark ? 0.18 : 0.12)
    }

    var pickerSelectedText: Color {
        isDark ? .white : accent
    }

    var chipBackground: Color {
        isDark ? Color.white.opacity(0.08) : Color.black.opacity(0.05)
    }

    var chipText: Color {
        isDark ? Color.white.opacity(0.85) : Color.black.opacity(0.8)
    }

    var chipChevron: Color {
        isDark ? Color.white.opacity(0.35) : Color.black.opacity(0.3)
    }

    var rowHighlight: Color {
        isDark ? Color.white.opacity(0.05) : Color.black.opacity(0.02)
    }

    var sectionBackground: Color {
        isDark ? Color.black.opacity(0.2) : Color.black.opacity(0.035)
    }

    var outerPanelBackground: Color {
        isDark ? Color.white.opacity(0.03) : Color.black.opacity(0.02)
    }

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

    // Always white — every colored button/pill in the mockups uses white text
    // in both themes.
    var onAccent: Color { .white }

    // MARK: - Hero (First Launch card)

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

/// The grouped card background shared by GeneralTab, IndicatorTab, and InputSourcesTab.
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

/// The dropdown-pill chip used by Indicator's Flag/Name rows and Input
/// Sources' Flag/Emoji rows: arbitrary leading content plus a chevron, on a
/// tinted pill background. `compact` matches Input Sources' smaller nested scale.
struct FlangDropdownChip<Content: View>: View {
    let theme: FlangColor
    var compact = false
    @ViewBuilder let content: Content

    var body: some View {
        HStack(spacing: compact ? 5 : 7) {
            content
            Image(systemName: "chevron.up.chevron.down")
                .font(.system(size: compact ? 8 : 9, weight: .semibold))
                .foregroundStyle(theme.chipChevron)
                .accessibilityHidden(true)
        }
        .padding(.horizontal, compact ? 8 : 10)
        .padding(.vertical, compact ? 4 : 5)
        .background(theme.chipBackground, in: RoundedRectangle(cornerRadius: FlangRadius.chip))
    }
}

/// A theme-colored 1pt separator, since `Divider()` can't be recolored directly.
struct FlangSeparator: View {
    let theme: FlangColor

    var body: some View {
        theme.separator.frame(height: 1)
    }
}

/// The app's logo mark, rounded with macOS's own app-icon corner ratio.
/// Uses the plain `AppLogo` asset (edge-to-edge, no padding) instead of
/// `NSApp.applicationIconImage`, which bakes in its own squircle mask and
/// safe-area padding and leaves visible gaps at small sizes.
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
