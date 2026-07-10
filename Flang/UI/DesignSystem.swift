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
    static let screenTop: CGFloat = 44
    static let screenSides: CGFloat = 32

    static let cardPaddingH: CGFloat = 16
    static let cardPaddingV: CGFloat = 12

    static let heroPadding: CGFloat = 24
    static let heroButtonInset: CGFloat = 24

    static let settingsWindowSize = CGSize(width: 640, height: 420)
    static let sidebarWidth: CGFloat = 172
}

/// Two independent radius scales: `card`/`sidebarItem`/`chip`/`field` for the
/// Settings window, `hero*` for the First Launch card — the mockups use a
/// visibly larger scale there, not a mistake to reconcile.
enum FlangRadius {
    static let sidebarItem: CGFloat = 7
    static let card: CGFloat = 10
    static let chip: CGFloat = 6
    static let field: CGFloat = 8
    static let flagImage: CGFloat = 2

    static let heroCard: CGFloat = 40
    static let heroButton: CGFloat = 16
    static let heroIcon: CGFloat = field
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

/// The repeated "grouped card" background (padding 16/12, corner radius 10)
/// that `GeneralTab`, `IndicatorTab`, and `InputSourcesTab` each reimplemented.
struct FlangCard: ViewModifier {
    let theme: FlangColor

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, FlangSpacing.cardPaddingH)
            .padding(.vertical, FlangSpacing.cardPaddingV)
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
