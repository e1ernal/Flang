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
            case .indicator: return "textformat.abc"
            case .inputSources: return "keyboard"
            case .about: return "info.circle"
            }
        }
    }

    var body: some View {
        HStack(spacing: 0) {
            sidebar
            theme.separator.frame(width: 1)
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .background(theme.windowBackground)
        }
        .frame(width: FlangSpacing.settingsWindowSize.width, height: FlangSpacing.settingsWindowSize.height)
    }

    // MARK: - Sidebar

    private var sidebar: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                FlangAppIcon(size: 32)
                Text("Flang")
                    .font(FlangFont.sidebarApp)
                    .foregroundStyle(theme.primaryText)
            }
            .padding(.top, 26)
            .padding(.bottom, 20)

            VStack(spacing: 2) {
                ForEach(Tab.allCases) { tab in
                    sidebarItem(tab)
                }
            }
            .padding(.horizontal, 10)

            Spacer()
        }
        .frame(width: FlangSpacing.sidebarWidth)
        .background(theme.sidebarBackground)
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
            .padding(.vertical, 7)
            .padding(.horizontal, 10)
            .background(
                RoundedRectangle(cornerRadius: FlangRadius.sidebarItem)
                    .fill(selection == tab ? theme.sidebarSelection : Color.clear)
            )
            .foregroundStyle(selection == tab ? theme.onAccent : theme.primaryText)
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
