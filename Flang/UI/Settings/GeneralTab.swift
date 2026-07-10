//
//  GeneralTab.swift
//  Flang
//
//  Created by e1ernal on 09.07.2026.
//

import SwiftUI

/// General settings tab: launch at login, interface language, tip (FR-8, FR-9).
struct GeneralTab: View {
    @ObservedObject var settings: SettingsStore

    @State private var showLanguagePicker = false

    @Environment(\.colorScheme) private var scheme
    private var theme: FlangColor { FlangColor(scheme) }

    private let languages: [(code: String, name: String)] = [
        ("system", "System Default"),
        ("en", "English"),
        ("zh-Hans", "Chinese, Simplified"),
        ("es", "Spanish"),
        ("fr", "French"),
        ("pt-BR", "Portuguese, Brazilian"),
        ("ja", "Japanese"),
        ("ru", "Russian")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("General")
                .font(FlangFont.screenTitle)
                .foregroundStyle(theme.primaryText)
                .padding(.bottom, 20)

            if showLanguagePicker {
                languagePickerView
            } else {
                mainContent
            }

            Spacer()
        }
        .padding(.top, FlangSpacing.screenTop)
        .padding(.horizontal, FlangSpacing.screenSides)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Main content

    private var mainContent: some View {
        VStack(spacing: 16) {
            Toggle("Launch at Login", isOn: Binding(
                get: { settings.launchAtLogin },
                set: { settings.launchAtLogin = $0 }
            ))
            .font(FlangFont.label)
            .foregroundStyle(theme.primaryText)
            .tint(theme.toggleOn)
            .flangCard(theme)

            Button {
                withAnimation(FlangMotion.tabTransition) { showLanguagePicker = true }
            } label: {
                HStack {
                    Text("Interface Language")
                        .font(FlangFont.label)
                        .foregroundStyle(theme.primaryText)
                    Spacer()
                    Text("English")
                        .font(FlangFont.label)
                        .foregroundStyle(theme.secondaryText)
                    Image(systemName: "chevron.right")
                        .font(FlangFont.chevron)
                        .foregroundStyle(theme.secondaryText)
                }
            }
            .buttonStyle(.plain)
            .flangCard(theme)

            HStack(spacing: 6) {
                Image(systemName: "hand.point.up.left")
                    .foregroundStyle(theme.secondaryText)
                    .font(FlangFont.captionSmall)
                Text("Right-click the flag in your menu bar to jump straight into these settings.")
                    .font(FlangFont.caption)
                    .foregroundStyle(theme.secondaryText)
            }
            .padding(.top, 4)
        }
    }

    // MARK: - Language picker sub-screen

    private var languagePickerView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Button {
                withAnimation(FlangMotion.tabTransition) { showLanguagePicker = false }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(FlangFont.chevron)
                    Text("General")
                        .font(FlangFont.label)
                }
            }
            .buttonStyle(.plain)
            .foregroundStyle(theme.secondaryText)

            VStack(spacing: 0) {
                ForEach(Array(languages.enumerated()), id: \.element.code) { index, lang in
                    if index > 0 {
                        FlangSeparator(theme: theme).padding(.leading, 16)
                    }
                    HStack {
                        Text(lang.name)
                            .font(FlangFont.label)
                            .foregroundStyle(theme.primaryText)
                        Spacer()
                        if lang.code == "en" {
                            Image(systemName: "checkmark")
                                .font(FlangFont.chevron)
                                .foregroundStyle(theme.accent)
                        }
                    }
                    .padding(.vertical, 8)
                    .contentShape(Rectangle())
                }
            }
            .flangCard(theme)

            Text("Translations are added in a future update.")
                .font(FlangFont.caption)
                .foregroundStyle(theme.secondaryText)
        }
    }
}
