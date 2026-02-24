# LocalX

LocalX is a desktop local-development manager for Windows and Linux. It provides a unified UI for service runtime, version installs, project scaffolding, and local domains.

## What is now real

1. Real service runtime (no fake start/stop simulation).
2. Native-first process launch with Docker fallback when native binaries fail or are missing.
3. Official framework/service brand icons (Simple Icons SVG) in setup, wizard, versions, dashboard, and project cards.
4. Real bundle manifest with SHA-256 integrity checks (`assets/bundles/manifest.json`).
5. Real hybrid template flow: generator-first, offline template fallback.
6. GitHub Actions release pipeline that publishes Windows and Linux artifacts from a single tag.

## Core features

1. One-click stack services (Apache, MySQL, PHP, Node.js, Redis, PostgreSQL, Memcached, Python, Mailhog, SMTP, WebSocket)
2. Version Manager with install/switch workflows
3. New Project Wizard (Laravel, React, Vue, Next.js, Svelte, Angular, Nuxt, Node.js, PHP, FastAPI, Django, WordPress)
4. Custom local domains (hosts-file mapping)
5. Setup Wizard with environment scan and guided install

## Runtime model

- `Native`: Local binary is started directly (`Process.start`).
- `Docker Fallback`: If native start fails, LocalX starts a containerized runtime.
- Runtime metadata is persisted in memory per service: mode, PID/container, health URL, and logs.

## Bundles and manifest

Embedded bundles live under `assets/bundles/`.

Manifest file:

- `assets/bundles/manifest.json`
- Includes: `software`, `version`, `platform`, `archive`, `sha256`, `sourceUrl`, `installMode`

Install behavior:

1. Prefer local user bundles in `%APPDATA%/LocalX/bundles/...`
2. Then embedded bundle + checksum verification
3. Otherwise download from official source URLs

## Build real assets

### Download official SVG brand icons

```powershell
powershell -ExecutionPolicy Bypass -File tools/download_brand_icons.ps1
```

### Rebuild bundle manifest checksums

```powershell
powershell -ExecutionPolicy Bypass -File tools/build_bundle_manifest.ps1
```

### Download/update bundles and regenerate manifest

```powershell
powershell -ExecutionPolicy Bypass -File tools/download_bundles.ps1
```

### Rebuild offline templates

```powershell
powershell -ExecutionPolicy Bypass -File tools/build_real_templates.ps1
```

## Git LFS

Large embedded bundles must be stored with Git LFS.

```bash
git lfs install
git lfs track "assets/bundles/**"
```

Tracked via `.gitattributes`.

## Release workflow

Workflow file: `.github/workflows/release.yml`

Trigger:

- Push a tag like `v1.1.0`

Pipeline:

1. `build-windows` builds and uploads `LocalX-windows-x64.zip`
2. `build-linux` builds and uploads `LocalX-linux-x64.tar.gz`
3. `publish-release` downloads both, generates `SHA256SUMS`, and publishes one GitHub Release

## Local development

```bash
flutter pub get
flutter analyze
flutter test
flutter run -d windows
```

Linux build:

```bash
flutter build linux --release
```

Windows build:

```bash
flutter build windows --release
```
