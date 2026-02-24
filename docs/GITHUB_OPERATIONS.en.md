# GitHub Operations (English)

This document defines the professional GitHub workflow for LocalX maintainers.

## 1. Repository Policy

1. Default branch is `main`
2. Release tags must use `vX.Y.Z`
3. A push to any `v*` tag triggers release workflow
4. Heavy bundles are tracked with Git LFS under `assets/bundles/**`

## 2. Release Workflow

Workflow file:

- `.github/workflows/release.yml`

Jobs:

1. `build-windows`
2. `build-linux`
3. `publish-release`

Published assets:

1. `LocalX-windows-x64-installer.exe`
2. `LocalX-windows-x64.zip`
3. `LocalX-linux-x64-installer.deb`
4. `LocalX-linux-x64.tar.gz`
5. `SHA256SUMS`

## 3. Standard Release Procedure

```bash
git checkout main
git pull --rebase
git tag -a v1.2.0 -m "Release v1.2.0"
git push origin v1.2.0
```

Then verify pipeline and assets:

- https://github.com/mcodersir/LocalX/actions
- https://github.com/mcodersir/LocalX/releases

## 4. Hotfix Procedure

1. Open failed run in Actions
2. Identify exact failed step
3. Fix issue in `main`
4. Push fix commit
5. Publish a new patch tag (example: `v1.2.1`)

Never reuse a previously published tag.

## 5. Security Checklist

1. Do not commit tokens or secrets
2. Store credentials only in GitHub Secrets
3. Revoke and rotate any leaked token immediately
4. Verify release checksums before public announcement
5. Enforce branch protection rules on `main`

## 6. Recommended Branch Protection

1. Pull request required before merge
2. Required status checks must pass
3. Force push blocked on `main`
4. Optional: signed tags for release provenance

## 7. Operational Notes

1. Keep release notes explicit: changes, fixes, known risks
2. Attach SHA256SUMS in every release
3. Keep docs in all supported languages synchronized
4. Confirm license banner and badges stay consistent in root README
