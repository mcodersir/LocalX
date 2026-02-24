# دليل التثبيت (العربية)

هذا الدليل يشرح طريقة تثبيت LocalX بشكل بسيط وعملي.

## 1. المتطلبات

- Windows 10/11 x64 او Linux x64
- ذاكرة 4 جيجابايت على الاقل (الموصى 8 جيجابايت)
- مساحة فارغة 2 جيجابايت على الاقل
- Docker Desktop او Docker Engine مفضل لحالات fallback

## 2. التثبيت على Windows

### الخطوة 1: التحميل

1. افتح: https://github.com/mcodersir/LocalX/releases/latest
2. حمل `LocalX-windows-x64-installer.exe`
3. حمل النسخة المحمولة الاختيارية `LocalX-windows-x64.zip`
4. حمل `SHA256SUMS`

### الخطوة 2: التحقق من سلامة الملف

```powershell
Get-FileHash .\LocalX-windows-x64-installer.exe -Algorithm SHA256
```

قارن القيمة مع `SHA256SUMS`.

### الخطوة 3: فك الضغط

1. اضغط بزر الفارة الايمن على ملف ZIP
2. اختر **Extract All...**
3. فك الضغط داخل `C:\Apps\LocalX` او اي مجلد نظيف

### الخطوة 4: التشغيل

1. افتح المجلد المستخرج
2. شغل `localx.exe`
3. اذا ظهر تحذير Defender اسمح بالتشغيل بعد التحقق من hash

### الخطوة 5: الاعداد الاول

1. اختر اللغة والمظهر
2. شغل Setup Wizard
3. ثبت الادوات الناقصة من قسم Versions
4. شغل الخدمات المطلوبة من Dashboard

### الخطوة 6: تشغيل كمسؤول (اختياري)

لاجل تعديل hosts او المنافذ الخاصة:

1. اضغط يمين على `localx.exe`
2. اختر **Run as administrator**

## 3. التثبيت على Linux

### الخطوة 1: التحميل

1. افتح: https://github.com/mcodersir/LocalX/releases/latest
2. حمل `LocalX-linux-x64-installer.deb`
3. حمل النسخة المحمولة الاختيارية `LocalX-linux-x64.tar.gz`
4. حمل `SHA256SUMS`

### الخطوة 2: التحقق من سلامة الملف

```bash
sha256sum LocalX-linux-x64-installer.deb
```

قارن الناتج مع `SHA256SUMS`.

### الخطوة 3: فك الضغط

```bash
mkdir -p ~/Apps/LocalX
tar -xzf LocalX-linux-x64.tar.gz -C ~/Apps/LocalX
```

### الخطوة 4: تثبيت الحزم المطلوبة (Ubuntu/Debian)

```bash
sudo apt-get update
sudo apt-get install -y libgtk-3-0 libayatana-appindicator3-1 libnotify4 libsecret-1-0
```

### الخطوة 5: التشغيل

```bash
cd ~/Apps/LocalX
./localx
```

## 4. التحديث

1. اغلق LocalX
2. حمل الاصدار الاحدث
3. تحقق من checksum
4. استبدل مجلد التطبيق القديم
5. اعد التشغيل

## 5. ازالة التثبيت

1. اغلق LocalX
2. احذف مجلد التطبيق
3. اختياري: احذف بيانات المستخدم
   - Windows: `%APPDATA%\LocalX`
   - Linux: `~/.local/share/LocalX`
