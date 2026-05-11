#!/bin/bash
set -euo pipefail

# Create necessary directories
mkdir -p .github/workflows docs examples/method1_rathole/{iran,kharej} examples/method2_cdn_simple/{iran,kharej} examples/method3_multilayer/{iran,kharej} examples/method4_vless_reverse/{iran,portal,backend}

echo "Creating .gitignore..."
cat > .gitignore << 'EOF'
*.log
tmp/
.env
.DS_Store
*.swp
EOF

echo "Creating CONTRIBUTING.md..."
cat > CONTRIBUTING.md << 'EOF'
# راهنمای مشارکت

از مشارکت شما سپاسگزاریم!  
پیشنهادات و گزارش باگ‌ها را ابتدا در قسمت **Issues** مطرح کنید.

- کدهای Bash باید با `shellcheck` بدون خطا باشند.
- مستندات به زبان فارسی نوشته شوند.
- تغییرات بزرگ را ابتدا در Issue بحث کنید.
EOF

echo "Creating LICENSE (MIT)..."
cat > LICENSE << 'EOF'
MIT License

Copyright (c) 2025 skyteamtrading

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF

echo "Creating documentation files..."
cat > docs/METHOD1_RATHOLE.md << 'EOF'
# روش ۱: Rathole + WaterWall (TAP)

## معماری
ایران: TAP <-> WaterWall Client <-> Rathole Client <-- اینترنت --> Rathole Server <-> WaterWall Server <-> TAP (خارج)

## پیش‌نیازها
- IP سرور خارج **تمیز** باشد.
- پورت ۴۴۳ روی سرور خارج باز باشد.

## مراحل نصب
1. اسکریپت را روی هر دو سرور اجرا کنید.
2. روش ۱ را انتخاب کرده و نقش (ایران/خارج) را مشخص کنید.
3. در سمت ایران، IP خارج را وارد کنید.

## تست
از ایران `ping 10.0.0.2` را اجرا کنید.
EOF

cat > docs/METHOD2_CDN.md << 'EOF'
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
EOF

cat > docs/METHOD3_MULTILAYER.md << 'EOF'
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
EOF

cat > docs/METHOD4_VLESS_REVERSE.md << 'EOF'
# روش ۴: VLESS Reverse + WaterWall

## معماری
ایران: TAP -> WaterWall Client -> Xray Client (VLESS+Reality) -> Portal (Xray - IP تمیز) -> Backend (Xray) -> WaterWall Server -> TAP (خارج)

## پیش‌نیازها
- یک **سرور پورتال** با IP تمیز و پورت ۴۴۳ باز.
- یک **سرور بک‌اند** با IP کثیف (پورت ۸۴۴۳ برای پورتال باز باشد).

## مراحل نصب
1. روی پورتال اسکریپت را با نقش Portal اجرا کنید. کلیدهای Reality را یادداشت کنید.
2. روی بک‌اند با نقش Backend اجرا کنید.
3. روی ایران با نقش Iran اجرا کنید و اطلاعات پورتال را وارد کنید.

## تست
از ایران `ping 10.0.0.2` را اجرا کنید.
EOF

cat > docs/FAQ.md << 'EOF'
# پرسش‌های متداول

### کدام روش را انتخاب کنم؟
- IP تمیز → روش ۱.
- IP کثیف و هزینه کم → روش ۲.
- امنیت حداکثری → روش ۳.
- کنترل کامل → روش ۴.

### چرا MTU روی ۱۲۰۰ تنظیم می‌شود؟
برای جلوگیری از تکه‌تکه شدن بسته‌ها در لایه‌های متعدد.

### آیا می‌توانم از دامنه رایگان استفاده کنم؟
بله، ولی دامنه واقعی پایدارتر است.
EOF

echo "Creating GitHub Actions workflow..."
cat > .github/workflows/shellcheck.yml << 'EOF'
name: ShellCheck

on: [push, pull_request]

jobs:
  shellcheck:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run ShellCheck
        uses: ludeeus/action-shellcheck@2.0.0
        with:
          scandir: './'
          format: tty
EOF

# مثال‌های خالی برای روش‌ها
touch examples/method1_rathole/iran/rathole_client.toml
touch examples/method1_rathole/iran/waterwall_client.json
touch examples/method1_rathole/kharej/rathole_server.toml
touch examples/method1_rathole/kharej/waterwall_server.json
touch examples/method2_cdn_simple/iran/waterwall_client.json
touch examples/method2_cdn_simple/kharej/waterwall_server.json
touch examples/method3_multilayer/iran/layer1_hd.json
touch examples/method3_multilayer/iran/layer2_reality.json
touch examples/method3_multilayer/iran/layer3_cdn.json
touch examples/method3_multilayer/kharej/layer1_hd.json
touch examples/method3_multilayer/kharej/layer2_reality.json
touch examples/method3_multilayer/kharej/layer3_cdn.json
touch examples/method4_vless_reverse/iran/waterwall_client.json
touch examples/method4_vless_reverse/portal/xray_config.json
touch examples/method4_vless_reverse/backend/xray_config.json
touch examples/method4_vless_reverse/backend/waterwall_server.json

echo "All files created successfully!"