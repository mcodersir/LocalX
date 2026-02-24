# LocalX 文档 (中文)

<p align="center">
  <img src="../assets/icons/localx.png" alt="LocalX Logo" width="96" />
</p>

## 语言切换

- English: [README.en.md](README.en.md)
- فارسي: [README.fa.md](README.fa.md)
- العربية: [README.ar.md](README.ar.md)
- 中文: [README.zh.md](README.zh.md)

LocalX 是一个面向 Windows 和 Linux 的专业本地开发环境管理平台。

## 1. 产品范围

LocalX 提供以下核心能力：

1. 服务运行管理（Apache, MySQL, PHP, Node.js, Redis, PostgreSQL, Memcached, Python, Mailhog, SMTP, WebSocket）
2. 版本安装与切换
3. 现代框架项目向导
4. 本地域名映射（hosts 文件）
5. 基于 GitHub Releases 的版本分发

## 2. Real-First 架构

本仓库已按真实生产行为实现：

1. 服务真实启动与停止（非模拟）
2. Native 优先，失败后自动 Docker fallback
3. Bundle Manifest + SHA-256 完整性校验
4. 官方生成器优先，失败时回退离线模板
5. GitHub Actions 同时产出 Windows/Linux 发布包

## 3. 从这里开始

- 快速安装: [INSTALL.zh.md](INSTALL.zh.md)
- GitHub 运维文档: [GITHUB_OPERATIONS.zh.md](GITHUB_OPERATIONS.zh.md)

## 4. 质量门禁

发布前必须通过：

```bash
flutter pub get
flutter analyze
flutter test
```

## 5. 发布产物

每个符合 `v*` 的 tag 必须生成：

1. `LocalX-windows-x64-installer.exe`
2. `LocalX-windows-x64.zip`
3. `LocalX-linux-x64-installer.deb`
4. `LocalX-linux-x64.tar.gz`
5. `SHA256SUMS`

## 6. 许可模型

LocalX 为专有软件。未经 MCODERs 书面许可，不得使用、复制、修改或分发。
请查看 [../LICENSE](../LICENSE)。

## 7. 支持渠道

- Issues: https://github.com/mcodersir/LocalX/issues
- Releases: https://github.com/mcodersir/LocalX/releases
- Actions: https://github.com/mcodersir/LocalX/actions
