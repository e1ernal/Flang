//
//  UpdateChecker.swift
//  Flang
//
//  Created by e1ernal on 10.07.2026.
//

import Foundation

/// Checks GitHub Releases for a newer version than the running build (FR-13,
/// v1.0 track: an anonymous read of the public Releases API — no Sparkle
/// appcast, no server, no user data sent). Full auto-download via Sparkle is
/// deferred to the paid track, which needs a Developer ID signature.
final class UpdateChecker: ObservableObject {
    struct Release: Equatable {
        let version: String
        let url: URL
    }

    @Published private(set) var isChecking = false
    @Published private(set) var newerRelease: Release?
    @Published private(set) var lastError: String?

    private let repo = "e1ernal/Flang"
    private let session: URLSession
    private let checkInterval: TimeInterval = 24 * 60 * 60

    init(session: URLSession = .shared) {
        self.session = session
    }

    private var currentVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0"
    }

    /// Runs the check only if auto-check is on and a day has passed since the
    /// last one — called once at launch so a new release shows up without the
    /// user having to open Settings.
    @MainActor
    func checkIfDue(settings: SettingsStore) async {
        guard settings.autoCheckForUpdates else { return }
        if let last = settings.lastUpdateCheck, Date().timeIntervalSince(last) < checkInterval {
            return
        }
        await check(settings: settings)
    }

    /// Runs an immediate check and records the timestamp on `settings`.
    @MainActor
    func check(settings: SettingsStore) async {
        isChecking = true
        lastError = nil
        defer { isChecking = false }

        guard let url = URL(string: "https://api.github.com/repos/\(repo)/releases/latest") else { return }
        var request = URLRequest(url: url)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")

        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse else {
                lastError = "Couldn't reach GitHub."
                settings.lastUpdateCheck = Date()
                return
            }

            switch http.statusCode {
            case 404:
                // No release has been published yet (e.g. before v1.0 ships) —
                // an expected state, not a failure worth alarming the user about.
                newerRelease = nil
            case 200...299:
                let payload = try JSONDecoder().decode(GitHubRelease.self, from: data)
                let tag = payload.tagName
                let latestVersion = tag.hasPrefix("v") ? String(tag.dropFirst()) : tag
                if latestVersion.isNewer(than: currentVersion), let releaseURL = URL(string: payload.htmlURL) {
                    newerRelease = Release(version: latestVersion, url: releaseURL)
                } else {
                    newerRelease = nil
                }
            default:
                lastError = "GitHub returned an error (HTTP \(http.statusCode))."
            }
        } catch {
            lastError = "Couldn't check for updates."
        }
        settings.lastUpdateCheck = Date()
    }
}

private struct GitHubRelease: Decodable {
    let tagName: String
    let htmlURL: String

    enum CodingKeys: String, CodingKey {
        case tagName = "tag_name"
        case htmlURL = "html_url"
    }
}

private extension String {
    /// Numeric dot-separated version comparison (e.g. "1.10.0" is newer than "1.9.0").
    func isNewer(than other: String) -> Bool {
        let lhs = split(separator: ".").compactMap { Int($0) }
        let rhs = other.split(separator: ".").compactMap { Int($0) }
        for index in 0..<max(lhs.count, rhs.count) {
            let left = index < lhs.count ? lhs[index] : 0
            let right = index < rhs.count ? rhs[index] : 0
            if left != right { return left > right }
        }
        return false
    }
}
