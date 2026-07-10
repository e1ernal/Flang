//
//  AboutTab.swift
//  Flang
//
//  Created by e1ernal on 09.07.2026.
//

import SwiftUI

/// About tab: version, links, license, attribution (FR-8).
struct AboutTab: View {
    @Environment(\.colorScheme) private var scheme
    private var theme: FlangColor { FlangColor(scheme) }

    private var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    }

    private var build: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            FlangAppIcon(size: FlangSpacing.heroIconSize)
                .padding(.bottom, 12)

            Text("Flang")
                .font(FlangFont.screenTitle)
                .foregroundStyle(theme.primaryText)
                .padding(.bottom, 4)

            Text("Version \(version) (\(build))")
                .font(FlangFont.caption)
                .foregroundStyle(theme.secondaryText)
                .padding(.bottom, 20)

            VStack(spacing: 8) {
                linkButton("Check for Updates", icon: "arrow.triangle.2.circlepath", enabled: false) {}

                linkButton("Report a Problem", icon: "exclamationmark.bubble", enabled: true) {
                    openURL("https://github.com/e1ernal/Flang/issues/new")
                }

                linkButton("GitHub Repository", icon: "link", enabled: true) {
                    openURL("https://github.com/e1ernal/Flang")
                }
            }
            .padding(.bottom, 24)

            VStack(spacing: 4) {
                Text("MIT License")
                    .font(FlangFont.captionSmall)
                    .foregroundStyle(theme.secondaryText)
                Text("Flag icons by flag-icons")
                    .font(FlangFont.captionSmall)
                    .foregroundStyle(theme.secondaryText)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func linkButton(_ title: String, icon: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .frame(width: 14)
                Text(title)
            }
            .font(FlangFont.label)
            .foregroundStyle(theme.primaryText)
            .frame(width: 200)
            .padding(.vertical, 6)
            .background(theme.cardBackground, in: RoundedRectangle(cornerRadius: FlangRadius.field))
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
        .opacity(enabled ? 1 : 0.5)
    }

    private func openURL(_ string: String) {
        guard let url = URL(string: string) else { return }
        NSWorkspace.shared.open(url)
    }
}
