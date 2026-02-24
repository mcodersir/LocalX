# LocalX Documentation (English)

LocalX is a professional desktop environment manager for local development on Windows and Linux.

## 1. Product Scope

LocalX combines:

1. Service runtime management (Apache, MySQL, PHP, Node.js, Redis, PostgreSQL, Memcached, Python, Mailhog, SMTP, WebSocket)
2. Version installation and switching
3. Project scaffolding wizard for modern frameworks
4. Local domain mapping (hosts file)
5. Release-based update distribution

## 2. Real-First Architecture

This repository is implemented with production-style behavior:

1. Real runtime execution (not simulated)
2. Native-first startup with Docker fallback
3. Bundle manifest + SHA-256 integrity verification
4. Generator-first scaffolding with offline template fallback
5. Windows/Linux dual release assets from GitHub Actions

## 3. Start Here

- Simple install: [INSTALL.en.md](INSTALL.en.md)
- GitHub workflow operations: [GITHUB_OPERATIONS.en.md](GITHUB_OPERATIONS.en.md)

## 4. Quality Gate

Before publishing changes:

```bash
flutter pub get
flutter analyze
flutter test
```

All must pass.

## 5. Release Artifacts

Every release tag (`v*`) should publish:

1. `LocalX-windows-x64.zip`
2. `LocalX-linux-x64.tar.gz`
3. `SHA256SUMS`

## 6. Security and Integrity

1. Large bundles are tracked via Git LFS.
2. Embedded bundle checksums are validated at install-time.
3. Release assets should be validated against `SHA256SUMS` by end users.

## 7. Support Channels

- Issues: https://github.com/mcodersir/LocalX/issues
- Releases: https://github.com/mcodersir/LocalX/releases
- Actions: https://github.com/mcodersir/LocalX/actions
