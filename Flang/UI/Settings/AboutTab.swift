//
//  AboutTab.swift
//  Flang
//
//  Created by e1ernal on 09.07.2026.
//

import SwiftUI

/// About tab: version, update check (FR-13), links, license, attribution (FR-8).
struct AboutTab: View {
    @ObservedObject var settings: SettingsStore
    @ObservedObject var updateChecker: UpdateChecker

    @Environment(\.colorScheme) private var scheme
    private var theme: FlangColor { FlangColor(scheme) }
    @State private var showAcknowledgements = false

    private var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    }

    private var build: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("About")
                .font(FlangFont.screenTitle)
                .foregroundStyle(theme.primaryText)
                .padding(.bottom, 24)

            appInfoSection
                .padding(.bottom, 16)

            footerLinks
        }
        .padding(.top, FlangSpacing.screenTop)
        .padding(.horizontal, FlangSpacing.screenSides)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    // MARK: - App info + update settings

    private var appInfoSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: FlangSpacing.cardPadding) {
                FlangAppIcon(size: FlangSpacing.heroIconSize)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Flang")
                        .font(FlangFont.appName)
                        .foregroundStyle(theme.primaryText)
                    Text("Version \(version) (\(build))\nCopyright © 2026 Flang")
                        .font(FlangFont.label)
                        .foregroundStyle(theme.secondaryText)
                }
            }
            .padding(.bottom, 24)

            autoCheckRow
                .background(theme.cardBackground, in: RoundedRectangle(cornerRadius: FlangRadius.card))

            checkForUpdatesRow
                .padding(.top, FlangSpacing.cardPadding)
        }
        .padding(FlangSpacing.cardPadding)
        .background(theme.outerPanelBackground, in: RoundedRectangle(cornerRadius: FlangRadius.panel))
    }

    private var autoCheckRow: some View {
        HStack {
            Text("Automatically check for updates")
                .font(FlangFont.label)
                .foregroundStyle(theme.primaryText)
            Spacer()
            Toggle("Automatically check for updates", isOn: $settings.autoCheckForUpdates)
                .labelsHidden()
                .toggleStyle(.switch)
                .tint(theme.toggleOn)
                .accessibilityLabel("Automatically check for updates")
        }
        .padding(.horizontal, FlangSpacing.cardPadding)
        .padding(.vertical, FlangSpacing.nestedPadding)
    }

    private var checkForUpdatesRow: some View {
        HStack(alignment: .top) {
            Button {
                Task { await updateChecker.check(settings: settings) }
            } label: {
                HStack(spacing: 6) {
                    if updateChecker.isChecking {
                        ProgressView().controlSize(.small)
                    }
                    Text("Check for Updates")
                }
                .font(FlangFont.label.weight(.medium))
                .foregroundStyle(theme.chipText)
                .padding(.horizontal, FlangSpacing.cardPadding)
                .padding(.vertical, FlangSpacing.nestedPadding)
                .background(theme.chipBackground, in: RoundedRectangle(cornerRadius: FlangRadius.chip))
            }
            .buttonStyle(.plain)
            .disabled(updateChecker.isChecking)

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(lastCheckedText)
                    .font(FlangFont.caption)
                    .foregroundStyle(theme.secondaryText)
                if let release = updateChecker.newerRelease {
                    Button {
                        openURL(release.url.absoluteString)
                    } label: {
                        Text("Flang \(release.version) is available")
                            .font(FlangFont.caption)
                            .foregroundStyle(theme.accent)
                    }
                    .buttonStyle(.plain)
                } else if let error = updateChecker.lastError {
                    Text(error)
                        .font(FlangFont.caption)
                        .foregroundStyle(theme.destructive)
                }
            }
        }
    }

    private var lastCheckedText: String {
        guard let date = settings.lastUpdateCheck else {
            return String(localized: "Never checked")
        }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return String(localized: "Last checked: \(formatter.string(from: date))")
    }

    // MARK: - Footer links

    private var footerLinks: some View {
        HStack {
            footerLink("Quit Flang") { NSApp.terminate(nil) }
            Spacer()
            HStack(spacing: FlangSpacing.cardPadding) {
                footerLink("Acknowledgements") { showAcknowledgements = true }
                footerLink("Report a Bug") { openURL(reportBugURL) }
                footerLink("GitHub") { openURL("https://github.com/e1ernal/Flang") }
            }
        }
        .padding(FlangSpacing.cardPadding)
        .background(theme.outerPanelBackground, in: RoundedRectangle(cornerRadius: FlangRadius.panel))
        .popover(isPresented: $showAcknowledgements) {
            acknowledgementsPopover
        }
    }

    private func footerLink(_ title: LocalizedStringKey, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(FlangFont.label)
                .foregroundStyle(theme.linkText)
        }
        .buttonStyle(.plain)
    }

    private var acknowledgementsPopover: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Acknowledgements")
                .font(FlangFont.label.weight(.semibold))
                .foregroundStyle(theme.primaryText)
            Text("Flang is released under the MIT License.")
                .font(FlangFont.caption)
                .foregroundStyle(theme.secondaryText)
            Text("Flag icons by flag-icons (github.com/lipis/flag-icons), MIT License.")
                .font(FlangFont.caption)
                .foregroundStyle(theme.secondaryText)
        }
        .padding(FlangSpacing.cardPadding)
        .frame(width: 260)
    }

    private func openURL(_ string: String) {
        guard let url = URL(string: string) else { return }
        NSWorkspace.shared.open(url)
    }

    /// Opens the Bug report issue form pre-filled with app + macOS version —
    /// shown in the browser before submitting, so the user can still edit it.
    private var reportBugURL: String {
        var components = URLComponents(string: "https://github.com/e1ernal/Flang/issues/new")
        components?.queryItems = [
            URLQueryItem(name: "template", value: "bug_report.yml"),
            URLQueryItem(name: "app-version", value: "\(version) (\(build))"),
            URLQueryItem(name: "macos-version", value: ProcessInfo.processInfo.operatingSystemVersionString)
        ]
        return components?.url?.absoluteString ?? "https://github.com/e1ernal/Flang/issues/new"
    }
}
