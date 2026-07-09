//
//  AboutTab.swift
//  Flang
//
//  Created by e1ernal on 09.07.2026.
//

import SwiftUI

/// About tab: version, links, license, attribution (FR-8).
struct AboutTab: View {
    private var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    }

    private var build: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .frame(width: 80, height: 80)
                .padding(.bottom, 12)

            Text("Flang")
                .font(.system(size: 22, weight: .bold))
                .padding(.bottom, 4)

            Text("Version \(version) (\(build))")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
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
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                Text("Flag icons by flag-icons")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
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
            .font(.system(size: 13))
            .frame(width: 200)
            .padding(.vertical, 6)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
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
