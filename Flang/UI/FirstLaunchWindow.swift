//
//  FirstLaunchWindow.swift
//  Flang
//
//  Created by e1ernal on 09.07.2026.
//

import AppKit
import SwiftUI

/// A borderless window that can still become key so its buttons stay responsive.
private final class WelcomeWindow: NSWindow {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

/// Shows the welcome card on first launch (FR-10). Rendered as a borderless,
/// rounded card to match the design (screen 7) — no system title bar.
final class FirstLaunchWindowController {
    private var window: NSWindow?

    func showWindow(onGetStarted: @escaping () -> Void) {
        let view = FirstLaunchView { [weak self] in
            onGetStarted()
            self?.window?.close()
        }
        let hostingView = NSHostingView(rootView: view)
        hostingView.layoutSubtreeIfNeeded()
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

struct FirstLaunchView: View {
    let onDismiss: () -> Void

    @Environment(\.colorScheme) private var scheme
    private var isDark: Bool { scheme == .dark }

    // Card
    private var cardBackground: Color {
        isDark ? Color(red: 0.157, green: 0.157, blue: 0.157) : .white
    }
    private var titleColor: Color {
        isDark ? Color(white: 1, opacity: 0.92) : Color(white: 0, opacity: 0.85)
    }
    private var subtitleColor: Color {
        isDark ? Color(white: 1, opacity: 0.5) : Color(white: 0, opacity: 0.45)
    }
    private var captionColor: Color {
        isDark ? Color(white: 1, opacity: 0.3) : Color(white: 0, opacity: 0.32)
    }
    private var accentBlue: Color {
        isDark ? Color(red: 0.039, green: 0.518, blue: 1) : Color(red: 0, green: 0.478, blue: 1)
    }

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
            .padding(.top, 32)
            .padding(.horizontal, 28)
            .padding(.bottom, 24)

            // The button is inset by a uniform 8 pt so its bottom corners are
            // optically concentric with the card's 16 pt corners (8 + 8 = 16).
            Button(action: onDismiss) {
                Text("Get Started")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(accentBlue, in: RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .frame(width: 380)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Menu bar preview

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
                                    isDark ? Color(white: 1, opacity: 0.25) : Color(white: 0, opacity: 0.15),
                                    lineWidth: 0.5
                                )
                        )
                    Text("ABC")
                        .font(.system(size: 12.5, weight: .medium))
                        .foregroundStyle(isDark ? Color(white: 1, opacity: 0.85) : Color(white: 0, opacity: 0.78))
                }
                Text("9:41")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(isDark ? Color(white: 1, opacity: 0.9) : Color(white: 0, opacity: 0.78))
            }
            .padding(.horizontal, 12)
            .frame(height: 25)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isDark ? Color(white: 0, opacity: 0.72) : Color(white: 1, opacity: 0.85))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .strokeBorder(
                                isDark ? Color.clear : Color(white: 0, opacity: 0.08),
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

    // MARK: - Tip card

    private var tipCard: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(isDark ? Color(white: 1, opacity: 0.06) : Color(white: 0, opacity: 0.04))
                    .frame(width: 32, height: 32)
                PlusClickIcon(
                    plusColor: isDark ? Color(white: 1, opacity: 0.5) : Color(white: 0, opacity: 0.4),
                    tickColor: isDark ? Color(white: 1, opacity: 0.3) : Color(white: 0, opacity: 0.25)
                )
                .frame(width: 16, height: 16)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Right-click the flag")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(isDark ? Color(white: 1, opacity: 0.85) : Color(white: 0, opacity: 0.8))
                Text("to open Settings and customize flags")
                    .font(.system(size: 12))
                    .foregroundStyle(isDark ? Color(white: 1, opacity: 0.4) : Color(white: 0, opacity: 0.38))
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(isDark ? Color(white: 1, opacity: 0.04) : Color(white: 0, opacity: 0.025))
        )
    }
}

/// The plus-with-click-ticks glyph from the design (screen 7 tip icon).
private struct PlusClickIcon: View {
    let plusColor: Color
    let tickColor: Color

    var body: some View {
        ZStack {
            Path { path in
                path.move(to: CGPoint(x: 8, y: 2))
                path.addLine(to: CGPoint(x: 8, y: 14))
                path.move(to: CGPoint(x: 2, y: 8))
                path.addLine(to: CGPoint(x: 14, y: 8))
            }
            .stroke(plusColor, style: StrokeStyle(lineWidth: 1.5, lineCap: .round))

            Path { path in
                path.move(to: CGPoint(x: 4, y: 4))
                path.addLine(to: CGPoint(x: 6, y: 6))
                path.move(to: CGPoint(x: 12, y: 4))
                path.addLine(to: CGPoint(x: 10, y: 6))
            }
            .stroke(tickColor, style: StrokeStyle(lineWidth: 1.2, lineCap: .round))
        }
    }
}
