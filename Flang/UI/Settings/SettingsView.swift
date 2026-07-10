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
    @ObservedObject var manager: InputSourceManager
    @ObservedObject var updateChecker: UpdateChecker

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
    }

    var body: some View {
        HStack(spacing: 0) {
            sidebar
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .frame(width: FlangSpacing.settingsWindowSize.width, height: FlangSpacing.settingsWindowSize.height)
        .background(theme.windowBackground)
    }

    // MARK: - Sidebar

    private var sidebar: some View {
        VStack(spacing: 2) {
            // "Flang" sits at screenTop, the same height as every tab's own
            // title, and clears the window's traffic lights (the window has
            // no title bar chrome — see SettingsWindowController).
            Text("Flang")
                .font(FlangFont.sidebarApp)
                .foregroundStyle(theme.sidebarTitleText)
                .frame(maxWidth: .infinity, alignment: .leading)
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
        .padding(.top, FlangSpacing.screenTop)
        .padding(.horizontal, FlangSpacing.sidebarPadding)
        .padding(.bottom, FlangSpacing.sidebarPaddingBottom)
        .frame(width: FlangSpacing.sidebarWidth)
        .frame(maxHeight: .infinity)
        .background(theme.sidebarBackground)
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
            Text(tab.label)
                .font(FlangFont.sidebarItem)
                .frame(maxWidth: .infinity, alignment: .leading)
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
            AboutTab(settings: settings, updateChecker: updateChecker)
        }
    }
}
