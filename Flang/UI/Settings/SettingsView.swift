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
            Divider()
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .frame(width: 640, height: 420)
    }

    // MARK: - Sidebar

    private var sidebar: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Image(nsImage: NSApp.applicationIconImage)
                    .resizable()
                    .frame(width: 32, height: 32)
                Text("Flang")
                    .font(.system(size: 15, weight: .semibold))
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
        .frame(width: 172)
        .background(.ultraThinMaterial)
    }

    private func sidebarItem(_ tab: Tab) -> some View {
        Button {
            selection = tab
        } label: {
            HStack(spacing: 8) {
                Image(systemName: tab.icon)
                    .frame(width: 16)
                Text(tab.label)
                    .font(.system(size: 13, weight: .medium))
                Spacer()
            }
            .padding(.vertical, 7)
            .padding(.horizontal, 10)
            .background(
                RoundedRectangle(cornerRadius: 7)
                    .fill(selection == tab ? Color.accentColor : Color.clear)
            )
            .foregroundStyle(selection == tab ? .white : .primary)
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
