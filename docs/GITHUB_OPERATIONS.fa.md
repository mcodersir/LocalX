# عملیات GitHub (فارسی)

این سند روش حرفه‌ای مدیریت LocalX روی GitHub را توضیح می‌دهد.

## 1. استانداردهای مخزن

1. شاخه اصلی: `main`
2. فرمت tag: `vX.Y.Z`
3. تریگر ریلیز: هر tag با الگوی `v*`
4. باندل‌های حجیم با Git LFS در `assets/bundles/**`

## 2. جریان CI/CD

فایل Workflow:

- `.github/workflows/release.yml`

Jobها:

1. `build-windows`
2. `build-linux`
3. `publish-release`

خروجی‌ها:

1. `LocalX-windows-x64.zip`
2. `LocalX-linux-x64.tar.gz`
3. `SHA256SUMS`

## 3. روش انتشار (برای Maintainer)

```bash
git checkout main
git pull --rebase
git tag -a v1.2.0 -m "Release v1.2.0"
git push origin v1.2.0
```

بعد از push، وضعیت را اینجا چک کن:

- https://github.com/mcodersir/LocalX/actions
- https://github.com/mcodersir/LocalX/releases

## 4. مدیریت خطای ریلیز

1. Run خراب‌شده را در Actions باز کن
2. Job/Step خطادار را دقیق پیدا کن
3. اصلاح را روی `main` اعمال کن
4. دوباره release را با patch tag جدید منتشر کن (مثلاً `v1.2.1`)
5. tag قدیمی را reuse نکن

## 5. چک‌لیست امنیت

1. هیچ Secret یا Token داخل کد نگذار
2. فقط از GitHub Secrets استفاده کن
3. در صورت نشت توکن، سریع revoke/rotate کن
4. قبل از انتشار عمومی، چک‌سام خروجی‌ها را بررسی کن

## 6. پیشنهاد Branch Protection

1. ادغام مستقیم به `main` ممنوع (فقط PR)
2. پاس شدن Status Checkها اجباری
3. Force-push روی `main` غیرفعال
4. امضای Tagها (اختیاری ولی حرفه‌ای)

## 7. فرآیند پشتیبانی

1. باگ‌ها: Issue با مراحل بازتولید + لاگ
2. مشکل نسخه: شماره tag + سیستم‌عامل دقیق
3. گزارش امنیتی: ترجیحاً به‌صورت private advisory
