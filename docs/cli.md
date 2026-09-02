# `kagglebar` CLI

The KaggleBar command-line tool mirrors the menu-bar app's data layer. It shares
`KaggleBarCore` with the app — no logic duplication.

## Installation

```sh
make cli              # build release + install to ~/.local/bin (or /usr/local/bin)
# or
swift build -c release --target KaggleBarCLI
cp .build/release/KaggleBarCLI /usr/local/bin/kagglebar
```

## Commands

### `kagglebar quota`

Fetch your Kaggle GPU/TPU quota and print it as JSON.

```sh
$ kagglebar quota
[
  {
    "resource": "GPU",
    "used": "1.23h",
    "remaining": "28.77h",
    "total": "30.00h",
    "refreshAt": "2025-09-07T00:00:00Z"
  }
]
```

Fetches via the `kaggle` CLI subprocess first, then falls back to the Kaggle
REST API if a credential is available in `~/.kaggle/kaggle.json`.

### `kagglebar kernels`

List your recent and active kernels as JSON.

```sh
$ kagglebar kernels
[
  {
    "ref": "user/notebook-slug",
    "title": "My Notebook",
    "status": "running",
    ...
  }
]
```

### `kagglebar accounts`

Print the active account and all configured accounts (including OAuth).

```sh
$ kagglebar accounts
{
  "active": "user1",
  "accounts": [
    { "username": "user1", "isOAuth": false, "hasKey": true },
    { "username": "oauth-user", "isOAuth": true, "hasKey": false }
  ]
}
```

### `kagglebar version`

Print the KaggleBar version.

```sh
$ kagglebar version
1.0.0
```

### `kagglebar --version`

Same as `version` (provided by Swift Argument Parser).

## Exit Codes

| Code | Meaning |
|---|---|
| 0 | Success |
| non-zero | Error (invalid command, parsing failure, or network error) |
