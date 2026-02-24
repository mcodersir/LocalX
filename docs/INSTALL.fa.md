# راهنماي نصب (فارسي)

اين سند براي نصب ساده و مطمين LocalX نوشته شده است.

## 1. پيش نيازها

- ويندوز 10/11 نسخه x64 يا لينوکس x64
- حداقل 4 گيگ RAM (پيشنهادي: 8 گيگ)
- حداقل 2 گيگ فضاي خالي
- Docker Desktop يا Docker Engine براي fallback پيشنهادي است

## 2. نصب روي ويندوز

### مرحله 1: دانلود

1. وارد شو: https://github.com/mcodersir/LocalX/releases/latest
2. فايل `LocalX-windows-x64.zip` را دانلود کن
3. فايل `SHA256SUMS` را هم دانلود کن

### مرحله 2: اعتبارسنجي فايل

```powershell
Get-FileHash .\LocalX-windows-x64.zip -Algorithm SHA256
```

خروجي را با مقدار داخل `SHA256SUMS` مقايسه کن.

### مرحله 3: استخراج

1. روي ZIP راست کليک کن
2. **Extract All...** را بزن
3. در مسير `C:\Apps\LocalX` يا مسير دلخواه استخراج کن

### مرحله 4: اجرا

1. پوشه استخراج شده را باز کن
2. `localx.exe` را اجرا کن
3. اگر Defender هشدار داد، فقط بعد از اعتبارسنجي فايل اجازه اجرا بده

### مرحله 5: راه اندازي اوليه

1. زبان و تم را انتخاب کن
2. Setup Wizard را اجرا کن
3. ابزارهاي missing را از بخش Versions نصب کن
4. سرويس هاي لازم را از Dashboard روشن کن

### مرحله 6: اجراي Administrator (اختياري)

براي تغيير hosts و پورت هاي خاص:

1. روي `localx.exe` راست کليک کن
2. **Run as administrator** را بزن

## 3. نصب روي لينوکس

### مرحله 1: دانلود

1. وارد شو: https://github.com/mcodersir/LocalX/releases/latest
2. فايل `LocalX-linux-x64.tar.gz` را دانلود کن
3. فايل `SHA256SUMS` را هم دانلود کن

### مرحله 2: اعتبارسنجي فايل

```bash
sha256sum LocalX-linux-x64.tar.gz
```

خروجي را با `SHA256SUMS` مقايسه کن.

### مرحله 3: استخراج

```bash
mkdir -p ~/Apps/LocalX
tar -xzf LocalX-linux-x64.tar.gz -C ~/Apps/LocalX
```

### مرحله 4: نصب پيش نيازهاي سيستمي (Ubuntu/Debian)

```bash
sudo apt-get update
sudo apt-get install -y libgtk-3-0 libayatana-appindicator3-1 libnotify4 libsecret-1-0
```

### مرحله 5: اجرا

```bash
cd ~/Apps/LocalX
./localx
```

### مرحله 6: ميانبر دسکتاپ (اختياري)

يک فايل `.desktop` بساز که به `~/Apps/LocalX/localx` اشاره کند.

## 4. آپديت

1. برنامه را کامل ببند
2. نسخه جديد را دانلود کن
3. checksum را چک کن
4. پوشه قبلي را با نسخه جديد جايگزين کن
5. برنامه را دوباره اجرا کن

## 5. حذف برنامه

1. LocalX را کامل ببند
2. پوشه برنامه را پاک کن
3. در صورت نياز داده هاي محلي را پاک کن:
   - ويندوز: `%APPDATA%\LocalX`
   - لينوکس: `~/.local/share/LocalX`
