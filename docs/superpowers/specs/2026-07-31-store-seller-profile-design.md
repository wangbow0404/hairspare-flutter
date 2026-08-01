# 스토어 셀러 프로필 페이지 — 설계 문서

> 작성일: 2026-07-31
> 대상: 신규 화면 `StoreSellerProfileScreen`
> 관련: `docs/superpowers/specs/2026-07-29-store-home-redesign-design.md` (스토어 홈 리디자인, 선행 작업)

## 1. 배경 · 목적

스토어 홈 리디자인(2026-07-29)에서 "인기 스토어" 섹션과 "전체 스토어" 목록을 추가했지만, 셀러 카드를 탭하면 단순히 `StoreScreen`이 그 셀러 상품만 필터링해서 보여주는 수준이었다. 사용자 피드백: 각 스토어마다 오늘의집 급의 진짜 "가게 페이지"(로고·소개글·통계·상품/리뷰 탭)가 있어야 한다.

## 2. 범위

**포함**: 신규 화면 `StoreSellerProfileScreen` 1개(상품/리뷰 탭 포함), `StoreSeller`에 소개글 필드 추가, 셀러 리뷰 집계 서비스 메서드, 인기 스토어 카드·전체 스토어 목록에서 이 화면으로의 네비게이션 연결.

**제외(이번 범위 아님)**: 기존 `StoreScreen`의 `sellerId` 필터 기능 및 관련 테스트 — 사용자 지시에 따라 **그대로 유지**하고 건드리지 않는다(코드에는 남지만 카드 탭 경로에서는 더 이상 쓰이지 않게 됨 — 의도된 상태). 큰 배너 이미지 — 로고+소개글로 대체. 리뷰 작성 기능 — 리뷰는 "모아 보여주기"만, 새로 쓰는 기능은 없음.

## 3. 화면 구조 (`StoreSellerProfileScreen`)

위에서 아래 순서:

1. AppBar — 뒤로가기, 찜·장바구니 아이콘 (기존 `StoreScreen`과 동일 패턴)
2. 프로필 헤더 — 원형 로고(`logoUrl` 있으면 이미지, 없으면 이니셜 아바타 — `StoreSellerCard`/`StoreAllSellersScreen`과 동일 스타일), 스토어명, 소개글(`StoreSeller.introText`, 신규 필드), 통계 텍스트("상품 N · ★평점 · 팔로워 M"), "+팔로우/팔로잉" 버튼(`StoreSellerFollowProvider` 재사용)
3. 검색바 — 이 스토어 상품 이름 기준 클라이언트 필터 (전역 검색 아님, 이 화면 로컬 상태)
4. `TabBar` — "상품" | "리뷰" 2개 탭
5. **상품 탭**: `StoreService.getProductsBySeller(sellerId)` 결과를 기존 2열 그리드 + `StoreProductCard`로 표시 (검색어 있으면 이름 매칭 필터링), 위시리스트 토글 포함
6. **리뷰 탭**: 이 셀러의 모든 상품 리뷰를 최신순으로 모아 리스트. 각 항목: 리뷰어명·별점·내용·날짜 + 어떤 상품에 대한 리뷰인지 작은 텍스트(상품명)로 표시

## 4. 데이터 모델

`lib/models/store_seller.dart`의 `StoreSeller`에 필드 추가:
```dart
final String? introText;
```
mock 데이터(7개 셀러 전부)에 실제 소개글 문구를 채운다. 없는 셀러는 없음(전부 채움).

`StoreSellerService.getSellerReviews(String sellerId)` (신규): 내부적으로 `StoreService.getProductsBySeller(sellerId)`를 호출해 모든 상품의 `reviews`를 평탄화하고, 각 리뷰에 상품명을 붙인 경량 모델(`StoreSellerReviewEntry { productId, productName, review }`)의 리스트를 최신순으로 반환.

## 5. 네비게이션

- 신규 라우트: `AppRoutes.spareHomeStoreSellerProfile(String sellerId)` → `/spare/home/store_seller_profile?sellerId=...` (기존 `spareHomeStoreForSeller`와 다른 새 상수, 기존 것은 그대로 둠)
- "인기 스토어" 카드 탭(`store_screen.dart`의 `_openSellerFromCard`) → 이 새 라우트로 `push`
- `StoreAllSellersScreen`의 셀러 항목 탭 → 이 새 라우트로 `push` (기존에 `spareHomeStoreForSeller`로 가던 것을 교체)
- 기존 `StoreScreen(sellerId: ...)` 필터 뷰와 `spareHomeStoreForSeller` 라우트/테스트는 코드에 그대로 남겨둔다 (사용자 지시 — 이번엔 정리하지 않음)

## 6. 테스트

- `StoreSeller`/mock 데이터: 소개글 필드 채워졌는지
- `getSellerReviews`: 여러 상품의 리뷰가 올바르게 합쳐지고 최신순 정렬되는지, 리뷰 없는 셀러는 빈 리스트
- `StoreSellerProfileScreen` 위젯 테스트: 프로필 정보·통계 노출, 상품/리뷰 탭 전환, 검색 필터링, 팔로우 토글
- 네비게이션: 인기 스토어 카드 탭 → 이 화면 진입 확인 (기존 `store_screen_home_sections_test.dart` 또는 신규 테스트)

## 7. Tech Stack

Flutter, `provider`, `go_router`, 기존 패턴 그대로. 백엔드 없음 — 전부 mock.
