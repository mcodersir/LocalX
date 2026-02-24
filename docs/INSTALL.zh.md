# 安装指南 (中文)

本文档用于帮助用户以最简单的方式完成 LocalX 安装。

## 1. 系统要求

- Windows 10/11 x64 或 Linux x64
- 至少 4GB 内存（建议 8GB）
- 至少 2GB 可用磁盘空间
- 建议安装 Docker Desktop / Docker Engine 以支持 fallback 运行

## 2. Windows 安装

### 第 1 步: 下载

1. 打开: https://github.com/mcodersir/LocalX/releases/latest
2. 下载 `LocalX-windows-x64-installer.exe`
3. 可选下载便携版 `LocalX-windows-x64.zip`
4. 下载 `SHA256SUMS`

### 第 2 步: 校验完整性

```powershell
Get-FileHash .\LocalX-windows-x64-installer.exe -Algorithm SHA256
```

将输出值与 `SHA256SUMS` 对比。

### 第 3 步: 解压

1. 右键 ZIP 文件
2. 选择 **Extract All...**
3. 解压到 `C:\Apps\LocalX` 或其他独立目录

### 第 4 步: 运行

1. 打开解压目录
2. 运行 `localx.exe`
3. 如 Defender 弹出提示，请在校验通过后再允许执行

### 第 5 步: 首次配置

1. 选择语言和主题
2. 运行 Setup Wizard 扫描
3. 在 Versions 页面安装缺失工具
4. 在 Dashboard 启动所需服务

### 第 6 步: 管理员模式（可选）

用于修改 hosts 或使用受限端口:

1. 右键 `localx.exe`
2. 选择 **Run as administrator**

## 3. Linux 安装

### 第 1 步: 下载

1. 打开: https://github.com/mcodersir/LocalX/releases/latest
2. 下载 `LocalX-linux-x64-installer.deb`
3. 可选下载便携版 `LocalX-linux-x64.tar.gz`
4. 下载 `SHA256SUMS`

### 第 2 步: 校验完整性

```bash
sha256sum LocalX-linux-x64-installer.deb
```

将输出与 `SHA256SUMS` 对比。

### 第 3 步: 解压

```bash
mkdir -p ~/Apps/LocalX
tar -xzf LocalX-linux-x64.tar.gz -C ~/Apps/LocalX
```

### 第 4 步: 安装运行依赖 (Ubuntu/Debian)

```bash
sudo apt-get update
sudo apt-get install -y libgtk-3-0 libayatana-appindicator3-1 libnotify4 libsecret-1-0
```

### 第 5 步: 运行

```bash
cd ~/Apps/LocalX
./localx
```

## 4. 更新流程

1. 完全退出 LocalX
2. 下载最新发布包
3. 校验 checksum
4. 替换旧应用目录
5. 重新启动

## 5. 卸载

1. 退出 LocalX
2. 删除应用目录
3. 可选清理数据目录:
   - Windows: `%APPDATA%\LocalX`
   - Linux: `~/.local/share/LocalX`
