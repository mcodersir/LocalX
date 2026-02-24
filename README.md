# LocalX

[![Release](https://img.shields.io/github/v/release/mcodersir/LocalX)](https://github.com/mcodersir/LocalX/releases)
[![CI Release](https://img.shields.io/github/actions/workflow/status/mcodersir/LocalX/release.yml?label=Release%20Workflow)](https://github.com/mcodersir/LocalX/actions/workflows/release.yml)
[![License](https://img.shields.io/github/license/mcodersir/LocalX)](LICENSE)

Professional, real-first local development environment manager for **Windows** and **Linux**.

## Languages

- English: [docs/README.en.md](docs/README.en.md)
- فارسی: [docs/README.fa.md](docs/README.fa.md)

## Quick Install

- Windows: [docs/INSTALL.en.md#windows](docs/INSTALL.en.md#windows)
- Linux: [docs/INSTALL.en.md#linux](docs/INSTALL.en.md#linux)
- نصب فارسی: [docs/INSTALL.fa.md](docs/INSTALL.fa.md)

## GitHub Operations

- English: [docs/GITHUB_OPERATIONS.en.md](docs/GITHUB_OPERATIONS.en.md)
- فارسی: [docs/GITHUB_OPERATIONS.fa.md](docs/GITHUB_OPERATIONS.fa.md)

## Latest Release

- Download from: https://github.com/mcodersir/LocalX/releases/latest
- Release assets include:
  - `LocalX-windows-x64.zip`
  - `LocalX-linux-x64.tar.gz`
  - `SHA256SUMS`

## Current Runtime Model

- Native-first service execution
- Automatic Docker fallback
- Bundle integrity verification via SHA-256 manifest
- Official SVG brand icons in key UI flows

## Source Build

```bash
flutter pub get
flutter analyze
flutter test
```

Windows build:

```bash
flutter build windows --release
```

Linux build:

```bash
flutter build linux --release
```
