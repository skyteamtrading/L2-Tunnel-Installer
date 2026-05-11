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
