# 스페어 홈 vs 샵 홈 — 비교 및 샵 홈 디자인 방향

HairSpare 앱에서 **스페어·디자이너(구직)** 홈과 **미용실·샵(구인·운영)** 홈의 차이, 현재 구현 상태, 샵 홈 개선 시 추가하면 좋은 요소를 정리한 문서입니다.  
디자인 리뷰·기획 공유·개발 핸드오프용으로 사용합니다.

---

## 1. 한 줄 요약

| | 스페어 홈 | 샵 홈 |
|---|-----------|--------|
| **사용자** | 구직 디자이너·스페어 | 미용실 운영자·점장 |
| **핵심 질문** | “오늘 어떤 공고에 지원할까?” | “공고·지원·스케줄을 어떻게 관리할까?” |
| **홈 콘텐츠** | **공고 피드** (급구·카테고리·인기·신규 등) | **운영 KPI** + **인력(지원자) 추천** |
| **CTA 성격** | 탐색·지원·찜 | 등록·승인·스케줄 확인 |

같은 8칸 퀵 메뉴·히어로 배너·상단 App Bar 골격은 **공유**하지만, 스크롤 하단의 **메인 콘텐츠 철학**이 다릅니다.

---

## 2. 레이아웃 비교 (와이어)

### 스페어 홈 (`SpareHomeScrollView`)

```
┌─────────────────────────────┐
│ [Logo]          🔍 💬 🔔   │  ← pinned top bar (AppScreenInsets)
├─────────────────────────────┤
│   Stitch Hero Banner        │  ← spare variant, CTA→급구/에너지/교육
├─────────────────────────────┤
│  8칸 퀵메뉴 (CategoryGrid)  │  공고별·스케줄·스토어·포인트…
├─────────────────────────────┤
│  급구 공고                  │
│  카테고리별 공고            │
│  인기 공고                  │
│  신규 공고                  │
│  오픈 예정 샵               │
│  일반 공고                  │
│  고객센터                   │
└─────────────────────────────┘
```

### 샵 홈 (`ShopHomeScrollView`) — 현재 + 스크린샷 기준

```
┌─────────────────────────────┐
│ [Logo]          🔍 💬 🔔   │  ← SliverToBoxAdapter 고정 헤더
├─────────────────────────────┤
│   Stitch Hero Banner        │  ← shop variant, CTA→내공고/인력별/스케줄
├─────────────────────────────┤
│  8칸 퀵메뉴 (색상 아이콘)   │  인력별·스케줄·스토어·포인트…
├─────────────────────────────┤
│ ┌─────┐ ┌─────┐ ┌─────┐    │
│ │  2  │ │  2  │ │  1  │    │  ← KPI 3종 (그라데이션 카드)
│ │활성 │ │대기 │ │오늘 │    │
│ │공고 │ │지원 │ │모델 │    │
│ └─────┘ └─────┘ └─────┘    │
├─────────────────────────────┤
│  인기 지원자 [HOT]  더보기  │  ← 가로 캐러셀
├─────────────────────────────┤
│  신규 지원자          더보기 │  ← 리스트/캐러셀
├─────────────────────────────┤
│  고객센터                   │
└─────────────────────────────┘
```

---

## 3. 섹션별 상세 비교

| 섹션 | 스페어 홈 | 샵 홈 | 비고 |
|------|-----------|--------|------|
| **App Bar** | `SpareHomeAppBarRow` + `pinnedTopBarSliver` | `ShopHomeAppBarRow` + 수동 Container | 기능 동일(로고·검색·채팅·알림). 샵은 safe-area 패턴 통일 여지 |
| **히어로 배너** | `StitchHeroVariant.spare` | `StitchHeroVariant.shop` | 이미지 세트·탭 CTA 다름 |
| **퀵 메뉴 8칸** | `SpareHomeQuickMenu` | `ShopHomeQuickMenu` | 라벨 거의 대칭. 샵은 아이콘 **컬러 per item** |
| **퀵메뉴 1번** | 공고별 | **인력별** | 역할 반전 |
| **퀵메뉴 8번** | 모odel매칭 → 연결됨 | 모델매칭 → **준비 중 토스트** | 샵 미완 |
| **메인 피드** | 공고 6섹션 (`SpareHomeJobSections`) | KPI + 지원자 2섹션 | **가장 큰 차이** |
| **KPI 대시보드** | 없음 | 활성 공고 / 대기 지원자 / 오늘 모델매칭 | **샵 전용 강점** |
| **찜(즐겨찾기)** | 공고 찜 토글 | 홈에서 미사용 | 샵은 인력 찜은 별도 화면 |
| **폴링** | 10초 알림·채팅 갱신 | 없음 | 샵도 지원자/알림 갱신 고려 |
| **로딩 UX** | JobProvider 로딩 시 섹션만 스피너 | 전 화면 스피너 | 샵은 skeleton 권장 |
| **고객센터** | `CustomerServiceSection` | 동일 | 공통 |

---

## 4. 퀵 메뉴 매핑 (8칸)

| # | 스페어 | 샵 | 목적 차이 |
|---|--------|-----|-----------|
| 1 | 공고별 | **인력별** | 구직 vs 구인 |
| 2 | 스케줄표 | 스케줄표 | 스페어=근무·출근 / 샵=매칭·근무 일정 |
| 3 | 스토어 | 스토어 | 둘 다 준비 중 |
| 4 | +포인트 | +포인트 | 동일 |
| 5 | 공간대여 | 공간대여 | 스페어=지역선택 / 샵=spaces |
| 6 | 교육 | 교육 | 동일 |
| 7 | 챌린지참여 | 챌린지참여 | 동일 |
| 8 | 모델매칭 | 모델매칭 | 스페어 연결됨 / **샵 stub** |

---

## 5. 데이터·상태 (ViewModel)

### `SpareHomeViewModel`

- `JobProvider.loadJobs()` — 홈 전체가 공고 데이터 의존
- `FavoriteProvider`, `NotificationProvider`, `ChatProvider` 병렬 로드
- 홈 탭 활성 시 **10초 폴링** (알림·채팅)

### `ShopHomeViewModel`

- `getMyJobs()` → **활성 공고 수**
- `getShopApplications()` → **대기 지원자 수**
- `getTodayModelMatchingCount()` → **오늘 모델매칭**
- `getSpares(popular/newest)` → 홈 인력 섹션
- 공고 **피드는 홈에 두지 않음** (주석: `ShopJobsListScreen` 등에서 관리)

→ 샵 홈은 **운영 지표 + 인력 마켓플레이스**에 최적화된 데이터 모델.

---

## 6. 현재 샵 홈 디자인 설명 (우리 구현)

스크린샷과 코드 기준으로, 현재 샵 홈은 아래 톤을 따릅니다.

### 6.1 비주얼

- **배경**: `AppTheme.backgroundGray` + KPI·신규 지원자 구간은 **흰 카드/흰 띠** 교차
- **브랜드**: HairSpare 로고 + Purple `#9333EA` (Stitch / `DESIGN_GUIDE_SHOP_PAGES.md` 정합)
- **KPI 카드**: 3열 그라데이션
  - 활성 공고: Purple → Pink
  - 대기 지원자: Blue → Cyan
  - 오늘 모델매칭: Green
- **섹션 헤더**: 16px Bold + **HOT** 그라데이션 pill (인기 지원자)
- **카드**: `ShopHomeSpareFeatureCard` — 프로필 사진·경력·전문분야·가로 스크롤

### 6.2 인터랙션

| 요소 | 탭 시 이동 |
|------|------------|
| KPI · 활성 공고 | `shopProfileJobs` (내 공고) |
| KPI · 대기 지원자 | `shopProfileApplicants` |
| KPI · 오늘 모델매칭 | `shopHomeSchedule` |
| 인기/신규 지원자 · 더보기 | `shopHomeSpares` |
| 지원자 카드 | `shopHomeSpareDetail` |
| 배너 슬라이드 0/1/2 | 내 공고 / 인력별 / 스케줄 |

### 6.3 스페어 홈과의 **의도적** 차이

- 샵 홈에 **급구·일반 공고 리스트를 넣지 않음** → 운영자는 “내가 올린 공고”는 프로필·KPI로, “남의 공고”는 볼 필요 없음
- 대신 **지원자(스페어) 카드**로 인력 확보 UX 제공
- KPI strip으로 **한눈에 운영 상태** 전달 (스크린샷의 2·2·1)

---

## 7. 샵 홈에 추가하면 좋은 것 (제안)

스페어 홈 수준의 완성도·샵 업무 흐름을 기준으로 우선순위를 나눴습니다.

### P0 — Must (운영 필수)

| 제안 | 이유 | 스페어 대응 참고 |
|------|------|------------------|
| **인증·온보딩 배너** | 가입 직후 사업자/본인/대리인 미완료 시 홈 상단 고정 | 스페어 success → 본인인증 CTA와 동일 논리 |
| **대기 지원자 미리보기** | KPI 숫자만으로는 부족 — **이름·공고·시간** 1~3건 카드 | 스페어 `UrgentJobSection` 급구 strip |
| **모델매칭 퀵메뉴 연결** | 현재 stub — 스케줄/전용 화면 연결 | 스페어 `spareHomeModelMatch` |
| **App Bar pinned 패턴 통일** | `AppScreenInsets.pinnedTopBarSliver` 로 스페어와 동일 | safe-area 규칙 일관 |

### P1 — Should (경험 향상)

| 제안 | 이유 |
|------|------|
| **마감 임박 / 지원 0건 공고 strip** | “활성 2” 중 **액션이 필요한 공고** 강조 (`ShopHomeOperationCard` 재사용) |
| **매칭 팁 배너** | `ShopHomeTipsBanner` 이미 구현됨 — KPI 아래 삽입 |
| **10초 폴링** | 대기 지원자·알림·채팅 badge 갱신 (`SpareHomeViewModel` 패턴) |
| **Skeleton 로딩** | 전체 화면 스피너 대신 배너·KPI·캐러셀 placeholder |
| **빈 상태 UX** | 지원자 0명·공고 0건일 때 “첫 공고 등록” CTA |

### P2 — Nice (차별화)

| 제안 | 이유 |
|------|------|
| **오늘 스케줄 한 줄** | KPI 3번과 연동 — “14:00 모델 OOO” |
| **에너지/포인트 잔액 chip** | App Bar 또는 KPI 옆 미니 표시 |
| **인력 찜/최근 본** | 스페어 찜과 대칭 — `FavoriteProvider` shop scope |
| **공간대여·교육 추천 1줄** | 샵-only 수익/운영 콘텐츠 |
| **ShopHomeStatusStrip 통합** | `shop_home_scroll_view` 인라인 KPI vs 별도 위젯 중복 정리 |

---

## 8. 샵 홈 리디자인 원칙 (제안)

1. **스페어 홈을 그대로 복제하지 않는다**  
   공고 6섹션을 샵에 넣으면 운영자 UX와 맞지 않음.

2. **KPI + Action 구조를 유지·강화한다**  
   숫자 → 탭 → 해당 관리 화면. 숫자 아래 **미리보기 1줄** 추가.

3. **인력 마켓은 “지원자” 관점으로 카피 통일**  
   “인기 지원자” / “신규 지원자” (현재) 유지. 필요 시 “추천 인력” vs “최근 지원”으로 세분.

4. **스페어와 공통 shell 유지**  
   Hero · 8-grid · App Bar · CustomerService · bottom nav(홈·결제·찜·마이) — **학습 비용 최소화**.

5. **미연결·미사용 코드 정리**  
   - `ShopHomeQuickMenu.openModelMatching` → 실제 라우트  
   - `ShopHomeTipsBanner`, `ShopHomeOperationCard`, `ShopHomeStatusStrip` → scroll_view에 wire-up 또는 삭제

---

## 9. 제안 레이아웃 (개선 후)

```
┌─────────────────────────────┐
│ App Bar (pinned, 공통)      │
├─────────────────────────────┤
│ [인증 미완료] 배너 (조건부)  │  ← P0
├─────────────────────────────┤
│ Hero Banner (shop)          │
├─────────────────────────────┤
│ 8칸 퀵메뉴                  │
├─────────────────────────────┤
│ KPI 3종 (현행 유지)         │
├─────────────────────────────┤
│ ⚠ 대기 지원자 2명 (cards)   │  ← P0, KPI와 연동
├─────────────────────────────┤
│ 📋 마감임박 내 공고 (strip)  │  ← P1
├─────────────────────────────┤
│ 💡 매칭 팁 배너             │  ← P1 (기존 위젯)
├─────────────────────────────┤
│ 인기 지원자 [HOT]           │
│ 신규 지원자                 │
├─────────────────────────────┤
│ 고객센터                    │
└─────────────────────────────┘
```

---

## 10. 관련 파일 맵

| 구분 | 스페어 | 샵 |
|------|--------|-----|
| Screen | `lib/screens/spare/home_screen.dart` | `lib/screens/shop/home_screen.dart` |
| Scroll | `lib/widgets/spare_home/spare_home_scroll_view.dart` | `lib/widgets/shop_home/shop_home_scroll_view.dart` |
| Quick menu | `lib/widgets/spare_home/spare_home_quick_menu.dart` | `lib/widgets/shop_home/shop_home_quick_menu.dart` |
| App bar | `lib/widgets/spare_home/spare_home_app_bar.dart` | `lib/widgets/shop_home/shop_home_app_bar.dart` |
| Main content | `lib/widgets/spare_home/spare_home_job_sections.dart` | `lib/widgets/shop_home/shop_home_spare_sections.dart` |
| ViewModel | `lib/view_models/spare_home_view_model.dart` | `lib/view_models/shop_home_view_model.dart` |
| Hero | `lib/widgets/stitch/stitch_hero_banner.dart` | 동일 (`variant: shop`) |
| 미사용(샵) | — | `shop_home_status_strip.dart`, `shop_home_tips_banner.dart`, `shop_home_operation_card.dart` |
| 디자인 가이드 | — | `docs/DESIGN_GUIDE_SHOP_PAGES.md` |

---

## 11. 다음 단계 (개발 핸드오ff)

1. 기획·디자인 리뷰: **섹션 7 P0** 합의  
2. Figma/목업: 인증 배너 + 대기 지원자 strip + KPI visual polish  
3. 구현: `shop_home_scroll_view.dart` 섹션 reorder + 미사용 위젯 연결  
4. QA: 가입 직후(미인증) / 공고·지원 0건 / 데이터 많음 케이스  

---

*작성 기준: `lib/widgets/spare_home/*`, `lib/widgets/shop_home/*`, ViewModel, 스크린샷(샵 홈 KPI·인기 지원자).*
