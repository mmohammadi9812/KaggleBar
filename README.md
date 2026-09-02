<p align="center">
  <img src="Sources/KaggleBar/Resources/logo.png" alt="KaggleBar" width="120">
</p>

<h1 align="center">KaggleBar</h1>

<p align="center">
  GPU quota, accounts, and running sessions, right in your menu bar.
</p>

<p align="center">
  <a href="https://github.com/mmohammadi9812/KaggleBar/actions/workflows/ci.yml"><img src="https://github.com/mmohammadi9812/KaggleBar/actions/workflows/ci.yml/badge.svg" alt="CI"></a>
  <img src="https://img.shields.io/badge/macOS-14%2B-black" alt="macOS 14+">
  <img src="https://img.shields.io/badge/Swift-6.1%2B-F05138?logo=swift&logoColor=white" alt="Swift">
  <img src="https://img.shields.io/badge/license-MIT-blue" alt="MIT License">
</p>

---

A tiny native SwiftUI menu bar app that shows your Kaggle GPU/TPU quota at a glance, lets you switch accounts with one click, and monitors active and recent notebook kernels. No Electron, no daemons, no telemetry. Just a ~1 MB binary.

## Install

```sh
brew tap mmohammadi9812/tap
brew install --cask kagglebar
```

Or [download the latest DMG](https://github.com/mmohammadi9812/KaggleBar/releases/latest/download/KaggleBar.dmg) and drag to Applications.

## Build from source

Requires Xcode Command Line Tools (`xcode-select --install`).

```sh
git clone https://github.com/mmohammadi9812/KaggleBar.git
cd KaggleBar
./Scripts/compile_and_run.sh   # build, bundle, and launch
make package                    # build + bundle a release .app (no launch)
make check                      # build + test + optional SwiftFormat/SwiftLint
make cli                        # install the kagglebar CLI tool
./build.sh --dmg               # also produce KaggleBar.dmg
```

> Requires [`create-dmg`](https://github.com/create-dmg/create-dmg) for the `--dmg` flag (`brew install create-dmg`).

## CLI

KaggleBar ships with a `kagglebar` command-line tool for terminal access to your quota and kernels:

```sh
kagglebar version     # print the version
kagglebar quota       # fetch Kaggle quota as JSON
kagglebar kernels     # fetch recent kernels as JSON
kagglebar accounts    # list accounts as JSON
```

Install with `make cli`. See [docs/cli.md](docs/cli.md) for the full reference.

## Features

- **Live quota:** GPU and TPU hours remaining with slim progress bars and a weekly reset countdown
- **Account switching:** one click writes the active credentials to `~/.kaggle/kaggle.json` (`0600`), so your terminal `kaggle` CLI and Python SDK switch immediately
- **OAuth aware:** picks up sessions from `kaggle auth login` automatically, no extra setup
- **Kernels list:** shows active/running notebooks and recently executed kernels with relative run times and status indicators. Click any kernel to open it directly.
- **Menu bar label:** choose between GPU quota, username, both, or icon only
- **Launch at login:** native `SMAppService` with a LaunchAgent fallback

## Credits

Logo by [Megan Risdal](https://twitter.com/MeganRisdal).

## License

[MIT](LICENSE)
