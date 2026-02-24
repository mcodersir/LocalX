# مستندات LocalX (فارسي)

<p align="center">
  <img src="../assets/icons/localx.png" alt="لوگو LocalX" width="96" />
</p>

## انتخاب زبان

- English: [README.en.md](README.en.md)
- فارسي: [README.fa.md](README.fa.md)
- العربية: [README.ar.md](README.ar.md)
- 中文: [README.zh.md](README.zh.md)

LocalX يک ابزار حرفه اي دسکتاپ براي مديريت محيط توسعه محلي در ويندوز و لينوکس است.

## 1. دامنه محصول

LocalX اين بخش ها را يکپارچه مي کند:

1. مديريت اجراي سرويس ها (Apache, MySQL, PHP, Node.js, Redis, PostgreSQL, Memcached, Python, Mailhog, SMTP, WebSocket)
2. نصب و سوييچ نسخه ها
3. جادوگر ساخت پروژه براي فريم ورک هاي مدرن
4. دامنه هاي محلي (ويرايش hosts)
5. انتشار نسخه از طريق GitHub Releases

## 2. معماري Real-First

اين پروژه به شکل واقعي و عملياتي پياده سازي شده است:

1. اجراي واقعي سرويس ها (بدون شبيه سازي)
2. اولويت Native با fallback خودکار به Docker
3. مانيفست باندل و اعتبارسنجي SHA-256
4. ساخت پروژه با generator رسمي و fallback به template آفلاین
5. خروجي ريليز ويندوز و لينوکس از GitHub Actions

## 3. شروع سريع

- نصب ساده: [INSTALL.fa.md](INSTALL.fa.md)
- راهنماي عمليات GitHub: [GITHUB_OPERATIONS.fa.md](GITHUB_OPERATIONS.fa.md)

## 4. گيت کيفيت

قبل از انتشار هر تغيير:

```bash
flutter pub get
flutter analyze
flutter test
```

هر 3 مرحله بايد بدون خطا پاس شوند.

## 5. خروجي هاي ريليز

هر tag با الگوي `v*` اين فايل ها را منتشر مي کند:

1. `LocalX-windows-x64.zip`
2. `LocalX-linux-x64.tar.gz`
3. `SHA256SUMS`

## 6. امنيت و يکپارچگي

1. باندل هاي حجيم با Git LFS نگهداري مي شوند.
2. هنگام نصب، checksum باندل ها اعتبارسنجي مي شود.
3. کاربر نهايي بايد فايل ها را با `SHA256SUMS` تطبيق دهد.

## 7. مدل لايسنس

LocalX نرم افزار انحصاري است. بدون مجوز کتبي MCODERs هيچ حقي براي استفاده يا کپي برداري وجود ندارد.
فايل [../LICENSE](../LICENSE) را ببين.

## 8. مسيرهاي پشتيباني

- Issues: https://github.com/mcodersir/LocalX/issues
- Releases: https://github.com/mcodersir/LocalX/releases
- Actions: https://github.com/mcodersir/LocalX/actions
