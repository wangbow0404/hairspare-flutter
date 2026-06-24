#!/usr/bin/env bash
# hot reload critical path — Image.network / NetworkImage 재도입 방지.
set -euo pipefail
cd "$(dirname "$0")/.."

HOT_PATHS=(
  lib/widgets/common/job_thumbnail.dart
  lib/widgets/new_jobs_section.dart
  lib/widgets/popular_jobs_section.dart
  lib/widgets/spare_home
  lib/widgets/shop_home
  lib/widgets/model_home/model_home_profile_card.dart
  lib/screens/spare/home_screen.dart
  lib/screens/spare/model_match_swipe_screen.dart
  lib/screens/spare/model_matching_status_screen.dart
)

failed=0

check_raw_network_images() {
  local path=$1
  if rg '\bImage\.network\s*\(' "$path" --glob '*.dart' -q 2>/dev/null; then
    echo "FAIL: Image.network in hot path: $path"
    rg '\bImage\.network\s*\(' "$path" --glob '*.dart' -n || true
    failed=1
  fi
  local hits
  hits=$(rg '\bNetworkImage\s*\(' "$path" --glob '*.dart' -n 2>/dev/null \
    | grep -v 'AppNetworkImage' || true)
  if [ -n "$hits" ]; then
    echo "FAIL: NetworkImage (not AppNetworkImage) in hot path: $path"
    echo "$hits"
    failed=1
  fi
}

for path in "${HOT_PATHS[@]}"; do
  if [ ! -e "$path" ]; then
    echo "WARN: missing path $path"
    continue
  fi
  check_raw_network_images "$path"
done

if rg 'picsum\.photos' lib/mocks --glob '*.dart' -q 2>/dev/null; then
  echo 'FAIL: picsum.photos found in lib/mocks — use mock:// URLs.'
  rg 'picsum\.photos' lib/mocks --glob '*.dart' -n || true
  failed=1
fi

if [ "$failed" -eq 1 ]; then
  echo ''
  echo 'See docs/HOT_RELOAD_GUIDE.md'
  exit 1
fi

echo 'OK: hot reload critical paths clean.'
exit 0
