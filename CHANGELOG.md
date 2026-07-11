# Changelog

All notable changes to Flang are documented here. Format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versioning follows
[semver](https://semver.org/).

## [Unreleased]

### Changed

- Distribute as a plain zip of Flang.app instead of a DMG. A DMG's own Finder
  icon doesn't survive a plain download from GitHub Releases, while an app
  bundle's icon is ordinary file content that comes through a zip fine.

## [1.0.0] — 2026-07-10

First public release.

### Added

- Menu bar indicator showing the active input source's flag, updated instantly
  on every switch.
- Left-click menu: an exact copy of the system input source switcher (same
  sources, same system-parity items), so it's a drop-in replacement.
- Right-click menu: Settings… and Quit Flang.
- Default flag for every macOS keyboard layout and input method, with a
  language-based fallback and a system-icon/globe last resort.
- Two flag styles: flat flag images or native emoji flags.
- Settings window:
  - **General** — launch at login (on by default), interface language.
  - **Indicator** — independent Flag and Name display settings with a live
    preview.
  - **Input Sources** — per-language personalization (custom flag image,
    custom flag emoji, custom full/short name), with reset and search.
  - **About** — version, update check, license and attribution.
- First-launch welcome window explaining the menu bar flag and the
  right-click Settings shortcut.
- Update check against GitHub Releases (daily automatic check, disable
  toggle, manual "Check for Updates" button).
- "Report a Bug" pre-fills a GitHub issue with the app and macOS version.
- English and Russian interface localization, following the system language
  by default with a manual override.
- VoiceOver accessibility labels throughout the Settings window and menu bar
  indicator.

[1.0.0]: https://github.com/e1ernal/Flang/releases/tag/v1.0.0
