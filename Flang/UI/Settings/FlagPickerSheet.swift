//
//  FlagPickerSheet.swift
//  Flang
//
//  Created by e1ernal on 09.07.2026.
//

import SwiftUI

/// Grid of all available flags for per-source customization (FR-7, FR-11).
struct FlagPickerSheet: View {
    let mode: FlagStore.Mode
    let currentCode: String?
    let flagStore: FlagStore
    let onSelect: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var scheme
    private var theme: FlangColor { FlangColor(scheme) }

    @State private var searchText = ""

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 6)

    private var filtered: [FlagStore.Region] {
        guard !searchText.isEmpty else { return FlagStore.availableRegions }
        let query = searchText.lowercased()
        return FlagStore.availableRegions.filter { $0.name.lowercased().contains(query) }
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            searchField
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
            FlangSeparator(theme: theme)
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(filtered) { region in
                        flagCell(region)
                    }
                }
                .padding(16)
            }
        }
        .frame(width: 440, height: 380)
        .background(theme.windowBackground)
    }

    private var header: some View {
        HStack {
            Text(mode == .images ? "Choose Flag Image" : "Choose Flag Emoji")
                .font(FlangFont.sidebarApp)
                .foregroundStyle(theme.primaryText)
            Spacer()
            Button("Cancel") { dismiss() }
                .buttonStyle(.plain)
                .foregroundStyle(theme.secondaryText)
        }
        .padding(.horizontal, 16)
        .padding(.top, 14)
    }

    private var searchField: some View {
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(theme.secondaryText)
                .font(FlangFont.caption)
            TextField("Search countries", text: $searchText)
                .textFieldStyle(.plain)
                .font(FlangFont.label)
                .foregroundStyle(theme.primaryText)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(theme.cardBackground, in: RoundedRectangle(cornerRadius: FlangRadius.field))
    }

    private func flagCell(_ region: FlagStore.Region) -> some View {
        let isSelected = region.code == currentCode
        return Button {
            onSelect(region.code)
            dismiss()
        } label: {
            VStack(spacing: 4) {
                if let image = flagStore.image(forCode: region.code, mode: mode, height: 20) {
                    Image(nsImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 20)
                }
                Text(region.name)
                    .font(FlangFont.tinyLabel)
                    .lineLimit(1)
                    .foregroundStyle(isSelected ? theme.accent : theme.primaryText)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: FlangRadius.field)
                    .fill(isSelected ? theme.accent.opacity(0.12) : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }
}
