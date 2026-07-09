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
    private var isDark: Bool { scheme == .dark }

    // MARK: Colors

    private var cardBackground: Color {
        isDark ? Color(red: 0.157, green: 0.157, blue: 0.157) : .white
    }
    private var titleColor: Color {
        isDark ? .white.opacity(0.92) : .black.opacity(0.85)
    }
    private var subtitleColor: Color {
        isDark ? .white.opacity(0.5) : .black.opacity(0.45)
    }
    private var captionColor: Color {
        isDark ? .white.opacity(0.3) : .black.opacity(0.32)
    }
    private var accentBlue: Color {
        isDark ? Color(red: 0.039, green: 0.518, blue: 1) : Color(red: 0, green: 0.478, blue: 1)
    }
    private var menuTextColor: Color {
        isDark ? .white.opacity(0.85) : .black.opacity(0.85)
    }
    private var menuBackground: Color {
        isDark ? .black.opacity(0.72) : .white.opacity(0.85)
    }
    private var iconBackground: Color {
        isDark ? .white.opacity(0.06) : .black.opacity(0.04)
    }
    private var tipBackground: Color {
        isDark ? .white.opacity(0.04) : .black.opacity(0.025)
    }

    // MARK: Body

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                Image(nsImage: NSApp.applicationIconImage)
                    .resizable()
                    .frame(width: 64, height: 64)
                    .padding(.bottom, 16)

                Text("Welcome to Flang")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(titleColor)
                    .padding(.bottom, 6)

                Text("Country flags are back in your menu bar.")
                    .font(.system(size: 13))
                    .foregroundStyle(subtitleColor)
                    .padding(.bottom, 20)

                menuBarPreview
                    .padding(.bottom, 20)

                tipCard
            }
            .padding(.top, 24)
            .padding(.horizontal, 24)
            .padding(.bottom, 24)

            Button(action: onDismiss) {
                Text("Get Started")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(accentBlue, in: RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .frame(width: 380)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 40))
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
                        .clipShape(RoundedRectangle(cornerRadius: 2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 2)
                                .strokeBorder(
                                    isDark ? Color.white.opacity(0.25) : Color.black.opacity(0.15),
                                    lineWidth: 0.5
                                )
                        )
                    Text("ABC")
                        .font(.system(size: 12.5, weight: .medium))
                }

                Image(systemName: "wifi")
                Image(systemName: "battery.100")
                Text("Fri Jul 10 9:41")
            }
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(menuTextColor)
            .padding(.horizontal, 12)
            .frame(height: 32)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(menuBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(
                                isDark ? Color.clear : Color.black.opacity(0.08),
                                lineWidth: 0.5
                            )
                    )
            )

            Text("Your flag + short name, right where the old indicator was")
                .font(.system(size: 11))
                .foregroundStyle(captionColor)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    private var tipCard: some View {
        HStack(spacing: 8) {
            Image(systemName: "sparkle")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(menuTextColor.opacity(0.5))
                .frame(width: 32, height: 32)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(iconBackground)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text("Right-click the flag")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(isDark ? .white.opacity(0.85) : .black.opacity(0.8))
                Text("to open Settings and customize flags")
                    .font(.system(size: 12))
                    .foregroundStyle(isDark ? .white.opacity(0.4) : .black.opacity(0.38))
            }
            Spacer()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(tipBackground)
        )
    }
}
