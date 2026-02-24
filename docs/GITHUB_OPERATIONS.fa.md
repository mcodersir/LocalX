# عمليات GitHub (فارسي)

اين سند روش حرفه اي مديريت LocalX روي GitHub را مشخص مي کند.

## 1. سياست مخزن

1. شاخه اصلي `main` است
2. فرمت tag بايد `vX.Y.Z` باشد
3. هر push به tag با الگوي `v*` ريليز را تريگر مي کند
4. باندل هاي حجيم با Git LFS در `assets/bundles/**` نگهداري مي شوند

## 2. جريان ريليز

فايل workflow:

- `.github/workflows/release.yml`

Jobها:

1. `build-windows`
2. `build-linux`
3. `publish-release`

Assetهاي نهايي:

1. `LocalX-windows-x64-installer.exe`
2. `LocalX-windows-x64.zip`
3. `LocalX-linux-x64-installer.deb`
4. `LocalX-linux-x64.tar.gz`
5. `SHA256SUMS`

## 3. رويه استاندارد انتشار

```bash
git checkout main
git pull --rebase
git tag -a v1.2.0 -m "Release v1.2.0"
git push origin v1.2.0
```

بعد از push اين دو صفحه را بررسي کن:

- https://github.com/mcodersir/LocalX/actions
- https://github.com/mcodersir/LocalX/releases

## 4. رويه Hotfix

1. Run ناموفق را در Actions باز کن
2. مرحله دقيق خطا را پيدا کن
3. اصلاح را روي `main` اعمال کن
4. commit جديد را push کن
5. يک patch tag جديد منتشر کن (مثل `v1.2.1`)

هرگز tag منتشر شده قبلي را reuse نکن.

## 5. چک ليست امنيت

1. Token يا Secret داخل مخزن commit نکن
2. فقط از GitHub Secrets استفاده کن
3. هر توکن نشت شده را فورا revoke و rotate کن
4. قبل از اعلام عمومي، checksum فايل هاي ريليز را چک کن
5. Branch protection براي `main` را فعال نگه دار

## 6. تنظيمات پيشنهادي Branch Protection

1. Merge فقط از طريق Pull Request
2. Status check اجباري
3. Force push روي `main` ممنوع
4. امضاي tag براي provenance (اختياري ولي حرفه اي)

## 7. نکات عملياتي

1. Release note را واضح بنويس: تغييرات، رفع باگ، ريسک شناخته شده
2. در هر ريليز `SHA256SUMS` را ضميمه کن
3. مستندات زبان هاي پشتيباني شده را همگام نگه دار
4. وجود badge ها و متن لايسنس در README اصلي را بررسي کن
