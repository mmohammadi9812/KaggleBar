# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] — 2025-08-21

### Changed
- **Architecture refactor**: restructured from a single 1,089-line `App.swift` into a multi-module Swift Package Manager project with a three-target layout:
  - `KaggleBarCore` — shared library (API client, account store, models, version) with zero AppKit dependencies
  - `KaggleBar` — SwiftUI menu-bar application target
  - `KaggleBarCLI` — `kagglebar` command-line tool (quota, kernels, accounts, version)
  - `KaggleBarCoreTests` — Swift Testing unit tests
- Adopted `@Observable` / `@Bindable` (macOS 14+) replacing `ObservableObject` / `@Published` / `@StateObject` / `@ObservedObject`
- Migrated display preference from `UserDefaults` to `~/.config/kagglebar/config.json` with automatic UserDefaults backward-compat migration
- Added Makefile (`make build`, `make test`, `make check`, `make cli`, etc.) as the stable dev entry point
- Split build logic: `build.sh` delegates to `Scripts/package_app.sh`; added `Scripts/compile_and_run.sh` and `bin/install-kagglebar-cli.sh`
- Added SwiftFormat and SwiftLint configuration (4-space indent, 120-char lines)
- Bumped minimum deployment target to macOS 14
- Added SwiftLint and SwiftFormat linting (optional — Makefile `check` skips if not installed)

### Added
- **CLI tool** (`kagglebar`) with subcommands: `quota`, `kernels`, `accounts`, `version`
- **Swift Testing** test suite covering `QuotaItem` math, `KaggleKernel` status/URL/time helpers, `AccountStore` file I/O (temp-dir isolated), and `KaggleAPI.calculateResetCountdown` date math
- **Documentation**: `AGENTS.md`, `docs/architecture.md`, `docs/cli.md`, `docs/development.md`
- **Release tooling**: `version.env`, `.swiftformat`, `.swiftlint.yml`

### Security
- Config directory created with `0700` permissions; credential files retain `0600`

### Notes
- No behavioral changes to Kaggle API calls, OAuth detection, CLI subprocess invocation, or `kaggle.json` switching — logic was decomposed verbatim from `KaggleManager`
