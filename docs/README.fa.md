# مستندات LocalX (فارسی)

LocalX یک ابزار حرفه‌ای دسکتاپ برای مدیریت محیط توسعه محلی در ویندوز و لینوکس است.

## 1. دامنه محصول

LocalX این بخش‌ها را یکپارچه می‌کند:

1. مدیریت اجرای سرویس‌ها (Apache, MySQL, PHP, Node.js, Redis, PostgreSQL, Memcached, Python, Mailhog, SMTP, WebSocket)
2. نصب و سوییچ نسخه‌ها
3. جادوگر ساخت پروژه برای فریم‌ورک‌های مدرن
4. دامنه‌های محلی (ویرایش hosts)
5. انتشار نسخه از طریق GitHub Releases

## 2. معماری Real-First

این پروژه به‌صورت واقعی و عملیاتی پیاده‌سازی شده است:

1. اجرای واقعی سرویس‌ها (بدون شبیه‌سازی)
2. اولویت Native + fallback خودکار به Docker
3. مانيفست باندل + اعتبارسنجی SHA-256
4. ساخت پروژه با generator رسمی + fallback به template آفلاین
5. خروجی ریلیز واقعی ویندوز/لینوکس از GitHub Actions

## 3. شروع سریع

- نصب ساده: [INSTALL.fa.md](INSTALL.fa.md)
- راهنمای عملیات GitHub: [GITHUB_OPERATIONS.fa.md](GITHUB_OPERATIONS.fa.md)

## 4. گیت کیفیت

قبل از انتشار هر تغییر:

```bash
flutter pub get
flutter analyze
flutter test
```

هر 3 مرحله باید بدون خطا پاس شوند.

## 5. خروجی‌های ریلیز

هر tag با الگوی `v*` باید این فایل‌ها را منتشر کند:

1. `LocalX-windows-x64.zip`
2. `LocalX-linux-x64.tar.gz`
3. `SHA256SUMS`

## 6. امنیت و یکپارچگی

1. باندل‌های حجیم با Git LFS نگهداری می‌شوند.
2. هنگام نصب، چک‌سام باندل‌ها اعتبارسنجی می‌شود.
3. کاربر نهایی باید فایل‌ها را با `SHA256SUMS` بررسی کند.

## 7. مسیرهای پشتیبانی

- Issues: https://github.com/mcodersir/LocalX/issues
- Releases: https://github.com/mcodersir/LocalX/releases
- Actions: https://github.com/mcodersir/LocalX/actions
