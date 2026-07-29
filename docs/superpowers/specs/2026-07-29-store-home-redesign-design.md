# 스토어 홈 화면 리디자인 — 설계 문서

> 작성일: 2026-07-29
> 대상: `StoreScreen` (`/spare/home/store`) 및 연관 신규 화면
> 관련 문서: `docs/STORE_SCREEN_OHOUSE_REFERENCE.md` (2026-07-26, 오늘의집 UX 벤치마크 원자료)

## 1. 배경 · 목적

스토어 마켓플레이스 기능(Phase 1~7)은 셀러 가입·상품 옵션·장바구니 그룹핑·쿠폰·찜 폴더·번들 할인까지 전부 mock 데이터로 구현·배포되어 있다. 그러나 스토어 홈 화면(`StoreScreen`) 자체는 검색바 → 배너 → 카테고리 → 정렬칩 → 2열 그리드로만 구성되어, 다른 Phase에서 만든 기능(셀러, 쿠폰, 찜)들이 홈에서 전혀 드러나지 않는다. 사용자 피드백: "구성도 단순하고 레이아웃도 단순해서 전문가가 만든 느낌이 아니다."

목표는 오늘의집 수준으로 무겁게 만드는 게 아니라, **멀티 셀러 마켓플레이스라는 정체성을 홈 화면에서 실제로 느낄 수 있게** 만드는 것. 즉 "판매자(스토어)"라는 개념을 카테고리·상품보다 먼저 보여주는 구성(브레인스토밍 중 시각적으로 비교한 A/B/C 3안 중 C안 "마켓플레이스 중심"을 채택).

## 2. 범위

**포함**: 스토어 홈 화면 섹션 재구성, 신규 "인기 스토어" 섹션과 팔로우 기능, 신규 바로가기 숏컷 섹션(6칸), 카테고리 아이콘 스타일 교체, 신규 화면 3개(전체 스토어 목록/쿠폰함/최근 본 상품).

**제외**: 상품 상세 화면, 장바구니·결제 플로우, 상품 카드(`StoreProductCard`) 자체 디자인 — 이미 뱃지·별점·할인 표시가 있어 이번 범위에서 다루지 않음. 백엔드 API 연동 — [[backend-railway-down-ncp-migration]] 방침에 따라 전부 mock 기반으로 진행하고, NCP 이전 후 별도로 연동.

## 3. 화면 구조 (StoreScreen)

위에서 아래 순서:

1. AppBar — 기존 유지 (찜·장바구니 배지)
2. 검색바 — 기존 유지
3. 배너 캐러셀 (`StorePromoBannerCarousel`) — 기존 유지
4. **[신규] 인기 스토어 섹션** — 가로 스크롤, `StoreSellerCard`(통계형) 4~6개, 섹션 헤더에 "더보기 ›" → `StoreAllSellersScreen`
5. 카테고리 아이콘 로우 (`StoreCategoryRow`) — 아이콘을 소프트 배지 스타일(연한 berry 배경 + 이모지/아이콘, radius 14)로 교체. 기존 원형 placeholder 대체.
6. **[신규] 바로가기 숏컷** (`StoreFeatureShortcuts`) — 반응형 grid(한 행에 들어가는 만큼, 강제로 5×2=10칸 채우지 않음): 장바구니 · 찜한 상품 · 주문내역 · 전체 스토어 · 쿠폰함 · 최근 본 상품 (6개)
7. 정렬 필터칩 — 기존 유지 (전체/프로추천/MD픽/특가/신상)
8. **[신규] 지금 뜨는 스토어의 상품** — 인기 스토어로 선정된 셀러들의 베스트셀러 상품을 모아 가로 스크롤. 섹션 헤더에 "더보기 ›" 불필요(전체 상품 그리드로 자연 연결).
9. 살롱 베스트 — 기존 유지
10. 전체 상품 그리드 — 기존 유지

기존 `_SectionHeader` 위젯에 선택적 `trailing`(예: "더보기 ›" + onTap) 파라미터를 추가해 4번·8번·9번 섹션에서 재사용한다.

## 4. 데이터 모델 · 로직

### 4.1 인기 스토어 선정 기준

`StoreSeller` 자체에 상품수·평균별점 필드를 저장하지 않는다 — 대신 `StoreService.getProducts()` 결과를 `sellerId`로 그룹핑해 계산하는 `getSellerSummaries()` 메서드를 `StoreSellerService`에 추가한다.

```
StoreSellerSummary {
  seller: StoreSeller
  productCount: int       // sellerId로 필터링한 상품 수
  averageRating: double   // 상품들의 리뷰 평균
  followerCount: int      // StoreSellerFollowProvider에서 조회
}
```

"인기" 정렬 기준(mock 단계): `averageRating` 내림차순, 동률이면 `productCount` 내림차순. 상위 4~6개 노출. `status == approved`인 셀러만 대상.

### 4.2 팔로우 기능 (신규)

- `StoreSellerFollowProvider extends ChangeNotifier` — `Set<String> followedSellerIds`를 메모리(추후 `SharedPreferences`로 영속화 검토)에 보관.
- API: `bool isFollowing(String sellerId)`, `void toggle(String sellerId)`, `int followerCount(String sellerId)` (mock 기준값 + 로컬 토글 반영).
- `ServiceLocator`(`sl`)에 `ChangeNotifierProvider`로 등록, 기존 `StoreWishlistProvider`·`CartProvider`와 동일한 패턴.

### 4.3 최근 본 상품 (신규)

- `RecentlyViewedStoreProvider extends ChangeNotifier` — 상품 상세 화면(`StoreProductDetailScreen`) 진입 시 `productId`를 최근순으로 기록 (최대 20개, LRU).
- 저장은 메모리만으로 충분 (mock 단계). 앱 재시작 시 초기화되는 건 이번 범위에서 허용.

## 5. 신규 컴포넌트/화면 매핑

| 항목 | 종류 | 파일 |
|------|------|------|
| 인기 스토어 카드 | 신규 위젯 | `lib/widgets/store/store_seller_card.dart` |
| 바로가기 숏컷 그리드 | 신규 위젯 | `lib/widgets/store/store_feature_shortcuts.dart` |
| 섹션 헤더(더보기 지원) | 기존 확장 | `store_screen.dart` 내 `_SectionHeader` → `trailing` 파라미터 추가 |
| 팔로우 상태 관리 | 신규 Provider | `lib/providers/store_seller_follow_provider.dart` |
| 최근 본 상품 상태 관리 | 신규 Provider | `lib/providers/recently_viewed_store_provider.dart` |
| 셀러 랭킹/집계 | 기존 서비스 확장 | `lib/services/store_seller_service.dart`에 `getSellerSummaries()` 추가 |
| 전체 스토어 목록 | 신규 화면 | `lib/screens/spare/store_all_sellers_screen.dart` |
| 쿠폰함 | 신규 화면 | `lib/screens/spare/store_coupon_box_screen.dart` (기존 `StoreCouponProvider` 사용) |
| 최근 본 상품 | 신규 화면 | `lib/screens/spare/store_recently_viewed_screen.dart` |
| 라우트 | 확장 | `app_routes.dart`에 `spareHomeStoreAllSellers`, `spareHomeStoreCouponBox`, `spareHomeStoreRecentlyViewed` 추가 |

## 6. 카테고리·숏컷 아이콘 스타일

브레인스토밍에서 3안(라인 아이콘/채워진 컬러 원/소프트 배지) 중 **소프트 배지**로 결정:

- `width/height: 44`, `borderRadius: 14`
- 배경: `HairSpareColors.brandPrimary`의 10~15% 알파 (예: `brandPrimary.withValues(alpha: 0.12)`)
- 아이콘: 기존 컬러 유지(현재 이모지 또는 `Icons.*` 아이콘 사용 중인 방식 그대로, 배경만 교체)
- `StoreCategoryRow`와 `StoreFeatureShortcuts` 양쪽에 동일 스타일 적용해 톤 통일

## 7. 에러 처리 · 빈 상태

- 인기 스토어 섹션: 승인된 셀러가 0명이면 섹션 자체를 숨김 (현재 6개 승인 셀러가 있어 실질적으로 발생하지 않지만 방어적으로 처리).
- 지금 뜨는 스토어의 상품: 대상 셀러의 베스트셀러가 없으면 해당 셀러는 후보에서 제외.
- 신규 화면(전체 스토어/쿠폰함/최근 본 상품) 모두 기존 `_EmptyState`/`_ErrorState` 패턴 재사용.

## 8. 테스트 관점

- `dart analyze` 0 error 유지
- 위젯 테스트: `StoreSellerCard` 팔로우 토글 시 버튼 라벨·팔로워수 갱신, `StoreFeatureShortcuts` 각 타일 탭 시 올바른 라우트로 이동
- 수동 QA: 에뮬레이터에서 인기 스토어 → 전체 스토어 목록 → 팔로우 토글 → 홈으로 돌아왔을 때 상태 유지 확인, 최근 본 상품이 상세 진입 순서대로 쌓이는지 확인

## 9. 단계 (구현 순서 제안)

1. 데이터/상태 레이어: `StoreSellerFollowProvider`, `RecentlyViewedStoreProvider`, `StoreSellerService.getSellerSummaries()`
2. 위젯: `store_seller_card.dart`, `store_feature_shortcuts.dart`, `_SectionHeader` trailing 확장
3. 홈 화면(`store_screen.dart`) 섹션 재배치 및 카테고리 아이콘 스타일 교체
4. 신규 화면 3개 + 라우트 등록
5. 수동 QA (에뮬레이터)

세부 태스크 분해는 이어서 `writing-plans` 스킬로 구현 계획을 작성한다.
