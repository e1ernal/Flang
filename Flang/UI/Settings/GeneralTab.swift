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
                .font(.system(size: 22, weight: .bold))
                .padding(.bottom, 20)

            if showLanguagePicker {
                languagePickerView
            } else {
                mainContent
            }

            Spacer()
        }
        .padding(.top, 44)
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Main content

    private var mainContent: some View {
        VStack(spacing: 16) {
            card {
                Toggle("Launch at Login", isOn: Binding(
                    get: { settings.launchAtLogin },
                    set: { settings.launchAtLogin = $0 }
                ))
                .font(.system(size: 13))
            }

            card {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { showLanguagePicker = true }
                } label: {
                    HStack {
                        Text("Interface Language")
                            .font(.system(size: 13))
                        Spacer()
                        Text("English")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }
                }
                .buttonStyle(.plain)
            }

            HStack(spacing: 6) {
                Image(systemName: "hand.point.up.left")
                    .foregroundStyle(.secondary)
                    .font(.system(size: 11))
                Text("Right-click the flag in your menu bar to jump straight into these settings.")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 4)
        }
    }

    // MARK: - Language picker sub-screen

    private var languagePickerView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) { showLanguagePicker = false }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 11, weight: .semibold))
                    Text("General")
                        .font(.system(size: 13))
                }
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)

            card {
                VStack(spacing: 0) {
                    ForEach(Array(languages.enumerated()), id: \.element.code) { index, lang in
                        if index > 0 {
                            Divider().padding(.leading, 16)
                        }
                        HStack {
                            Text(lang.name)
                                .font(.system(size: 13))
                            Spacer()
                            if lang.code == "en" {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(Color.accentColor)
                            }
                        }
                        .padding(.vertical, 8)
                        .contentShape(Rectangle())
                    }
                }
            }

            Text("Translations are added in a future update.")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Card wrapper

    private func card<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10))
    }
}
