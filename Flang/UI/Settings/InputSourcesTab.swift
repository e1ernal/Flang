//
//  InputSourcesTab.swift
//  Flang
//
//  Created by e1ernal on 09.07.2026.
//

import SwiftUI

/// Input Sources tab: per-source customization of flags and names (FR-7, FR-8).
struct InputSourcesTab: View {
    @ObservedObject var settings: SettingsStore
    let flagStore: FlagStore
    @ObservedObject var manager: InputSourceManager

    @State private var expandedSources: Set<String> = []
    @State private var searchText = ""
    @State private var flagPicker: FlagPickerContext?
    @State private var resetConfirmSource: InputSource?

    @Environment(\.colorScheme) private var scheme
    var theme: FlangColor { FlangColor(scheme) }

    struct FlagPickerContext: Identifiable {
        let sourceID: String
        let mode: FlagStore.Mode
        var id: String { "\(sourceID)-\(mode.rawValue)" }
    }

    private var sources: [InputSource] {
        manager.inputSources
    }

    private var filteredSources: [InputSource] {
        guard !searchText.isEmpty else { return sources }
        let query = searchText.lowercased()
        return sources.filter {
            let custom = settings.customization(for: $0.id)
            let fullName = custom.fullName ?? $0.name
            let short = custom.shortName ?? $0.shortName
            return fullName.lowercased().contains(query) || short.lowercased().contains(query)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Input Sources")
                    .font(FlangFont.screenTitle)
                    .foregroundStyle(theme.primaryText)
                Spacer()
                Button(action: openKeyboardSettings) {
                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(theme.sidebarItemText)
                        .frame(width: FlangSpacing.iconButtonSize, height: FlangSpacing.iconButtonSize)
                        .background(theme.chipBackground, in: RoundedRectangle(cornerRadius: FlangRadius.chip))
                }
                .buttonStyle(.plain)
            }
            .padding(.bottom, 16)

            Text("""
            Customize the flag, emoji and name shown for each input source you've added \
            in System Settings. Tap + to add another.
            """)
                .font(FlangFont.sectionSubtitle)
                .foregroundStyle(theme.secondaryText)
                .padding(.bottom, 16)

            if sources.count >= 10 {
                searchField
                    .padding(.bottom, 12)
            }

            ScrollView {
                VStack(spacing: 0) {
                    ForEach(Array(filteredSources.enumerated()), id: \.element.id) { index, source in
                        if index > 0 { FlangSeparator(theme: theme).padding(.horizontal, FlangSpacing.cardPadding) }
                        sourceEntry(source)
                    }
                }
            }
            .background(theme.cardBackground, in: RoundedRectangle(cornerRadius: FlangRadius.card))
            .frame(maxHeight: 280)

            Spacer()
        }
        .padding(.top, FlangSpacing.screenTop)
        .padding(.horizontal, FlangSpacing.screenSides)
        .frame(maxWidth: .infinity, alignment: .leading)
        .sheet(item: $flagPicker) { context in
            FlagPickerSheet(
                mode: context.mode,
                currentCode: currentFlagCode(sourceID: context.sourceID, mode: context.mode),
                flagStore: flagStore
            ) { code in
                var custom = settings.customization(for: context.sourceID)
                switch context.mode {
                case .images: custom.flagImageCode = code
                case .emoji: custom.flagEmojiCode = code
                }
                settings.setCustomization(custom, for: context.sourceID)
            }
        }
        .alert(
            "Reset to Defaults",
            isPresented: Binding(
                get: { resetConfirmSource != nil },
                set: { if !$0 { resetConfirmSource = nil } }
            )
        ) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                if let source = resetConfirmSource {
                    settings.resetCustomization(for: source.id)
                }
            }
        } message: {
            if let source = resetConfirmSource {
                Text("Reset all customizations for \"\(source.name)\" to their default values?")
            }
        }
    }

    // MARK: - Search

    private var searchField: some View {
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(theme.secondaryText)
                .font(FlangFont.caption)
            TextField("Search", text: $searchText)
                .textFieldStyle(.plain)
                .font(FlangFont.label)
                .foregroundStyle(theme.primaryText)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(theme.cardBackground, in: RoundedRectangle(cornerRadius: FlangRadius.field))
    }

    // MARK: - Source entry

    private func sourceEntry(_ source: InputSource) -> some View {
        let isExpanded = expandedSources.contains(source.id)
        let custom = settings.customization(for: source.id)
        return VStack(alignment: .leading, spacing: 0) {
            sourceRow(source, custom: custom, expanded: isExpanded)
                .padding(.bottom, isExpanded ? FlangSpacing.cardPadding : 0)
            if isExpanded {
                expandedContent(source, custom: custom)
            }
        }
        .padding(.horizontal, FlangSpacing.cardPadding)
        .padding(.vertical, FlangSpacing.nestedPadding)
        .background(isExpanded ? theme.rowHighlight : Color.clear)
    }

    private func sourceRow(_ source: InputSource, custom: SourceCustomization, expanded: Bool) -> some View {
        Button {
            withAnimation(FlangMotion.tabTransition) {
                if expanded {
                    expandedSources.remove(source.id)
                } else {
                    expandedSources.insert(source.id)
                }
            }
        } label: {
            HStack(spacing: 10) {
                let mode: FlagStore.Mode = settings.flagSetting == .emoji ? .emoji : .images
                Image(nsImage: flagStore.image(for: source, mode: mode, height: 16))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 16)
                    .clipShape(RoundedRectangle(cornerRadius: FlangRadius.flagImage))

                VStack(alignment: .leading, spacing: 1) {
                    Text(custom.fullName ?? source.name)
                        .font(FlangFont.label)
                        .foregroundStyle(theme.primaryText)
                    Text(custom.shortName ?? source.shortName)
                        .font(FlangFont.captionSmall)
                        .foregroundStyle(theme.secondaryText)
                }
                Spacer()
                Image(systemName: expanded ? "chevron.down" : "chevron.right")
                    .font(FlangFont.chevron)
                    .foregroundStyle(theme.secondaryText)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helpers

    func currentFlagCode(sourceID: String, mode: FlagStore.Mode) -> String? {
        let custom = settings.customization(for: sourceID)
        switch mode {
        case .images: return custom.flagImageCode
        case .emoji: return custom.flagEmojiCode
        }
    }

    func openKeyboardSettings() {
        guard let url = URL(string: "x-apple.systempreferences:com.apple.Keyboard-Settings.extension") else { return }
        NSWorkspace.shared.open(url)
    }
}

// MARK: - Expanded content

extension InputSourcesTab {
    func expandedContent(_ source: InputSource, custom: SourceCustomization) -> some View {
        VStack(spacing: FlangSpacing.nestedPadding) {
            flagSection(source, custom: custom)
            nameSection(source, custom: custom)
            actionSection(source, custom: custom)
            footerNote
        }
    }

    private var footerNote: some View {
        Text("""
        Reset restores this source's flag, emoji and names to their system defaults. \
        Delete removes the input source from the system entirely.
        """)
            .font(FlangFont.captionSmall)
            .foregroundStyle(theme.secondaryText)
    }

    private func flagSection(_ source: InputSource, custom: SourceCustomization) -> some View {
        VStack(spacing: 0) {
            flagRow("Flag", code: custom.flagImageCode, source: source, mode: .images)
            FlangSeparator(theme: theme)
            flagRow("Emoji", code: custom.flagEmojiCode, source: source, mode: .emoji)
        }
        .padding(.horizontal, FlangSpacing.nestedPadding)
        .background(theme.sectionBackground, in: RoundedRectangle(cornerRadius: FlangRadius.field))
    }

    private func flagRow(
        _ label: LocalizedStringKey, code: String?, source: InputSource, mode: FlagStore.Mode
    ) -> some View {
        let effectiveCode = code ?? flagStore.defaultCountryCode(for: source)
        return Button {
            flagPicker = FlagPickerContext(sourceID: source.id, mode: mode)
        } label: {
            HStack {
                Text(label)
                    .font(FlangFont.sectionSubtitle)
                    .foregroundStyle(theme.secondaryText)
                Spacer()
                HStack(spacing: 7) {
                    if let effectiveCode, let image = flagStore.image(forCode: effectiveCode, mode: mode, height: 12) {
                        Image(nsImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 12)
                            .clipShape(RoundedRectangle(cornerRadius: FlangRadius.flagImage))
                    }
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 8, weight: .semibold))
                        .foregroundStyle(theme.chipChevron)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(theme.chipBackground, in: RoundedRectangle(cornerRadius: FlangRadius.chip))
            }
            .padding(.vertical, FlangSpacing.nestedPadding)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func nameSection(_ source: InputSource, custom: SourceCustomization) -> some View {
        VStack(spacing: 0) {
            nameRow("Full name", value: custom.fullName ?? source.name) { newValue in
                var updated = custom
                updated.fullName = newValue == source.name ? nil : newValue
                settings.setCustomization(updated, for: source.id)
            }
            FlangSeparator(theme: theme)
            nameRow("Short name", value: custom.shortName ?? source.shortName) { newValue in
                var updated = custom
                let trimmed = String(newValue.prefix(8))
                updated.shortName = trimmed == source.shortName ? nil : trimmed
                settings.setCustomization(updated, for: source.id)
            }
        }
        .padding(.horizontal, FlangSpacing.nestedPadding)
        .background(theme.sectionBackground, in: RoundedRectangle(cornerRadius: FlangRadius.field))
    }

    private func nameRow(
        _ label: LocalizedStringKey, value: String, onCommit: @escaping (String) -> Void
    ) -> some View {
        HStack {
            Text(label)
                .font(FlangFont.sectionSubtitle)
                .foregroundStyle(theme.secondaryText)
            Spacer()
            TextField("", text: Binding(
                get: { value },
                set: { onCommit($0) }
            ))
            .textFieldStyle(.plain)
            .font(FlangFont.sectionSubtitle)
            .foregroundStyle(theme.primaryText)
            .frame(maxWidth: 160)
            .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, FlangSpacing.nestedPadding)
    }

    private func actionSection(_ source: InputSource, custom: SourceCustomization) -> some View {
        HStack(spacing: 12) {
            if !custom.isEmpty {
                Button("Reset") {
                    resetConfirmSource = source
                }
                .font(FlangFont.sectionSubtitle)
                .buttonStyle(.plain)
                .foregroundStyle(theme.accent)
            }

            Spacer()

            Button("Delete…") {
                openKeyboardSettings()
            }
            .font(FlangFont.sectionSubtitle)
            .buttonStyle(.plain)
            .foregroundStyle(theme.destructive)
        }
        .padding(.horizontal, FlangSpacing.nestedPadding)
        .padding(.vertical, FlangSpacing.nestedPadding)
        .background(theme.sectionBackground, in: RoundedRectangle(cornerRadius: FlangRadius.field))
    }
}
