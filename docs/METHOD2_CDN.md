# روش ۲: ArvanCloud CDN + WaterWall

## معماری
ایران: TAP <-> WaterWall Client (WSS) <-> ArvanCloud CDN <-> WaterWall Server (WSS) <-> TAP (خارج)

## پیش‌نیازها
- یک دامنه که در ArvanCloud تنظیم شده باشد (پروکسی CDN فعال، SSL روی Full Strict).
- IP خارج می‌تواند **کثیف** باشد.

## مراحل نصب
1. دامنه را در ArvanCloud تنظیم کنید.
2. اسکریپت را روی هر دو سرور اجرا کرده و روش ۲ را انتخاب کنید.
3. در هر دو طرف، دامنه را وارد کنید.

## تست
از ایران `ping 10.0.0.2` را اجرا کنید.
