# Road Town RP - Admin Logger

سكربت FiveM لإرسال سجلات استخدام الأدمن (qb-admin) و txAdmin للموقع.

## التثبيت

1. انسخ مجلد `roadtown-logger` إلى مجلد `resources` في سيرفر FiveM
2. افتح `config.lua` وغيّر:
   - `Config.WebsiteURL` = رابط موقعك (مثال: `http://31.56.120.150:3000`)
   - `Config.Secret` = المفتاح السري (نفس الموجود في `.env`)
3. أضف في `server.cfg`:
   ```
   ensure roadtown-logger
   ```
4. أعد تشغيل السيرفر

## ملاحظة مهمة

أسماء الـ events في `server.lua` قد تختلف حسب إصدار `qb-admin` عندك.
إذا لم تظهر السجلات، تحقق من أسماء الـ events في ملفات `qb-admin/server/main.lua`.
