# Architecture

KaggleBar follows a **three-target** Swift Package Manager layout that separates
concerns and eliminates code duplication between the menu-bar app and the CLI.

```
Sources/
  KaggleBarCore/        Shared business logic (no AppKit)
    Models.swift          Data structures: QuotaItem, KaggleKernel, credentials
    KaggleAPI.swift       Quota/kernel fetching via CLI subprocess + REST fallback
    AccountStore.swift    Credential management (~/.kaggle/ + accounts.json + OAuth)
    KaggleStatus.swift    Result type for a refresh cycle
    Version.swift         Static version string
  KaggleBar/             SwiftUI menu-bar app
    App.swift             @main entry, MenuBarExtra
    KaggleManager.swift   @Observable state holder composing KaggleAPI + AccountStore
    ContentView.swift     Menu UI
    QuotaRow.swift        Progress row view
    KernelRow.swift       Kernel list row view
    Assets.swift          Base64 icon fallbacks + resource loading
    LaunchAtLoginManager.swift
    AppConfig.swift       ~/.config/kagglebar/config.json read/write
    Resources/            Icons (.icns, .png)
  KaggleBarCLI/          Command-line tool (kagglebar)
    main.swift            ArgumentParser subcommands
Tests/
  KaggleBarCoreTests/    Swift Testing unit tests (no live network)
```

## Data Flow

1. **`KaggleManager`** (app or CLI) holds shared state (`quotas`, `kernels`,
   `accounts`, `activeAccount`) and drives the refresh cycle.
2. **`AccountStore`** reads/writes files under `~/.kaggle/` and returns a
   `KaggleAccountsSnapshot`. It is injectable via `KagglePaths` so tests run
   in a temp directory.
3. **`KaggleAPI`** is a stateless `Sendable` struct. Its `refresh(credential:activeAccount:)`
   method tries the `kaggle` CLI first, then falls back to direct REST API calls.
4. **`KaggleStatus`** is the immutable result of a refresh: `{ quotas, kernels,
   resetCountdown, lastUpdated }`.

### `~/.kaggle/` — credentials (never committed)

| File | Purpose |
|---|---|
| `kaggle.json` | Active account's API key (written by `switchAccount`) |
| `accounts.json` | KaggleBar's account index (migrated from legacy `kaggle.json`) |
| `credentials.json` | OAuth session from `kaggle auth login` |

### `~/.config/kagglebar/config.json` — app preferences

```json
{
  "displayMode": "GPU Quota",
  "launchAtLogin": true
}
```

On first launch, display mode is migrated from `UserDefaults` if present;
otherwise defaults to `gpuQuota`.

## Build & Package

- `swift build` — debug build all targets
- `swift test` — run unit tests
- `make check` — build + test + optional SwiftFormat/SwiftLint
- `make cli` — build + install CLI to `~/.local/bin/kagglebar`
- `./Scripts/package_app.sh` — release build, create `.app` bundle, ad-hoc codesign
- `./build.sh` — thin wrapper around `package_app.sh` (keeps `--dmg` / `--no-open` flags)

SPM does not produce a hand-tuned `.app` bundle, so `package_app.sh` creates
`KaggleBar.app/Contents/{MacOS,Resources}` manually, sets `LSUIElement=true`,
and ad-hoc signs. The CLI binary is installed by `bin/install-kagglebar-cli.sh`.
