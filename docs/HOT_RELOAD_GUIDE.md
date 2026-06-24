# Hot Reload 가이드

## 로그인 직후 렉

**원인:** `StatefulShellRoute.indexedStack`가 결제·찜·프로필 탭까지 동시 마운트 → API·VM 4중 호출.

**해결:** [`LazyShellTab`](../lib/core/shell/lazy_shell_tab.dart) — 홈(tab 0)만 즉시 빌드, 나머지 탭은 탭 선택 시 첫 마운트.

---

| 항목 | 수정 전 (스페어 홈) | 목표 |
|------|---------------------|------|
| hot reload (`r`) | ~1s+, stuck 체감 | **<500ms**, stuck 없음 |
| reload 중 picsum 요청 | 10~30+ | **0** (mock mode) |
| shop 홈 `r` | 빠름 (baseline) | 유지 |

**근본 원인 (해결됨):**

1. `JobThumbnail` → `Image.network` + mock picsum URL → reload마다 대량 fetch/decode
2. `NewJobsSection` / `PopularJobsSection` → 16ms auto-scroll + reassemble 즉시 재시작
3. `SpareHomeScrollView` monolith → Consumer 9중첩, favoriteMap/sort 반복

---

## `r` vs `R`

| 키 | 용도 |
|----|------|
| **`r`** (hot reload) | UI 텍스트·색·padding 등 **작은** 변경 |
| **`R`** (hot restart) | Provider/VM 구조 변경, `initState` 로직, route/DI 변경 |

구조 변경 후에는 **`R` 1회** → 이후 `r`로 미세 조정.

---

## Dual device (iOS + Android)

- **터미널 1개 = 디바이스 1개** (`./scripts/run_ios.sh`, `./scripts/run_android.sh`)
- **동시에 `r` 금지** — compile 2배, stuck처럼 보임
- 한쪽 reload 끝난 뒤 다른 쪽 reload

---

## stuck 시 복구

1. `Performing hot reload...` 10초+ → `Ctrl+C`
2. `./scripts/run_ios.sh` 또는 `./scripts/run_android.sh` 재실행
3. **`R` 1회** 후 다시 `r`

---

## 이미지 규칙 (필수)

- 리스트/카드 썸네일 → **`AppNetworkImage`** (`lib/widgets/common/app_network_image.dart`)
- mock JSON → **`mock://`** URL (picsum 금지)
- `JobThumbnail`은 `AppNetworkImage` 사용 (직접 `Image.network` 금지)

로컬 검사:

```bash
./scripts/check_no_raw_network_images.sh
```

---

## Auto-scroll 섹션

**2026-06 ANR 대응:** `NewJobsSection` / `PopularJobsSection`의 `Timer.periodic` + `jumpTo()` 자동 스크롤은 **비활성화**됨. push 전환 중 IndexedStack 홈과 경합해 Android ANR을 유발했음.

- 수동 가로 스크롤·3배 무한 리스트는 유지
- 자동 스크롤 재도입 시: `jumpTo` 고주파 금지, `NavigationLock.isLocked` / `ModalRoute.isCurrent` 게이트, 단일 coordinator + `animateTo` 저주파만 허용
- [`AutoScrollReassembleMixin`](lib/utils/auto_scroll_reassemble.dart)은 재도입 시 참고용으로만 유지

---

## 검증 체크리스트

1. 스페어 홈 탭 → `r` 3회 — 터미널 ms 기록
2. DevTools Network — reload 중 **picsum 0건**
3. shop 홈 → `r` — baseline 유지
4. `./scripts/check_no_raw_network_images.sh` 통과
