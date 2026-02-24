# دليل LocalX (العربية)

<p align="center">
  <img src="../assets/icons/localx.png" alt="شعار LocalX" width="96" />
</p>

## اختيار اللغة

- English: [README.en.md](README.en.md)
- فارسي: [README.fa.md](README.fa.md)
- العربية: [README.ar.md](README.ar.md)
- 中文: [README.zh.md](README.zh.md)

LocalX منصة احترافية لادارة بيئة التطوير المحلي على Windows و Linux.

## 1. نطاق المنتج

LocalX يجمع بين:

1. ادارة تشغيل الخدمات (Apache, MySQL, PHP, Node.js, Redis, PostgreSQL, Memcached, Python, Mailhog, SMTP, WebSocket)
2. تثبيت الاصدارات والتبديل بينها
3. معالج انشاء مشاريع لاطر العمل الحديثة
4. ربط النطاقات المحلية عبر ملف hosts
5. توزيع التحديثات عبر GitHub Releases

## 2. معمارية Real-First

تم تنفيذ المشروع بسلوك تشغيلي فعلي:

1. تشغيل حقيقي للخدمات بدون محاكاة
2. تشغيل Native اولا مع Docker fallback تلقائي
3. Manifest للحزم مع تحقق SHA-256
4. انشاء المشاريع عبر generator رسمي ثم fallback الى template snapshot
5. مخرجات اصدار Windows و Linux من GitHub Actions

## 3. ابدأ من هنا

- التثبيت السريع: [INSTALL.ar.md](INSTALL.ar.md)
- عمليات GitHub: [GITHUB_OPERATIONS.ar.md](GITHUB_OPERATIONS.ar.md)

## 4. بوابة الجودة

قبل نشر اي تعديل:

```bash
flutter pub get
flutter analyze
flutter test
```

يجب نجاح جميع الفحوصات.

## 5. ملفات الاصدار

كل tag يطابق `v*` يجب ان ينشر:

1. `LocalX-windows-x64.zip`
2. `LocalX-linux-x64.tar.gz`
3. `SHA256SUMS`

## 6. الترخيص

LocalX برنامج احتكاري. لا توجد اي صلاحية استخدام او نسخ او تعديل او توزيع بدون موافقة خطية صريحة من MCODERs.
راجع [../LICENSE](../LICENSE).

## 7. الدعم

- Issues: https://github.com/mcodersir/LocalX/issues
- Releases: https://github.com/mcodersir/LocalX/releases
- Actions: https://github.com/mcodersir/LocalX/actions
