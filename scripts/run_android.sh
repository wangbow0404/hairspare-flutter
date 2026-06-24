#!/usr/bin/env bash
# Android 에뮬레이터 — 터미널 2
# 에뮬레이터가 꺼져 있으면 Pixel_8 AVD를 자동 실행합니다.
set -euo pipefail
cd "$(dirname "$0")/.."

ANDROID_EMULATOR="${ANDROID_EMULATOR:-Pixel_8}"
MAX_WAIT_SEC="${MAX_WAIT_SEC:-180}"

find_android_device_id() {
  flutter devices --machine 2>/dev/null \
    | python3 -c "
import json, sys
try:
    devices = json.load(sys.stdin)
except json.JSONDecodeError:
    sys.exit(0)
for d in devices:
    platform = d.get('targetPlatform') or ''
    if platform.startswith('android') and d.get('emulator'):
        print(d['id'])
        break
" 2>/dev/null || true
}

wait_for_android_boot() {
  if ! command -v adb >/dev/null 2>&1; then
    return 0
  fi
  adb wait-for-device >/dev/null 2>&1 || true
  local boot
  for _ in $(seq 1 60); do
    boot="$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')"
    if [ "$boot" = "1" ]; then
      return 0
    fi
    sleep 2
  done
}

DEVICE_ID="$(find_android_device_id)"

if [ -z "$DEVICE_ID" ]; then
  echo "▶ Android 에뮬레이터가 없습니다. ${ANDROID_EMULATOR} 실행 중..."
  flutter emulators --launch "$ANDROID_EMULATOR" >/dev/null 2>&1 &
  wait_for_android_boot
  ELAPSED=0
  while [ "$ELAPSED" -lt "$MAX_WAIT_SEC" ]; do
    DEVICE_ID="$(find_android_device_id)"
    if [ -n "$DEVICE_ID" ]; then
      echo "✓ 에뮬레이터 준비됨: $DEVICE_ID"
      break
    fi
    sleep 3
    ELAPSED=$((ELAPSED + 3))
    echo "  ... Flutter 기기 등록 대기 (${ELAPSED}s / ${MAX_WAIT_SEC}s)"
  done
fi

if [ -z "$DEVICE_ID" ]; then
  echo "✗ Android 기기를 찾지 못했습니다."
  echo "  에뮬레이터 화면이 켜졌는지 확인한 뒤:"
  echo "  flutter devices"
  echo "  flutter run -d emulator-5554"
  exit 1
fi

echo "▶ flutter run -d $DEVICE_ID"
# dual device: iOS/Android 각각 별도 터미널. 동시 hot reload(r) 금지 — docs/HOT_RELOAD_GUIDE.md
exec flutter run -d "$DEVICE_ID" --no-track-widget-creation
