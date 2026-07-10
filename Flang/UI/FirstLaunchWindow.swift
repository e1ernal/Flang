//
//  FirstLaunchWindow.swift
//  Flang
//
//  Created by e1ernal on 09.07.2026.
//

import AppKit
import SwiftUI

// MARK: - Window

private final class WelcomeWindow: NSWindow {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

// MARK: - Controller

final class FirstLaunchWindowController {
    private var window: NSWindow?

    func showWindow(onGetStarted: @escaping () -> Void) {
        let view = FirstLaunchView {
            onGetStarted()
            self.window?.close()
        }
        let hostingView = NSHostingView(rootView: view)
        let size = hostingView.fittingSize

        let newWindow = WelcomeWindow(
            contentRect: NSRect(origin: .zero, size: size),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        newWindow.isOpaque = false
        newWindow.backgroundColor = .clear
        newWindow.hasShadow = true
        newWindow.isMovableByWindowBackground = true
        newWindow.contentView = hostingView
        newWindow.center()
        newWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        window = newWindow
    }
}

// MARK: - View

struct FirstLaunchView: View {
    let onDismiss: () -> Void

    @Environment(\.colorScheme) private var scheme
    private var theme: FlangColor { FlangColor(scheme) }

    // MARK: Body

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                FlangAppIcon(size: FlangSpacing.heroIconSize)
                    .accessibilityHidden(true)
                    .padding(.bottom, 16)

                Text("Welcome to Flang")
                    .font(FlangFont.heroTitle)
                    .foregroundStyle(theme.heroTitleText)
                    .padding(.bottom, 6)

                Text("Country flags are back in your menu bar.")
                    .font(FlangFont.label)
                    .foregroundStyle(theme.heroSubtitleText)
                    .padding(.bottom, 20)

                menuBarPreview
                    .padding(.bottom, 20)

                tipCard
            }
            .padding(.top, FlangSpacing.heroPadding)
            .padding(.horizontal, FlangSpacing.heroPadding)
            .padding(.bottom, FlangSpacing.heroPadding)

            Button(action: onDismiss) {
                Text("Get Started")
                    .font(FlangFont.heroButton)
                    .foregroundStyle(theme.onAccent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(theme.accent, in: RoundedRectangle(cornerRadius: FlangRadius.heroButton))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, FlangSpacing.heroPadding)
            .padding(.bottom, FlangSpacing.heroPadding)
        }
        .frame(width: 380)
        .background(theme.heroCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: FlangRadius.heroCard))
    }

    // MARK: - Subviews

    private var menuBarPreview: some View {
        VStack(spacing: 6) {
            HStack(spacing: 10) {
                Spacer()

                HStack(spacing: 5) {
                    Image("us")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 18, height: 12)
                        .clipShape(RoundedRectangle(cornerRadius: FlangRadius.flagImage))
                        .overlay(
                            RoundedRectangle(cornerRadius: FlangRadius.flagImage)
                                .strokeBorder(theme.heroFlagStroke, lineWidth: 0.5)
                        )
                    Text("ABC")
                        .font(.system(size: 12.5, weight: .medium))
                }

                Image(systemName: "wifi")
                Image(systemName: "battery.100")
                Text("Fri Jul 10 9:41")
            }
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(theme.heroMenuText)
            .padding(.horizontal, 12)
            .frame(height: 32)
            .background(
                RoundedRectangle(cornerRadius: FlangRadius.heroButton)
                    .fill(theme.heroMenuBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: FlangRadius.heroButton)
                            .strokeBorder(theme.heroMenuStroke, lineWidth: 0.5)
                    )
            )
            // A static mockup of the menu bar, not real content — the caption
            // below already says the same thing in words, so VoiceOver skips it.
            .accessibilityHidden(true)

            Text("Your flag + short name, right where the old indicator was")
                .font(FlangFont.captionSmall)
                .foregroundStyle(theme.heroCaptionText)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    private var tipCard: some View {
        HStack(spacing: 8) {
            Image(systemName: "sparkle")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(theme.heroMenuText.opacity(0.5))
                .frame(width: 32, height: 32)
                .background(
                    RoundedRectangle(cornerRadius: FlangRadius.heroIcon)
                        .fill(theme.heroIconBackground)
                )
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text("Right-click the flag")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(theme.heroTipTitleText)
                Text("to open Settings and customize flags")
                    .font(FlangFont.caption)
                    .foregroundStyle(theme.heroTipSubtitleText)
            }
            Spacer()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: FlangRadius.heroButton)
                .fill(theme.heroTipBackground)
        )
    }
}
