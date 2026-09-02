# Development

## Prerequisites

- macOS 14.0+
- Swift 6.1+ (Xcode Command Line Tools suffice; Xcode.app is **not** required for builds or tests)
- [`create-dmg`](https://github.com/create-dmg/create-dmg) (only needed for `--dmg`)

## Quick Start

```sh
# 1. Build everything (debug)
swift build

# 2. Run tests
swift test

# 3. Full lint + build + test
make check

# 4. Build, bundle, and launch the menu-bar app
./Scripts/compile_and_run.sh

# 5. Or just build + bundle (no launch)
make package
```

## Project Structure

See [architecture.md](architecture.md) for the full layout. The key principle:
**all shared logic lives in `KaggleBarCore`**; the app and CLI are thin shells.

## Testing

Tests use [Swift Testing](https://github.com/apple/swift-testing) (not XCTest).
`AccountStoreTests` injects a `KagglePaths` pointing to a temp directory so no
writes escape the test sandbox.

```sh
# Run all tests
swift test

# Run a specific test
swift test --filter QuotaItemTests

# Run tests + lint + build
make check
```

### Adding a test

Create a new `final class` or top-level `@Test` function in `Tests/KaggleBarCoreTests/`.
The file will be discovered automatically by Swift Testing.

## Linting

SwiftFormat and SwiftLint are **optional** — `make check` skips them if not
installed, so local builds never hard-fail. To enable:

```sh
brew install swiftformat swiftlint
make check
```

## Code Style

- 4-space indentation
- 120-character line limit (`xcodeformat`, `swiftlint`)
- `@Observable` / `@Bindable` for state (macOS 14+)
- No live-network tests in CI or locally
- Commit style: conventional commits (`feat:`, `fix:`, `refactor:`)
