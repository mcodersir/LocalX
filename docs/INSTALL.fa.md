# راهنمای نصب (فارسی)

این راهنما برای کاربری نوشته شده که می‌خواهد خیلی ساده و سریع LocalX را اجرا کند.

## نصب روی ویندوز

### 1. دانلود

1. وارد این لینک شو: https://github.com/mcodersir/LocalX/releases/latest
2. فایل `LocalX-windows-x64.zip` را دانلود کن
3. فایل `SHA256SUMS` را هم برای اعتبارسنجی دانلود کن (پیشنهادی)

### 2. استخراج

1. روی فایل ZIP راست‌کلیک کن
2. گزینه **Extract All...** را بزن
3. در مسیر دلخواه مثل `C:\Apps\LocalX` استخراج کن

### 3. اجرا

1. وارد پوشه استخراج‌شده شو
2. فایل `localx.exe` را اجرا کن
3. اگر Windows Defender پیام داد، اجازه اجرا بده

### 4. راه‌اندازی اولیه

1. زبان و تم را انتخاب کن
2. اجازه بده Setup Wizard سیستم را اسکن کند
3. هر ابزار لازم که Missing است را نصب کن
4. وارد داشبورد شو

### 5. اجرای Administrator (در صورت نیاز)

برای تغییر hosts و پورت‌های سیستمی:

1. روی `localx.exe` راست‌کلیک کن
2. **Run as administrator** را بزن

### 6. آپدیت

1. نسخه جدید ZIP را از Releases بگیر
2. برنامه را ببند
3. فایل‌های جدید را جایگزین قبلی کن
4. دوباره اجرا کن

## نصب روی لینوکس

### 1. دانلود

1. وارد لینک Releases شو: https://github.com/mcodersir/LocalX/releases/latest
2. فایل `LocalX-linux-x64.tar.gz` را دانلود کن
3. فایل `SHA256SUMS` را هم دانلود کن

### 2. استخراج

```bash
mkdir -p ~/Apps/LocalX
tar -xzf LocalX-linux-x64.tar.gz -C ~/Apps/LocalX
```

### 3. اجرا

```bash
cd ~/Apps/LocalX
./localx
```

### 4. پیش‌نیازهای احتمالی

روی Ubuntu/Debian:

```bash
sudo apt-get update
sudo apt-get install -y libgtk-3-0 libayatana-appindicator3-1 libnotify4 libsecret-1-0
```

## اعتبارسنجی فایل دانلودی (پیشنهادی)

PowerShell ویندوز:

```powershell
Get-FileHash .\LocalX-windows-x64.zip -Algorithm SHA256
```

لینوکس:

```bash
sha256sum LocalX-linux-x64.tar.gz
```

خروجی را با `SHA256SUMS` مقایسه کن.

## حذف برنامه

1. LocalX را کامل ببند
2. پوشه برنامه را حذف کن
3. در صورت نیاز داده‌های محلی را هم حذف کن:
   - ویندوز: `%APPDATA%\LocalX`
   - لینوکس: `~/.local/share/LocalX`
