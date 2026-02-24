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
2. Download `LocalX-windows-x64.zip`
3. Download `SHA256SUMS` (recommended)

### Step 2: Verify (Recommended)

```powershell
Get-FileHash .\LocalX-windows-x64.zip -Algorithm SHA256
```

Compare the output hash with `SHA256SUMS`.

### Step 3: Extract

1. Right click ZIP
2. Select **Extract All...**
3. Extract to `C:\Apps\LocalX` or another clean folder

### Step 4: Run

1. Open extracted folder
2. Run `localx.exe`
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

## 3. Linux

### Step 1: Download

1. Open: https://github.com/mcodersir/LocalX/releases/latest
2. Download `LocalX-linux-x64.tar.gz`
3. Download `SHA256SUMS` (recommended)

### Step 2: Verify (Recommended)

```bash
sha256sum LocalX-linux-x64.tar.gz
```

Compare the output with `SHA256SUMS`.

### Step 3: Extract

```bash
mkdir -p ~/Apps/LocalX
tar -xzf LocalX-linux-x64.tar.gz -C ~/Apps/LocalX
```

### Step 4: Install Runtime Dependencies (Ubuntu/Debian)

```bash
sudo apt-get update
sudo apt-get install -y libgtk-3-0 libayatana-appindicator3-1 libnotify4 libsecret-1-0
```

### Step 5: Run

```bash
cd ~/Apps/LocalX
./localx
```

### Step 6: Optional Desktop Launcher

Create a `.desktop` file pointing to `~/Apps/LocalX/localx`.

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
