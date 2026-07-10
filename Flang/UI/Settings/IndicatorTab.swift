//
//  IndicatorTab.swift
//  Flang
//
//  Created by e1ernal on 09.07.2026.
//

import SwiftUI

/// Indicator settings tab: Flag and Name pickers with live preview (FR-4, FR-8).
struct IndicatorTab: View {
    @ObservedObject var settings: SettingsStore
    let flagStore: FlagStore
    let manager: InputSourceManager

    enum PickerKind { case flag, name }
    @State private var activePicker: PickerKind?

    @Environment(\.colorScheme) private var scheme
    private var theme: FlangColor { FlangColor(scheme) }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Indicator")
                .font(FlangFont.screenTitle)
                .foregroundStyle(theme.primaryText)
                .padding(.bottom, 6)

            Text("Choose how the active input source appears in your menu bar.")
                .font(FlangFont.sectionSubtitle)
                .foregroundStyle(theme.secondaryText)
                .padding(.bottom, 20)

            if let picker = activePicker {
                pickerView(for: picker)
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
                settingRow("Flag", value: settings.flagSetting.title) {
                    withAnimation(FlangMotion.tabTransition) { activePicker = .flag }
                }
                FlangSeparator(theme: theme).padding(.leading, 16)
                settingRow("Name", value: settings.nameSetting.title) {
                    withAnimation(FlangMotion.tabTransition) { activePicker = .name }
                }
            }
            .flangCard(theme)

            previewCard
        }
    }

    private func settingRow(_ label: String, value: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(label)
                    .font(FlangFont.label)
                    .foregroundStyle(theme.primaryText)
                Spacer()
                Text(value)
                    .font(FlangFont.label)
                    .foregroundStyle(theme.secondaryText)
                Image(systemName: "chevron.right")
                    .font(FlangFont.chevron)
                    .foregroundStyle(theme.secondaryText)
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Preview

    private var previewCard: some View {
        VStack(spacing: 8) {
            Text("Preview")
                .font(FlangFont.caption)
                .foregroundStyle(theme.secondaryText)
                .frame(maxWidth: .infinity, alignment: .leading)

            previewIndicator
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 4)
        }
        .flangCard(theme)
    }

    private var previewIndicator: some View {
        let source = manager.currentInputSource
        return HStack(spacing: 4) {
            if let source, let image = flagImage(for: source) {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 16)
            }
            if let source, let name = nameText(for: source) {
                Text(name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(theme.primaryText)
            }
            if flagImage(for: source) == nil && nameText(for: source) == nil {
                if let source, let icon = flagStore.systemIcon(for: source, height: 16) {
                    Image(nsImage: icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 16)
                } else if let source {
                    Text(source.shortName)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(theme.primaryText)
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(theme.cardBackground, in: RoundedRectangle(cornerRadius: FlangRadius.field))
    }

    private func flagImage(for source: InputSource?) -> NSImage? {
        guard let source else { return nil }
        switch settings.flagSetting {
        case .image: return flagStore.image(for: source, mode: .images, height: 16)
        case .emoji: return flagStore.image(for: source, mode: .emoji, height: 16)
        case .none: return nil
        }
    }

    private func nameText(for source: InputSource?) -> String? {
        guard let source else { return nil }
        let custom = settings.customization(for: source.id)
        switch settings.nameSetting {
        case .short: return custom.shortName ?? source.shortName
        case .full: return custom.fullName ?? source.name
        case .none: return nil
        }
    }

    // MARK: - Picker sub-screen

    @ViewBuilder
    private func pickerView(for kind: PickerKind) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Button {
                withAnimation(FlangMotion.tabTransition) { activePicker = nil }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(FlangFont.chevron)
                    Text("Indicator")
                        .font(FlangFont.label)
                }
            }
            .buttonStyle(.plain)
            .foregroundStyle(theme.secondaryText)

            switch kind {
            case .flag: flagPicker
            case .name: namePicker
            }
        }
    }

    private var flagPicker: some View {
        VStack(spacing: 0) {
            ForEach(Array(SettingsStore.FlagSetting.allCases.enumerated()), id: \.element.id) { index, option in
                if index > 0 { FlangSeparator(theme: theme).padding(.leading, 16) }
                pickerRow(option.title, selected: settings.flagSetting == option) {
                    settings.flagSetting = option
                }
            }
        }
        .flangCard(theme)
    }

    private var namePicker: some View {
        VStack(spacing: 0) {
            ForEach(Array(SettingsStore.NameSetting.allCases.enumerated()), id: \.element.id) { index, option in
                if index > 0 { FlangSeparator(theme: theme).padding(.leading, 16) }
                pickerRow(option.title, selected: settings.nameSetting == option) {
                    settings.nameSetting = option
                }
            }
        }
        .flangCard(theme)
    }

    private func pickerRow(_ label: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(label)
                    .font(FlangFont.label)
                    .foregroundStyle(theme.primaryText)
                Spacer()
                if selected {
                    Image(systemName: "checkmark")
                        .font(FlangFont.chevron)
                        .foregroundStyle(theme.accent)
                }
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
