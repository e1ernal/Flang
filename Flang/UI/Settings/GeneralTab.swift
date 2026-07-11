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
    @State private var pendingRelaunchLanguage: String?

    @Environment(\.colorScheme) private var scheme
    private var theme: FlangColor { FlangColor(scheme) }

    /// Only languages with an actual translation — the rest of the mockup's
    /// 7-language set ships once translated, in a later release.
    private let languages: [(code: String, name: String)] = [
        ("system", String(localized: "System Default")),
        ("en", Locale.current.localizedString(forLanguageCode: "en") ?? "English"),
        ("ru", Locale.current.localizedString(forLanguageCode: "ru") ?? "Russian")
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
            VStack(spacing: 0) {
                launchAtLoginRow
                FlangSeparator(theme: theme).padding(.horizontal, FlangSpacing.cardPadding)
                interfaceLanguageRow
            }
            .background(theme.cardBackground, in: RoundedRectangle(cornerRadius: FlangRadius.card))

            tipRow
        }
    }

    private var launchAtLoginRow: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Launch at Login")
                    .font(FlangFont.label)
                    .foregroundStyle(theme.primaryText)
                Text("Automatically start Flang when you log in.")
                    .font(FlangFont.caption)
                    .foregroundStyle(theme.secondaryText)
            }
            Spacer()
            Toggle("Launch at Login", isOn: Binding(
                get: { settings.launchAtLogin },
                set: { settings.launchAtLogin = $0 }
            ))
            .labelsHidden()
            .toggleStyle(.switch)
            .tint(theme.toggleOn)
            .accessibilityLabel("Launch at Login")
        }
        .padding(FlangSpacing.cardPadding)
    }

    private var currentLanguageName: String {
        languages.first { $0.code == settings.interfaceLanguage }?.name ?? languages[0].name
    }

    private var interfaceLanguageRow: some View {
        Button {
            withAnimation(FlangMotion.tabTransition) { showLanguagePicker = true }
        } label: {
            HStack {
                Text("Interface Language")
                    .font(FlangFont.label)
                    .foregroundStyle(theme.primaryText)
                Spacer()
                Text(currentLanguageName)
                    .font(FlangFont.label)
                    .foregroundStyle(theme.secondaryText)
                Image(systemName: "chevron.up.chevron.down")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(theme.secondaryText)
                    .accessibilityHidden(true)
            }
            .padding(FlangSpacing.cardPadding)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var tipRow: some View {
        HStack(spacing: 10) {
            Image(systemName: "lightbulb")
                .font(.system(size: 15))
                .foregroundStyle(theme.secondaryText)
                .accessibilityHidden(true)
            Text("Right-click the flag in your menu bar to jump straight into these settings.")
                .font(FlangFont.caption)
                .foregroundStyle(theme.secondaryText)
        }
        .padding(FlangSpacing.cardPadding)
        .background(theme.tipBackground, in: RoundedRectangle(cornerRadius: FlangRadius.field))
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
                        .accessibilityHidden(true)
                    Text("General")
                        .font(FlangFont.label)
                }
            }
            .buttonStyle(.plain)
            .foregroundStyle(theme.accent)

            VStack(spacing: 0) {
                ForEach(Array(languages.enumerated()), id: \.element.code) { index, lang in
                    if index > 0 {
                        FlangSeparator(theme: theme).padding(.horizontal, FlangSpacing.cardPadding)
                    }
                    let isSelected = lang.code == settings.interfaceLanguage
                    Button {
                        selectLanguage(lang.code)
                    } label: {
                        HStack {
                            Text(lang.name)
                                .font(FlangFont.label)
                                .foregroundStyle(isSelected ? theme.pickerSelectedText : theme.primaryText)
                            Spacer()
                            if isSelected {
                                Image(systemName: "checkmark")
                                    .font(FlangFont.chevron)
                                    .foregroundStyle(theme.accent)
                                    .accessibilityHidden(true)
                            }
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, FlangSpacing.cardPadding)
                        .background(isSelected ? theme.pickerSelectedBackground : Color.clear)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(isSelected ? .isSelected : [])
                }
            }
            .background(theme.cardBackground, in: RoundedRectangle(cornerRadius: FlangRadius.card))

            Text("More languages are coming in a future update.")
                .font(FlangFont.caption)
                .foregroundStyle(theme.secondaryText)
        }
        .alert(
            "Restart Flang to Apply?",
            isPresented: Binding(
                get: { pendingRelaunchLanguage != nil },
                set: { if !$0 { pendingRelaunchLanguage = nil } }
            )
        ) {
            Button("Later", role: .cancel) { pendingRelaunchLanguage = nil }
            Button("Restart Now") { relaunch() }
        } message: {
            Text("The new interface language takes effect after Flang restarts.")
        }
    }

    private func selectLanguage(_ code: String) {
        guard code != settings.interfaceLanguage else { return }
        settings.interfaceLanguage = code
        pendingRelaunchLanguage = code
    }

    private func relaunch() {
        let url = Bundle.main.bundleURL
        let configuration = NSWorkspace.OpenConfiguration()
        // Without this, openApplication just re-activates us instead of
        // spawning a new instance, and terminating right after races
        // LaunchServices into showing "The application is not open anymore".
        configuration.createsNewApplicationInstance = true
        NSWorkspace.shared.openApplication(at: url, configuration: configuration) { app, error in
            guard app != nil, error == nil else { return }
            DispatchQueue.main.async {
                NSApp.terminate(nil)
            }
        }
    }
}
