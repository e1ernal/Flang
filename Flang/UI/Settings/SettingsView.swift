//
//  SettingsView.swift
//  Flang
//
//  Created by e1ernal on 09.07.2026.
//

import SwiftUI

/// Root view of the Settings window: sidebar with four tabs (FR-8).
struct SettingsView: View {
    @ObservedObject var settings: SettingsStore
    let flagStore: FlagStore
    let manager: InputSourceManager

    @State private var selection: Tab = .general

    @Environment(\.colorScheme) private var scheme
    private var theme: FlangColor { FlangColor(scheme) }

    enum Tab: String, CaseIterable, Identifiable {
        case general, indicator, inputSources, about
        var id: String { rawValue }

        var label: String {
            switch self {
            case .general: return "General"
            case .indicator: return "Indicator"
            case .inputSources: return "Input Sources"
            case .about: return "About"
            }
        }

        var icon: String {
            switch self {
            case .general: return "gearshape"
            case .indicator: return "flag"
            case .inputSources: return "lock"
            case .about: return "info.circle"
            }
        }
    }

    var body: some View {
        HStack(spacing: 0) {
            sidebar
                .padding(.top, FlangSpacing.sidebarMargin)
                .padding(.leading, FlangSpacing.sidebarMargin)
                .padding(.bottom, FlangSpacing.sidebarMargin)
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .frame(width: FlangSpacing.settingsWindowSize.width, height: FlangSpacing.settingsWindowSize.height)
        .background(theme.windowBackground)
    }

    // MARK: - Sidebar

    private var sidebar: some View {
        VStack(spacing: 2) {
            header
                .padding(.horizontal, FlangSpacing.sidebarPadding)
                .padding(.bottom, FlangSpacing.sidebarHeaderGap)

            sidebarItem(.general)
            sidebarDivider
            sidebarItem(.indicator)
            sidebarItem(.inputSources)
            sidebarDivider
            sidebarItem(.about)

            Spacer()
        }
        .padding(.top, FlangSpacing.sidebarPaddingTop)
        .padding(.horizontal, FlangSpacing.sidebarPadding)
        .padding(.bottom, FlangSpacing.sidebarPaddingBottom)
        .frame(width: FlangSpacing.sidebarWidth)
        .background(theme.sidebarBackground)
        .clipShape(RoundedRectangle(cornerRadius: FlangRadius.sidebarPanel))
        .overlay(
            RoundedRectangle(cornerRadius: FlangRadius.sidebarPanel)
                .strokeBorder(theme.primaryText.opacity(0.08), lineWidth: 0.5)
        )
    }

    private var header: some View {
        HStack(spacing: 8) {
            FlangAppIcon(size: FlangSpacing.sidebarAppIconSize)
            Text("Flang")
                .font(FlangFont.sidebarApp)
                .foregroundStyle(theme.sidebarTitleText)
        }
    }

    private var sidebarDivider: some View {
        FlangSeparator(theme: theme)
            .padding(.horizontal, FlangSpacing.sidebarPadding)
            .padding(.vertical, 6)
    }

    private func sidebarItem(_ tab: Tab) -> some View {
        Button {
            selection = tab
        } label: {
            HStack(spacing: 8) {
                Image(systemName: tab.icon)
                    .frame(width: 16)
                Text(tab.label)
                    .font(FlangFont.sidebarItem)
                Spacer()
            }
            .padding(FlangSpacing.sidebarPadding)
            .background(
                RoundedRectangle(cornerRadius: FlangRadius.sidebarItem)
                    .fill(selection == tab ? theme.sidebarSelection : Color.clear)
            )
            .foregroundStyle(selection == tab ? theme.onAccent : theme.sidebarItemText)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        switch selection {
        case .general:
            GeneralTab(settings: settings)
        case .indicator:
            IndicatorTab(settings: settings, flagStore: flagStore, manager: manager)
        case .inputSources:
            InputSourcesTab(settings: settings, flagStore: flagStore, manager: manager)
        case .about:
            AboutTab()
        }
    }
}
