# Installation Guide (English)

This guide is written for first time users and focuses on a simple and reliable setup.

## 1. System Requirements

- Windows 10/11 x64 or Linux x64
- At least 4 GB RAM (8 GB recommended)
- At least 2 GB free disk space
- Docker Desktop / Docker Engine (recommended for fallback runtime)

## 2. Windows

### Step 1: Download

1. Open: https://github.com/mcodersir/LocalX/releases/latest
2. Download `LocalX-windows-x64-installer.exe`
3. Optional portable package: `LocalX-windows-x64.zip`
4. Download `SHA256SUMS` (recommended)

### Step 2: Verify (Recommended)

```powershell
Get-FileHash .\LocalX-windows-x64-installer.exe -Algorithm SHA256
```

Compare the output hash with `SHA256SUMS`.

### Step 3: Install

1. Right click `LocalX-windows-x64-installer.exe`
2. Select **Run as administrator**
3. Complete setup wizard (install path, shortcuts, launch option)

### Step 4: Run

1. Open Start Menu and run `LocalX`
2. If needed, run the desktop shortcut
3. If Windows Defender prompts, choose **More info** then **Run anyway** only if hash check passed

### Step 5: First Launch

1. Select language and theme
2. Run Setup Wizard scan
3. Install missing tools from Versions section
4. Start required services from Dashboard

### Step 6: Optional Admin Mode

For hosts file updates and privileged ports:

1. Right click `localx.exe`
2. Choose **Run as administrator**

### Step 7: Portable Alternative (No Installer)

If you prefer portable mode:

1. Extract `LocalX-windows-x64.zip` to a clean folder (example: `C:\Apps\LocalX`)
2. Run `localx.exe` from extracted folder

## 3. Linux

### Step 1: Download

1. Open: https://github.com/mcodersir/LocalX/releases/latest
2. Download `LocalX-linux-x64-installer.deb`
3. Optional portable package: `LocalX-linux-x64.tar.gz`
4. Download `SHA256SUMS` (recommended)

### Step 2: Verify (Recommended)

```bash
sha256sum LocalX-linux-x64-installer.deb
```

Compare the output with `SHA256SUMS`.

### Step 3: Install Installer Package (Ubuntu/Debian)

```bash
sudo apt-get update
sudo apt-get install -y ./LocalX-linux-x64-installer.deb
```

### Step 4: Fix Dependencies (If Needed)

```bash
sudo apt-get install -f -y
```

### Step 5: Run

```bash
localx
```

### Step 6: Optional Desktop Launcher

Installer already provides desktop integration.

### Step 7: Portable Alternative (No Installer)

If you prefer portable mode:

```bash
mkdir -p ~/Apps/LocalX
tar -xzf LocalX-linux-x64.tar.gz -C ~/Apps/LocalX
cd ~/Apps/LocalX
./localx
```

## 4. Update Procedure

1. Close LocalX completely
2. Download latest release asset
3. Verify checksum
4. Replace previous app folder
5. Launch again

## 5. Uninstall

1. Close LocalX
2. Delete app folder
3. Optional cleanup:
   - Windows: `%APPDATA%\LocalX`
   - Linux: `~/.local/share/LocalX`
