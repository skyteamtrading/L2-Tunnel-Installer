# روش ۳: CDN + HalfDuplex + RealityTls (چندلایه)

## معماری
ایران: TAP -> HalfDuplex -> RealityTls -> CDN Client -> ArvanCloud -> CDN Server -> RealityTls -> HalfDuplex -> TAP (خارج)

## ویژگی‌ها
- چهار لایه پنهان‌سازی.
- IP خارج می‌تواند کثیف باشد.
- MTU پیش‌فرض ۱۲۰۰.

## مراحل نصب
1. دامنه را در ArvanCloud مشابه روش ۲ تنظیم کنید.
2. اسکریپت را روی هر دو سرور اجرا کرده و روش ۳ را انتخاب کنید.
3. دامنه را وارد کنید.

## تست
از ایران `ping 10.0.0.2` را اجرا کنید.
