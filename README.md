
<!-- Header with animated-type effect -->
<div align="center">
  <img src="https://readme-typing-svg.demolab.com?font=Fira+Code&weight=700&size=28&duration=3000&pause=1000&color=00FFAA&center=true&vCenter=true&width=600&lines=🚀+L2+Tunnel+Installer;%F0%9F%94%92+Layer+2+Ethernet+Bridge;%F0%9F%8C%90+Iran+%E2%86%94+Foreign+Server" alt="Typing SVG" />
</div>

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

<div align="center">
  <pre style="background: linear-gradient(135deg, #0d1117, #161b22); padding: 20px; border-radius: 12px; display: inline-block;">
  ⚡ یک اسکریپت تعاملی Bash برای ساخت تونل امن لایهٔ ۲ (Ethernet Bridge)
  بین سرور ایران (پشت NAT) و سرور خارج از کشور – با ۴ روش متفاوت ⚡
  </pre>
</div>

<br>

---

<div align="center">
  <a href="#⚡-نصب-سریع">
    <img src="https://img.shields.io/badge/🚀_نصب_سریع-کلیک_کنید-00d2ff?style=for-the-badge&logo=rocket&logoColor=white" alt="install" />
  </a>
  &nbsp;&nbsp;
  <a href="#🧠-روش‌های-موجود">
    <img src="https://img.shields.io/badge/📚_روش‌ها-مشاهده-ff8c00?style=for-the-badge&logo=readthedocs&logoColor=white" alt="methods" />
  </a>
  &nbsp;&nbsp;
  <a href="https://github.com/skyteamtrading/L2-Tunnel-Installer/issues">
    <img src="https://img.shields.io/badge/🐛_گزارش_باگ-اینجا-red?style=for-the-badge&logo=bugatti&logoColor=white" alt="issues" />
  </a>
</div>

<br>

---

## 🎯 نمای کلی

<div align="center">
  <table>
    <tr>
      <td align="center" width="200">
        <img src="https://img.icons8.com/fluency/96/iran.png" width="48"/><br>
        <b>سرور ایران</b><br>
        <sub>پشت NAT</sub>
      </td>
      <td align="center" width="100">
        <b>🔗</b><br>
        <sub>TAP</sub>
      </td>
      <td align="center" width="200">
        <img src="https://img.icons8.com/color/96/waterfall.png" width="48"/><br>
        <b>WaterWall</b><br>
        <sub>کپسوله‌سازی</sub>
      </td>
      <td align="center" width="100">
        <b>🔒</b><br>
        <sub>TLS / WSS</sub>
      </td>
      <td align="center" width="200">
        <img src="https://img.icons8.com/color/96/cloud-backup-restore.png" width="48"/><br>
        <b>Arvan / Rathole</b><br>
        <sub>عبور از فیلتر</sub>
      </td>
      <td align="center" width="100">
        <b>🌐</b>
      </td>
      <td align="center" width="200">
        <img src="https://img.icons8.com/fluency/96/globe.png" width="48"/><br>
        <b>سرور خارج</b><br>
        <sub>IP تمیز / کثیف</sub>
      </td>
    </tr>
  </table>
</div>

---
## ✨ ویژگی‌های کلیدی

<div align="center">
  <table>
    <tr>
      <td><img src="https://img.icons8.com/color/48/000000/mind-map.png" width="36"/> <b>۴ روش تونل‌زنی</b></td>
      <td><img src="https://img.icons8.com/color/48/000000/cloud-backup-restore.png" width="36"/> <b>پشتیبانی از IP کثیف</b></td>
    </tr>
    <tr>
      <td><img src="https://img.icons8.com/color/48/000000/encrypted.png" width="36"/> <b>رمزنگاری سرتاسری</b></td>
      <td><img src="https://img.icons8.com/color/48/000000/automation.png" width="36"/> <b>نصب خودکار</b></td>
    </tr>
    <tr>
      <td><img src="https://img.icons8.com/color/48/000000/console.png" width="36"/> <b>منوی تعاملی</b></td>
      <td><img src="https://img.icons8.com/color/48/000000/shield.png" width="36"/> <b>ضد فیلترینگ و DPI</b></td>
    </tr>
  </table>

---

## ⚡ نصب سریع

<div align="center">
  <p><b>👇 همین یک خط را در ترمینال اجرا کنید (نیاز به دسترسی root)</b></p>
  
  ```bash
  bash <(curl -s https://raw.githubusercontent.com/skyteamtrading/L2-Tunnel-Installer/main/l2tunnel.sh)
  ```


---

## 🧠 روش‌های موجود

### ۱. Rathole + WaterWall (TAP)
**معماری:**  
`ایران: TAP ↔ WaterWall Client ↔ Rathole Client ↔ اینترنت ↔ Rathole Server ↔ WaterWall Server ↔ TAP (خارج)`

- **IP خارج:** تمیز (در لیست سیاه نباشد)
- **امنیت:** ⭐⭐
- **پیچیدگی:** آسان
- **مزایا:** راه‌اندازی سریع، بدون نیاز به دامنه
- **مناسب برای:** زمانی که IP سرور خارج کاملاً سالم است

### ۲. CDN (آروان) + WaterWall
**معماری:**  
`ایران: TAP ↔ WaterWall Client (WSS) ↔ ArvanCloud CDN ↔ WaterWall Server (WSS) ↔ TAP (خارج)`

- **IP خارج:** می‌تواند کثیف باشد (پشت CDN مخفی می‌شود)
- **امنیت:** ⭐⭐⭐
- **پیچیدگی:** بسیار آسان
- **پیش‌نیاز:** یک دامنه که در ArvanCloud با پروکسی CDN و SSL **Full (Strict)** تنظیم شده باشد
- **مزایا:** بدون هزینهٔ اضافه، تأخیر کم به دلیل لبه‌های داخلی آروان

### ۳. CDN + HalfDuplex + RealityTls (چندلایه)
**معماری:**  
`ایران: TAP → HalfDuplex → RealityTls → CDN Client → ArvanCloud → CDN Server → RealityTls → HalfDuplex → TAP (خارج)`

- **IP خارج:** کثیف
- **امنیت:** ⭐⭐⭐⭐ (چهار لایه پنهان‌سازی)
- **پیچیدگی:** متوسط
- **MTU پیش‌فرض:** ۱۲۰۰ برای جلوگیری از تکه‌تکه شدن
- **مزایا:** ضد تحلیل عمیق بسته‌ها، حتی اگر CDN هم مورد بازرسی قرار گیرد

### ۴. VLESS Reverse (Xray) + WaterWall
**معماری:**  
`ایران: TAP → WaterWall Client → Xray Client (VLESS+Reality) → Portal (Xray) → Backend (Xray) → WaterWall Server → TAP (خارج)`

- **نیازمندی‌ها:** یک **سرور پورتال** با IP تمیز و یک **سرور بک‌اند** با IP کثیف
- **امنیت:** ⭐⭐⭐⭐⭐
- **پیچیدگی:** پیشرفته
- **مزایا:** مقیاس‌پذیری بالا، کنترل کامل، امنیت بسیار بالا

> **📚 مستندات بیشتر و مثال‌های پیکربندی** در پوشه‌های [docs](docs/) و [examples](examples/) موجود است.  
> برای مطالعه دقیق‌تر هر روش و نمونه فایل‌های پیکربندی، می‌توانید به همان پوشه‌ها مراجعه کنید (اختیاری).

---

## 🧪 تست موفقیت‌آمیز بودن تونل

<div align="center">

```diff
+ پس از نصب، از سرور ایران پینگ بگیرید:
  ping 10.0.0.2
+ اگر پاسخ گرفتید، تونل لایهٔ ۲ شما برقرار است! 🎉
```

</div>

---

## ❓ پرسش‌های متداول (FAQ)

**کدام روش را انتخاب کنم؟**
- IP تمیز ← روش ۱ (ساده و سریع)
- IP کثیف، هزینهٔ صفر ← روش ۲ (CDN ساده)
- امنیت بسیار بالا + IP کثیف ← روش ۳ (چندلایه)
- کنترل کامل و حرفه‌ای ← روش ۴ (VLESS Reverse)

**چرا MTU روی ۱۲۰۰ تنظیم می‌شود؟**  
به دلیل لایه‌های متعدد کپسوله‌سازی، بسته‌های بزرگ ممکن است تکه‌تکه شوند. کاهش MTU از افت بسته جلوگیری می‌کند.

**آیا می‌توان از دامنه رایگان استفاده کرد؟**  
بله، سرویس‌هایی مانند `freedns.afraid.org` ساب‌دامین رایگان می‌دهند، اما دامنهٔ واقعی پایدارتر است.

**اگر سرعت پایین بود چه کنم؟**  
- از روش CDN با SNI یک سایت ایرانی (مثلاً `www.aparat.com`) استفاده کنید.  
- سرور خارج را به موقعیتی نزدیک‌تر به ایران ببرید.

**چطور IP تمیز برای پورتال تهیه کنم؟**  
VPSهای جدید از DigitalOcean، Vultr یا Oracle Cloud Always Free معمولاً IPهای تمیز دارند. قبل از استفاده تست کنید.

**آیا می‌توان رمزهای پیش‌فرض را تغییر داد؟**  
بله، در فایل‌های JSON تولید شده پس از نصب می‌توانید رمزها را تغییر دهید. فقط باید در هر دو طرف (ایران و خارج) کاملاً یکسان باشند.

**در روش VLESS Reverse، اطلاعات کلاینت ایران مثل UUID و کلیدها را از کجا بیاورم؟**  
پس از اجرای اسکریپت روی سرور پورتال، اطلاعات لازم (Public Key, ShortId, UUID) نمایش داده می‌شود. آن‌ها را برای سرور ایران وارد کنید.

---

## 🔧 نکات فنی مهم

- در روش‌های CDN، دامنه **باید** در ArvanCloud روی حالت **SSL Full (Strict)** تنظیم شده و پروکسی (ابر نارنجی) فعال باشد.
- رمزهای پیش‌فرض در فایل‌های JSON (`MyCDNpass`, `MyHDpass`, `MyRLpass`) را می‌توانید تغییر دهید، اما باید در دو طرف یکسان باشند.
- در روش VLESS Reverse، **UUID** و **کلیدهای Reality** باید بین ایران، پورتال و بک‌اند هماهنگ باشند.
- تمام سرویس‌ها پس از نصب توسط **systemd** مدیریت می‌شوند و با ری‌استارت سرور فعال باقی می‌مانند.

---

## 📚 مستندات تکمیلی (در صورت نیاز)

در این مخزن پوشه‌های زیر نیز برای مطالعهٔ بیشتر وجود دارند:

<div align="center">
  <a href="docs/METHOD1_RATHOLE.md">
    <img src="https://img.shields.io/badge/روش_۱-Rathole_+_WaterWall-blue?style=for-the-badge" alt="method1" />
  </a>
  <a href="docs/METHOD2_CDN.md">
    <img src="https://img.shields.io/badge/روش_۲-CDN_ساده-orange?style=for-the-badge" alt="method2" />
  </a>
  <a href="docs/METHOD3_MULTILAYER.md">
    <img src="https://img.shields.io/badge/روش_۳-چندلایه-red?style=for-the-badge" alt="method3" />
  </a>
  <a href="docs/METHOD4_VLESS_REVERSE.md">
    <img src="https://img.shields.io/badge/روش_۴-VLESS_Reverse-purple?style=for-the-badge" alt="method4" />
  </a>
  <a href="docs/FAQ.md">
    <img src="https://img.shields.io/badge/❓_FAQ-green?style=for-the-badge" alt="faq" />
  </a>
</div>

---

## 🤝 مشارکت و حمایت

<div align="center">
  <a href="https://github.com/skyteamtrading/L2-Tunnel-Installer/issues">
    <img src="https://img.shields.io/badge/گزارش_باگ_یا_پیشنهاد-اینجا-red?style=for-the-badge&logo=github" alt="issues" />
  </a>
  &nbsp;&nbsp;
  <a href="CONTRIBUTING.md">
    <img src="https://img.shields.io/badge/راهنمای_مشارکت-مشاهده-blue?style=for-the-badge&logo=handshake" alt="contributing" />
  </a>
</div>

<br>

<div align="center">
  <p>⭐ اگر این پروژه برایتان مفید بود، لطفاً ستاره بدهید!</p>
  <img src="https://img.shields.io/github/stars/skyteamtrading/L2-Tunnel-Installer?style=social" alt="stars" />
</div>

---

<div align="center">
  <sub>ساخته‌شده با ❤️ برای عبور امن و آزاد | مجوز MIT</sub>
</div>
SKYTEAM2026
