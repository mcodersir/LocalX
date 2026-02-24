# Installation Guide (English)

This guide is designed for users with no prior setup experience.

## Windows

### 1. Download

1. Open: https://github.com/mcodersir/LocalX/releases/latest
2. Download `LocalX-windows-x64.zip`
3. Download `SHA256SUMS` (recommended)

### 2. Extract

1. Right-click the ZIP file
2. Choose **Extract All...**
3. Extract into a clean folder such as `C:\Apps\LocalX`

### 3. Run

1. Open extracted folder
2. Run `localx.exe`
3. If prompted by Windows Defender, allow the app

### 4. First Launch Setup

1. Choose language and theme
2. Let Setup Wizard scan your system
3. Install missing components from the Install step
4. Finish and launch dashboard

### 5. Optional: Run as Administrator

For hosts-file editing and privileged ports:

1. Right-click `localx.exe`
2. Choose **Run as administrator**

### 6. Update

1. Download latest ZIP from Releases
2. Close LocalX
3. Replace old folder with new files
4. Run again

## Linux

### 1. Download

1. Open: https://github.com/mcodersir/LocalX/releases/latest
2. Download `LocalX-linux-x64.tar.gz`
3. Download `SHA256SUMS` (recommended)

### 2. Extract

```bash
mkdir -p ~/Apps/LocalX
tar -xzf LocalX-linux-x64.tar.gz -C ~/Apps/LocalX
```

### 3. Run

```bash
cd ~/Apps/LocalX
./localx
```

### 4. Required runtime packages (if missing)

On Ubuntu/Debian:

```bash
sudo apt-get update
sudo apt-get install -y libgtk-3-0 libayatana-appindicator3-1 libnotify4 libsecret-1-0
```

### 5. Optional: Desktop shortcut

Create a `.desktop` entry pointing to `~/Apps/LocalX/localx`.

## Verify Download Integrity (Recommended)

Windows PowerShell:

```powershell
Get-FileHash .\LocalX-windows-x64.zip -Algorithm SHA256
```

Linux:

```bash
sha256sum LocalX-linux-x64.tar.gz
```

Compare output with `SHA256SUMS`.

## Uninstall

1. Close LocalX
2. Delete app folder
3. Optional: remove local data directory
   - Windows: `%APPDATA%\LocalX`
   - Linux: `~/.local/share/LocalX`
