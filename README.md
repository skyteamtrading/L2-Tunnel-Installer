
<br>

<p align="center">
  <a href="https://github.com/skyteamtrading/L2-Tunnel-Installer/releases">
    <img src="https://img.shields.io/github/v/release/skyteamtrading/L2-Tunnel-Installer?color=blue&label=Latest&style=for-the-badge" alt="release" />
  </a>
  <a href="https://opensource.org/licenses/MIT">
    <img src="https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge" alt="license" />
  </a>
  <a href="https://github.com/skyteamtrading/L2-Tunnel-Installer/actions/workflows/shellcheck.yml">
    <img src="https://img.shields.io/github/actions/workflow/status/skyteamtrading/L2-Tunnel-Installer/shellcheck.yml?branch=main&style=for-the-badge&label=ShellCheck" alt="ShellCheck" />
  </a>
</p>

<br>

<p align="center">
  ⚡ یک اسکریپت تعاملی Bash برای ساخت تونل امن لایهٔ ۲ (Ethernet Bridge)
  بین سرور ایران (پشت NAT) و سرور خارج از کشور – با ۴ روش متفاوت ⚡
</p>

---

<p align="center">
  <a href="#-همه‌چیز-برای-کپی">📋 همه‌چیز برای کپی</a> &nbsp;&nbsp;
  <a href="#⚡-نصب-سریع">🚀 نصب سریع</a> &nbsp;&nbsp;
  <a href="#🧠-روش‌های-موجود">📚 روش‌ها</a> &nbsp;&nbsp;
  <a href="https://github.com/skyteamtrading/L2-Tunnel-Installer/issues">🐛 گزارش باگ</a>
</p>

---



# ========== نصب (اجرا روی سرور) ==========
bash <(curl -s https://raw.githubusercontent.com/skyteamtrading/L2-Tunnel-Installer/main/l2tunnel.sh)

# ========== تست تونل (از سرور ایران) ==========
ping 10.0.0.2

# ========== معماری روش‌ها (برای مستندات) ==========
# روش ۱: Rathole + WaterWall
ایران: TAP ↔ WaterWall Client ↔ Rathole Client ↔ اینترنت ↔ Rathole Server ↔ WaterWall Server ↔ TAP (خارج)

# روش ۲: CDN (آروان) + WaterWall
ایران: TAP ↔ WaterWall Client (WSS) ↔ ArvanCloud CDN ↔ WaterWall Server (WSS) ↔ TAP (خارج)

# روش ۳: CDN + HalfDuplex + RealityTls (چندلایه)
ایران: TAP → HalfDuplex → RealityTls → CDN Client → ArvanCloud → CDN Server → RealityTls → HalfDuplex → TAP (خارج)

# روش ۴: VLESS Reverse (Xray) + WaterWall
ایران: TAP → WaterWall Client → Xray Client (VLESS+Reality) → Portal (Xray) → Backend (Xray) → WaterWall Server → TAP (خارج)



## 🎯 نمای کلی

| سرور ایران | اتصال | WaterWall | امنیت | Arvan / Rathole | مسیر | سرور خارج |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| <sub>پشت NAT</sub> | <sub>TAP</sub> | <sub>کپسوله‌سازی</sub> | <sub>TLS / WSS</sub> | <sub>عبور از فیلتر</sub> | 🌐 | <sub>IP تمیز / کثیف</sub> |

---

## ✨ ویژگی‌های کلیدی

| | | |
| :--- | :--- | :--- |
| 🧠 ۴ روش تونل‌زنی | ☁️ پشتیبانی از IP کثیف | 🔒 رمزنگاری سرتاسری |
| 🤖 نصب خودکار | 🖥️ منوی تعاملی | 🛡️ ضد فیلترینگ و DPI |

---

## ⚡ نصب سریع

**👇 همین یک خط را در ترمینال اجرا کنید (نیاز به دسترسی root)**

```bash
bash <(curl -s https://raw.githubusercontent.com/skyteamtrading/L2-Tunnel-Installer/main/l2tunnel.sh)
```

---

## 🧠 روش‌های موجود

### ۱. Rathole + WaterWall (TAP)
- **معماری:**
  ```
  ایران: TAP ↔ WaterWall Client ↔ Rathole Client ↔ اینترنت ↔ Rathole Server ↔ WaterWall Server ↔ TAP (خارج)
  ```
- **IP خارج:** تمیز (در لیست سیاه نباشد)
- **امنیت:** ⭐⭐
- **پیچیدگی:** آسان
- **مزایا:** راه‌اندازی سریع، بدون نیاز به دامنه
- **مناسب برای:** زمانی که IP سرور خارج کاملاً سالم است

### ۲. CDN (آروان) + WaterWall
- **معماری:**
  ```
  ایران: TAP ↔ WaterWall Client (WSS) ↔ ArvanCloud CDN ↔ WaterWall Server (WSS) ↔ TAP (خارج)
  ```
- **IP خارج:** می‌تواند کثیف باشد (پشت CDN مخفی می‌شود)
- **امنیت:** ⭐⭐⭐
- **پیچیدگی:** بسیار آسان
- **پیش‌نیاز:** یک دامنه که در ArvanCloud با پروکسی CDN و SSL Full (Strict) تنظیم شده باشد
- **مزایا:** بدون هزینهٔ اضافه، تأخیر کم به دلیل لبه‌های داخلی آروان

### ۳. CDN + HalfDuplex + RealityTls (چندلایه)
- **معماری:**
  ```
  ایران: TAP → HalfDuplex → RealityTls → CDN Client → ArvanCloud → CDN Server → RealityTls → HalfDuplex → TAP (خارج)
  ```
- **IP خارج:** کثیف
- **امنیت:** ⭐⭐⭐⭐ (چهار لایه پنهان‌سازی)
- **پیچیدگی:** متوسط
- **MTU پیش‌فرض:** ۱۲۰۰ برای جلوگیری از تکه‌تکه شدن
- **مزایا:** ضد تحلیل عمیق بسته‌ها، حتی اگر CDN هم مورد بازرسی قرار گیرد

### ۴. VLESS Reverse (Xray) + WaterWall
- **معماری:**
  ```
  ایران: TAP → WaterWall Client → Xray Client (VLESS+Reality) → Portal (Xray) → Backend (Xray) → WaterWall Server → TAP (خارج)
  ```
- **نیازمندی‌ها:** یک سرور پورتال با IP تمیز و یک سرور بک‌اند با IP کثیف
- **امنیت:** ⭐⭐⭐⭐⭐
- **پیچیدگی:** پیشرفته
- **مزایا:** مقیاس‌پذیری بالا، کنترل کامل، امنیت بسیار بالا

---

## 📚 مستندات بیشتر

مستندات و مثال‌های پیکربندی در پوشه‌های `docs` و `examples` موجود است.

---

## 🧪 تست موفقیت‌آمیز بودن تونل

پس از نصب، از سرور ایران پینگ بگیرید:

```bash
ping 10.0.0.2
```

اگر پاسخ گرفتید، تونل لایهٔ ۲ شما برقرار است! 🎉

---

## ❓ پرسش‌های متداول (FAQ)

<details>
<summary><b>کدام روش را انتخاب کنم؟</b></summary>
<br>

- IP تمیز ← روش ۱ (ساده و سریع)
- IP کثیف، هزینهٔ صفر ← روش ۲ (CDN ساده)
- امنیت بسیار بالا + IP کثیف ← روش ۳ (چندلایه)
- کنترل کامل و حرفه‌ای ← روش ۴ (VLESS Reverse)
</details>

<details>
<summary><b>چرا MTU روی ۱۲۰۰ تنظیم می‌شود؟</b></summary>
<br>
به دلیل لایه‌های متعدد کپسوله‌سازی، بسته‌های بزرگ ممکن است تکه‌تکه شوند. کاهش MTU از افت بسته جلوگیری می‌کند.
</details>

<details>
<summary><b>آیا می‌توان از دامنه رایگان استفاده کرد؟</b></summary>
<br>
بله، سرویس‌هایی مانند freedns.afraid.org ساب‌دامین رایگان می‌دهند، اما دامنهٔ واقعی پایدارتر است.
</details>

<details>
<summary><b>اگر سرعت پایین بود چه کنم؟</b></summary>
<br>

- از روش CDN با SNI یک سایت ایرانی (مثلاً www.aparat.com) استفاده کنید.
- سرور خارج را به موقعیتی نزدیک‌تر به ایران ببرید.
</details>

<details>
<summary><b>چطور IP تمیز برای پورتال تهیه کنم؟</b></summary>
<br>
VPSهای جدید از DigitalOcean، Vultr یا Oracle Cloud Always Free معمولاً IPهای تمیز دارند. قبل از استفاده تست کنید.
</details>

<details>
<summary><b>آیا می‌توان رمزهای پیش‌فرض را تغییر داد؟</b></summary>
<br>
بله، در فایل‌های JSON تولید شده پس از نصب می‌توانید رمزها را تغییر دهید. فقط باید در هر دو طرف (ایران و خارج) کاملاً یکسان باشند.
</details>

<details>
<summary><b>در روش VLESS Reverse، اطلاعات کلاینت ایران را از کجا بیاورم؟</b></summary>
<br>
پس از اجرای اسکریپت روی سرور پورتال، اطلاعات لازم (Public Key, ShortId, UUID) نمایش داده می‌شود. آن‌ها را برای سرور ایران وارد کنید.
</details>

---

## 🔧 نکات فنی مهم

- در روش‌های CDN، دامنه باید در ArvanCloud روی حالت SSL Full (Strict) تنظیم شده و پروکسی (ابر نارنجی) فعال باشد.
- رمزهای پیش‌فرض در فایل‌های JSON (MyCDNpass, MyHDpass, MyRLpass) را می‌توانید تغییر دهید، اما باید در دو طرف یکسان باشند.
- در روش VLESS Reverse، UUID و کلیدهای Reality باید بین ایران، پورتال و بک‌اند هماهنگ باشند.
- تمام سرویس‌ها پس از نصب توسط systemd مدیریت می‌شوند و با ری‌استارت سرور فعال باقی می‌مانند.

---

## 📚 مستندات تکمیلی

- [روش ۱: Rathole + WaterWall](docs/METHOD1_RATHOLE.md)
- [روش ۲: CDN ساده](docs/METHOD2_CDN.md)
- [روش ۳: چندلایه](docs/METHOD3_MULTILAYER.md)
- [روش ۴: VLESS Reverse](docs/METHOD4_VLESS_REVERSE.md)
- [❓ FAQ](docs/FAQ.md)

---

## 🤝 مشارکت و حمایت

- [گزارش باگ یا پیشنهاد](https://github.com/skyteamtrading/L2-Tunnel-Installer/issues)
- [راهنمای مشارکت](CONTRIBUTING.md)

⭐ اگر این پروژه برایتان مفید بود، لطفاً ستاره بدهید!

---

<sub>ساخته‌شده با ❤️ برای عبور امن و آزاد | مجوز MIT</sub>
```
