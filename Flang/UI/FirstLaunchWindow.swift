//
//  FirstLaunchWindow.swift
//  Flang
//
//  Created by e1ernal on 09.07.2026.
//

import AppKit
import SwiftUI

/// Shows the welcome window on first launch (FR-10).
final class FirstLaunchWindowController {
    private var window: NSWindow?

    func showWindow() {
        let view = FirstLaunchView { [weak self] in
            self?.window?.close()
        }
        let hostingView = NSHostingView(rootView: view)

        let newWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 320),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        newWindow.title = "Welcome to Flang"
        newWindow.contentView = hostingView
        newWindow.isReleasedWhenClosed = false
        newWindow.center()
        newWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        window = newWindow
    }
}

struct FirstLaunchView: View {
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .frame(width: 64, height: 64)
                .padding(.bottom, 16)

            Text("Welcome to Flang")
                .font(.system(size: 20, weight: .bold))
                .padding(.bottom, 20)

            VStack(alignment: .leading, spacing: 14) {
                hintRow(
                    icon: "flag",
                    text: "Flang shows a country flag for your current keyboard layout in the menu bar."
                )
                hintRow(
                    icon: "cursorarrow.click.2",
                    text: "Right-click the flag to open Settings, or left-click to switch input sources."
                )
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 28)

            Button(action: onDismiss) {
                Text("Get Started")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 140, height: 32)
                    .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)

            Spacer()
        }
        .frame(width: 400, height: 320)
    }

    private func hintRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(Color.accentColor)
                .frame(width: 24)
            Text(text)
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
