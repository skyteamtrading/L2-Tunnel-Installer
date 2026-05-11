کد کامل صفحهٔ گرافیکی README.md که طراحی کردیم را در زیر می‌توانید ببینید. این کد دقیقاً همان چیزی است که مخزن شما را به یک پنل حرفه‌ای و چشم‌نواز تبدیل می‌کند – کافی است آن را در فایل `README.md` مخزن جایگزین کنید.

```markdown
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
  <a href="docs/">
    <img src="https://img.shields.io/badge/📚_مستندات-مشاهده-ff8c00?style=for-the-badge&logo=readthedocs&logoColor=white" alt="docs" />
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

<br>

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
</div>

<br>

---

## ⚡ نصب سریع

<div align="center">
  <p><b>👇 همین یک خط را در ترمینال اجرا کنید (نیاز به دسترسی root)</b></p>
  
  ```bash
  bash <(curl -s https://raw.githubusercontent.com/skyteamtrading/L2-Tunnel-Installer/main/l2tunnel.sh)
  ```
</div>

<br>

---

## 🧠 انتخاب روش مناسب

| روش | IP خارج | امنیت | پیچیدگی | دکمهٔ انتخاب |
|------|----------|-------|----------|--------------|
| **۱. Rathole + WaterWall** | 🟢 تمیز | ⭐⭐ | 🟢 آسان | `۱` |
| **۲. CDN (آروان) + WaterWall** | 🔴 کثیف | ⭐⭐⭐ | 🟢 بسیار آسان | `۲` |
| **۳. CDN + HalfDuplex + RealityTls** | 🔴 کثیف | ⭐⭐⭐⭐ | 🟡 متوسط | `۳` |
| **۴. VLESS Reverse + WaterWall** | 🟢 پورتال تمیز | ⭐⭐⭐⭐⭐ | 🔴 پیشرفته | `۴` |

> 📖 توضیحات کامل هر روش در [پوشهٔ `docs`](docs/) موجود است.

<br>

---

## 🧪 تست موفقیت‌آمیز بودن تونل

<div align="center">

```diff
+ پس از نصب، از سرور ایران پینگ بگیرید:
  ping 10.0.0.2
+ اگر پاسخ گرفتید، تونل لایهٔ ۲ شما برقرار است! 🎉
```

</div>

<br>

---

## 🎮 معماری‌ها (تصویری)

```
روش ۱: Rathole
ایران: TAP <-> WW Client <-> Rathole Client ← اینترنت → Rathole Server <-> WW Server <-> TAP (خارج)

روش ۲: CDN ساده
ایران: TAP <-> WW Client (WSS) ← ArvanCloud → WW Server (WSS) <-> TAP (خارج)

روش ۳: چندلایه
ایران: TAP → HalfDuplex → RealityTls → CDN Client → ArvanCloud → CDN Server → RealityTls → HalfDuplex → TAP (خارج)

روش ۴: VLESS Reverse
ایران: TAP → WW Client → Xray (VLESS+Reality) → Portal (Xray) → Backend (Xray) → WW Server → TAP (خارج)
```

<br>

---

## 📚 مستندات تکمیلی

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

<br>

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

<br>

---

<div align="center">
  <sub>ساخته‌شده با ❤️ برای عبور امن و آزاد | مجوز MIT</sub>
</div>
```

---

کافی است این کد را عیناً در فایل `README.md` مخزن خود جای دهید. اگر دوست دارید رنگ‌ها، متن‌ها یا آیکون‌ها را کمی تغییر دهید، به من بگویید – می‌توانیم حتی یک **صفحهٔ فرود کامل با GitHub Pages** هم برایش طراحی کنیم.
