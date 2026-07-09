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

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Indicator")
                .font(.system(size: 22, weight: .bold))
                .padding(.bottom, 6)

            Text("Choose how the active input source appears in your menu bar.")
                .font(.system(size: 12.5))
                .foregroundStyle(.secondary)
                .padding(.bottom, 20)

            if let picker = activePicker {
                pickerView(for: picker)
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
                VStack(spacing: 0) {
                    settingRow("Flag", value: settings.flagSetting.title) {
                        withAnimation(.easeInOut(duration: 0.2)) { activePicker = .flag }
                    }
                    Divider().padding(.leading, 16)
                    settingRow("Name", value: settings.nameSetting.title) {
                        withAnimation(.easeInOut(duration: 0.2)) { activePicker = .name }
                    }
                }
            }

            previewCard
        }
    }

    private func settingRow(_ label: String, value: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(label)
                    .font(.system(size: 13))
                Spacer()
                Text(value)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Preview

    private var previewCard: some View {
        card {
            VStack(spacing: 8) {
                Text("Preview")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                previewIndicator
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 4)
            }
        }
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
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 6))
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
        switch settings.nameSetting {
        case .short: return source.shortName
        case .full: return source.name
        case .none: return nil
        }
    }

    // MARK: - Picker sub-screen

    @ViewBuilder
    private func pickerView(for kind: PickerKind) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) { activePicker = nil }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 11, weight: .semibold))
                    Text("Indicator")
                        .font(.system(size: 13))
                }
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)

            switch kind {
            case .flag: flagPicker
            case .name: namePicker
            }
        }
    }

    private var flagPicker: some View {
        card {
            VStack(spacing: 0) {
                ForEach(Array(SettingsStore.FlagSetting.allCases.enumerated()), id: \.element.id) { index, option in
                    if index > 0 { Divider().padding(.leading, 16) }
                    pickerRow(option.title, selected: settings.flagSetting == option) {
                        settings.flagSetting = option
                    }
                }
            }
        }
    }

    private var namePicker: some View {
        card {
            VStack(spacing: 0) {
                ForEach(Array(SettingsStore.NameSetting.allCases.enumerated()), id: \.element.id) { index, option in
                    if index > 0 { Divider().padding(.leading, 16) }
                    pickerRow(option.title, selected: settings.nameSetting == option) {
                        settings.nameSetting = option
                    }
                }
            }
        }
    }

    private func pickerRow(_ label: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(label)
                    .font(.system(size: 13))
                Spacer()
                if selected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.accentColor)
                }
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Card wrapper

    private func card<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10))
    }
}
