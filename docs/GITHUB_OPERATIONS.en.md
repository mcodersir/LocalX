# GitHub Operations (English)

This document explains how to run LocalX professionally on GitHub.

## 1. Repository Standards

1. Default branch: `main`
2. Tag format: `vX.Y.Z`
3. Release trigger: push tag matching `v*`
4. Large bundles tracked with Git LFS (`assets/bundles/**`)

## 2. CI/CD Workflow

Workflow file:

- `.github/workflows/release.yml`

Jobs:

1. `build-windows`
2. `build-linux`
3. `publish-release`

Output assets:

1. `LocalX-windows-x64.zip`
2. `LocalX-linux-x64.tar.gz`
3. `SHA256SUMS`

## 3. Release Procedure (Maintainer)

```bash
git checkout main
git pull --rebase
git tag -a v1.2.0 -m "Release v1.2.0"
git push origin v1.2.0
```

Then monitor:

- https://github.com/mcodersir/LocalX/actions
- https://github.com/mcodersir/LocalX/releases

## 4. Handling Failed Releases

1. Open failed run in Actions
2. Identify failing job and step
3. Fix in `main`
4. Push fix commit
5. Create next patch tag (`v1.2.1`), do not reuse old tag

## 5. Security Checklist

1. Never hard-code secrets in repository
2. Use GitHub Secrets for any required credentials
3. Rotate leaked tokens immediately
4. Validate release checksums before announcing builds

## 6. Recommended Branch Protection

1. Require pull request before merge
2. Require status checks to pass
3. Restrict force-push on `main`
4. Require signed tags for releases (optional advanced)

## 7. Issue and Support Workflow

1. Bugs: open GitHub Issue with logs and reproduction
2. Release regressions: include tag (`vX.Y.Z`) and OS details
3. Security reports: use private security advisory channel when possible
