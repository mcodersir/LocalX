# GitHub 运维文档 (中文)

本文档定义 LocalX 在 GitHub 上的专业发布与运维流程。

## 1. 仓库策略

1. 默认分支为 `main`
2. 发布标签格式必须为 `vX.Y.Z`
3. 任意匹配 `v*` 的 tag push 会触发发布流程
4. 大体积 bundle 使用 Git LFS 管理，路径 `assets/bundles/**`

## 2. 发布工作流

工作流文件:

- `.github/workflows/release.yml`

作业:

1. `build-windows`
2. `build-linux`
3. `publish-release`

发布产物:

1. `LocalX-windows-x64.zip`
2. `LocalX-linux-x64.tar.gz`
3. `SHA256SUMS`

## 3. 标准发布流程

```bash
git checkout main
git pull --rebase
git tag -a v1.2.0 -m "Release v1.2.0"
git push origin v1.2.0
```

随后检查:

- https://github.com/mcodersir/LocalX/actions
- https://github.com/mcodersir/LocalX/releases

## 4. 热修复流程

1. 在 Actions 打开失败任务
2. 定位失败步骤
3. 在 `main` 修复问题
4. 推送修复提交
5. 发布新的补丁标签，例如 `v1.2.1`

不要复用已发布标签。

## 5. 安全清单

1. 不要在仓库提交任何 Token 或 Secret
2. 凭据仅存放在 GitHub Secrets
3. 如有泄露，立即撤销并轮换
4. 对外发布前必须校验 checksum
5. 为 `main` 启用分支保护

## 6. 推荐分支保护设置

1. 合并必须通过 Pull Request
2. 必须通过状态检查
3. 禁止 `main` Force Push
4. 可选启用签名 tag 提升可追溯性

## 7. 运维建议

1. Release Notes 需明确写出变化、修复、已知风险
2. 每次发布都附带 `SHA256SUMS`
3. 多语言文档保持同步更新
4. 定期检查根 README 的 Logo、Stars、License 徽章是否有效
