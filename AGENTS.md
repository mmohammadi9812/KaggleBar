# AGENTS.md

Guidelines for contributing to KaggleBar.

## Language & Runtime

- Swift 6.1+ (strict concurrency)
- macOS 14.0+ deployment target
- Xcode Command Line Tools is sufficient; Xcode.app is **not** required

## Project Layout

```
Sources/KaggleBarCore/   # Shared logic (no AppKit)
Sources/KaggleBar/       # App target (SwiftUI, AppKit, ServiceManagement)
Sources/KaggleBarCLI/    # CLI target (ArgumentParser)
Tests/KaggleBarCoreTests/  # Swift Testing unit tests
```

- All business logic (API calls, account management, models, date math) goes in
  `KaggleBarCore`.
- The app (`KaggleBar`) and CLI (`KaggleBarCLI`) depend on `KaggleBarCore` — no
  logic duplication.
- AppKit and `ServiceManagement` imports stay in the app target only.

## Style & Formatting

- **SwiftFormat**: 4-space indent, 120-char max line length. Config: `.swiftformat`
- **SwiftLint**: line length 120 warning / 200 error. Config: `.swiftlint.yml`
- Run `make check` to build, test, and optionally lint in one step.
- SwiftLint/SwiftFormat are optional — CI and local builds pass even if they're
  not installed.

## Concurrency

- Use `@Observable` + `@Bindable` for SwiftUI state (no `ObservableObject`,
  `@Published`, `ObservableObject`, `@StateObject`, or `@ObservedObject`).
- `KaggleAPI` is a `Sendable` struct; keep it stateless.
- File I/O in `AccountStore` is synchronous (local disk only); network/CLI
  subprocess calls are `async`.

## Testing

- **Framework**: Swift Testing (`import Testing`), not XCTest.
- `AccountStore` accepts an injectable `KagglePaths` so tests run in a temp
  directory with zero writes outside it.
- **No live-network tests** — `KaggleAPI` methods that hit the network or spawn
  subprocesses are not unit-tested. Mock or inject where possible.
- `calculateResetCountdown(from:)` is a pure static function and is tested with
  fixed date strings.
- Add tests for: new `QuotaItem` math, `KaggleKernel` helpers, `AccountStore`
  file operations, and pure date math.

## Building & Running

```sh
swift build                          # debug build all targets
make package                         # release build + .app bundle
./Scripts/compile_and_run.sh         # build + bundle + launch
make cli                             # install CLI to ~/.local/bin
```

## Commit Style

Use [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add kagglebar CLI accounts subcommand
fix: correct reset countdown day truncation
refactor: extract KaggleAPI from KaggleManager
```
