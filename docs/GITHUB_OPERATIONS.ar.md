# عمليات GitHub (العربية)

هذا المستند يوضح اسلوب ادارة LocalX على GitHub بشكل احترافي.

## 1. سياسة المستودع

1. الفرع الافتراضي هو `main`
2. صيغة الوسم يجب ان تكون `vX.Y.Z`
3. اي push على وسم مطابق `v*` يشغل Workflow الاصدار
4. الحزم الكبيرة تتبع عبر Git LFS في `assets/bundles/**`

## 2. سير عمل الاصدار

ملف Workflow:

- `.github/workflows/release.yml`

الوظائف:

1. `build-windows`
2. `build-linux`
3. `publish-release`

الملفات المنشورة:

1. `LocalX-windows-x64.zip`
2. `LocalX-linux-x64.tar.gz`
3. `SHA256SUMS`

## 3. اجراء الاصدار القياسي

```bash
git checkout main
git pull --rebase
git tag -a v1.2.0 -m "Release v1.2.0"
git push origin v1.2.0
```

ثم راقب:

- https://github.com/mcodersir/LocalX/actions
- https://github.com/mcodersir/LocalX/releases

## 4. اجراء الاصلاح السريع

1. افتح التشغيل الفاشل في Actions
2. حدد خطوة الفشل بدقة
3. اصلح المشكلة على `main`
4. ادفع commit جديد
5. انشر patch tag جديد مثل `v1.2.1`

لا تعد استخدام tag تم نشره مسبقا.

## 5. قائمة الامان

1. لا تحفظ اي Token او Secret داخل المستودع
2. استخدم GitHub Secrets فقط
3. الغ اي token مسرب وقم بتدويره فورا
4. تحقق من checksum قبل الاعلان عن الاصدار
5. فعّل Branch protection على `main`

## 6. اعدادات Branch Protection المقترحة

1. الدمج فقط عبر Pull Request
2. اجبار نجاح فحوصات الحالة
3. منع Force Push على `main`
4. توقيع tags اختياريا لرفع موثوقية الاصدار

## 7. ملاحظات تشغيلية

1. اكتب Release Notes بوضوح: التغييرات، الاصلاحات، المخاطر المعروفة
2. ارفق `SHA256SUMS` مع كل اصدار
3. حافظ على مزامنة التوثيق بكل اللغات المدعومة
4. تحقق من شارة الترخيص وشارة النجوم في README الرئيسي
