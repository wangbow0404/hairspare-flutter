#!/usr/bin/env bash
# iPhone 시뮬레이터 — 터미널 1
set -euo pipefail
cd "$(dirname "$0")/.."

IOS_DEVICE="${IOS_DEVICE:-iPhone 17 Pro}"
MAX_WAIT_SEC="${MAX_WAIT_SEC:-90}"

find_ios_device_id() {
  flutter devices --machine 2>/dev/null \
    | python3 -c "
import json, sys
try:
    devices = json.load(sys.stdin)
except json.JSONDecodeError:
    sys.exit(0)
name = (sys.argv[1] if len(sys.argv) > 1 else '').lower()
for d in devices:
    platform = d.get('targetPlatform') or ''
    if not platform.startswith('ios'):
        continue
    device_name = (d.get('name') or '').lower()
    if name and name not in device_name:
        continue
    print(d['id'])
    break
" "$IOS_DEVICE" 2>/dev/null || true
}

DEVICE_ID="$(find_ios_device_id)"

if [ -z "$DEVICE_ID" ]; then
  echo "▶ iOS 시뮬레이터 시작 중..."
  open -a Simulator >/dev/null 2>&1 || true
  xcrun simctl boot "$IOS_DEVICE" >/dev/null 2>&1 || true
  ELAPSED=0
  while [ "$ELAPSED" -lt "$MAX_WAIT_SEC" ]; do
    DEVICE_ID="$(find_ios_device_id)"
    if [ -n "$DEVICE_ID" ]; then
      echo "✓ 시뮬레이터 준비됨: $DEVICE_ID"
      break
    fi
    sleep 3
    ELAPSED=$((ELAPSED + 3))
    echo "  ... Flutter 기기 등록 대기 (${ELAPSED}s / ${MAX_WAIT_SEC}s)"
  done
fi

if [ -z "$DEVICE_ID" ]; then
  echo "✗ iOS 시뮬레이터를 찾지 못했습니다."
  echo "  Xcode → Open Developer Tool → Simulator 를 실행하세요."
  exit 1
fi

echo "▶ flutter run -d $DEVICE_ID ($IOS_DEVICE)"
# dual device: iOS/Android 각각 별도 터미널. 동시 hot reload(r) 금지 — docs/HOT_RELOAD_GUIDE.md
exec flutter run -d "$DEVICE_ID" --no-track-widget-creation
