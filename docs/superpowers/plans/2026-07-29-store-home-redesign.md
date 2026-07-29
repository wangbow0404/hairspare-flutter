# 스토어 홈 화면 리디자인 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** `StoreScreen`(`/spare/home/store`)에 "인기 스토어"(팔로우 포함)·바로가기 숏컷·"지금 뜨는 스토어의 상품" 섹션을 추가하고 카테고리 아이콘을 소프트 배지 스타일로 바꿔, 멀티 셀러 마켓플레이스라는 정체성을 홈 화면에서 드러낸다.

**Architecture:** 기존 mock 서비스(`StoreService`, `StoreSellerService`)에 집계·필터 메서드를 추가하고, 새 로컬 상태 Provider 2개(팔로우, 최근 본 상품)를 기존 `StoreWishlistProvider`와 동일한 패턴으로 추가한다. 신규 화면 3개는 기존 서브페이지 패턴(`SpareSubpageAppBar` + `_isLoading/_error` 상태 머신)을 그대로 따른다. 백엔드는 아직 없으므로([[backend-railway-down-ncp-migration]]) 전부 mock 데이터·로컬 상태로 구현한다.

**Tech Stack:** Flutter, `provider` (ChangeNotifier), `go_router`, 기존 `hairspare` 패키지 구조.

## Global Constraints

- 패키지명은 `hairspare` — 테스트 import는 `package:hairspare/...` 사용.
- 색상·간격은 반드시 `HairSpareColors`/`AppTheme`의 기존 토큰만 사용 (임의 하드코딩 색상 금지). 소프트 배지 배경은 `HairSpareColors.brandPrimarySoft`(`0xFFFBEAF0`), 아이콘 색은 `HairSpareColors.brandPrimary`(`0xFFB3355C`).
- 신규 서브페이지 AppBar는 `SpareSubpageAppBar(title: ..., showToolbarActions: false)` 패턴을 따른다 (기존 `store_my_screen.dart`, `store_wishlist_screen.dart`, `store_cart_screen.dart`와 동일).
- 새 Provider는 `ChangeNotifier` mixin(`with ChangeNotifier`) 사용, `sl.registerLazySingleton`으로 등록 후 `main.dart`의 `MultiProvider`에 `ChangeNotifierProvider.value`로 노출 (기존 `StoreWishlistProvider`와 동일 패턴).
- 위젯 테스트는 DI를 쓰는 화면일 경우 `configureDependencies()` + `sl.reset()` (tearDown) + `dotenv.testLoad(fileInput: '')` + `ApiClient().init(...)` 보일러플레이트를 사용 (`test/spare_home_scroll_view_test.dart` 참고).
- `flutter analyze`는 항상 0 error를 유지해야 한다.

---

## Task 1: `StoreSellerSummary` 모델 + `StoreSellerService.getSellerSummaries()`

**Files:**
- Modify: `lib/models/store_seller.dart`
- Modify: `lib/services/store_seller_service.dart`
- Test: `test/store_seller_summary_test.dart`

**Interfaces:**
- Produces: `class StoreSellerSummary { final StoreSeller seller; final int productCount; final double averageRating; }`
- Produces: `Future<List<StoreSellerSummary>> StoreSellerService.getSellerSummaries(List<StoreProduct> allProducts)` — 승인된(`StoreSellerStatus.approved`) 셀러만 포함, `averageRating` 내림차순 → 동률이면 `productCount` 내림차순 정렬.

- [ ] **Step 1: Write the failing test**

```dart
// test/store_seller_summary_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:hairspare/models/store_product.dart';
import 'package:hairspare/services/store_seller_service.dart';

StoreProduct _product({
  required String id,
  required String sellerId,
  List<StoreProductReview> reviews = const [],
}) {
  return StoreProduct(
    id: id,
    name: '테스트 상품',
    brand: '테스트 브랜드',
    sellerId: sellerId,
    category: StoreProductCategory.scissors,
    price: 10000,
    imageUrls: const ['https://example.com/a.png'],
    description: '설명',
    reviews: reviews,
  );
}

List<StoreProductReview> _fiveStarReviews(int count) => List.generate(
  count,
  (_) => StoreProductReview(
    userName: '테스터',
    rating: 5,
    comment: '좋아요',
    createdAt: DateTime.now(),
  ),
);

void main() {
  group('StoreSellerService.getSellerSummaries', () {
    test('승인된 셀러만 포함하고 평점·상품수로 정렬한다', () async {
      final products = [
        _product(
          id: 'p1',
          sellerId: 'seller-hairspare-official',
          reviews: _fiveStarReviews(2),
        ),
        _product(
          id: 'p2',
          sellerId: 'seller-hairspare-official',
          reviews: _fiveStarReviews(1),
        ),
        _product(
          id: 'p3',
          sellerId: 'seller-junscissors',
          reviews: [
            StoreProductReview(
              userName: '테스터',
              rating: 4,
              comment: '좋아요',
              createdAt: DateTime.now(),
            ),
          ],
        ),
        _product(id: 'p4', sellerId: 'seller-curlstar'),
        _product(id: 'p5', sellerId: 'seller-curlstar'),
        // pending 상태인 seller-bomne는 결과에서 제외되어야 함
        _product(
          id: 'p6',
          sellerId: 'seller-bomne',
          reviews: _fiveStarReviews(5),
        ),
      ];

      final service = StoreSellerService();
      final summaries = await service.getSellerSummaries(products);

      expect(
        summaries.any((s) => s.seller.id == 'seller-bomne'),
        isFalse,
        reason: 'pending 셀러는 제외되어야 함',
      );

      final top = summaries.first;
      expect(top.seller.id, 'seller-hairspare-official');
      expect(top.productCount, 2);
      expect(top.averageRating, 5.0);

      final second = summaries[1];
      expect(second.seller.id, 'seller-junscissors');
      expect(second.productCount, 1);
      expect(second.averageRating, 4.0);

      final curlstar = summaries.firstWhere(
        (s) => s.seller.id == 'seller-curlstar',
      );
      expect(curlstar.productCount, 2);
      expect(curlstar.averageRating, 0.0);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/store_seller_summary_test.dart`
Expected: FAIL — `getSellerSummaries` 메서드가 없어 컴파일 에러.

- [ ] **Step 3: Write minimal implementation**

`lib/models/store_seller.dart` 맨 끝에 추가:

```dart
/// 셀러별 집계 지표(상품수·평균 별점) — [StoreSellerService.getSellerSummaries]가 생성.
class StoreSellerSummary {
  const StoreSellerSummary({
    required this.seller,
    required this.productCount,
    required this.averageRating,
  });

  final StoreSeller seller;
  final int productCount;
  final double averageRating;
}
```

`lib/services/store_seller_service.dart` 상단 import에 추가:

```dart
import '../models/store_product.dart';
```

같은 파일 클래스 내부(마지막 메서드 뒤)에 추가:

```dart
  /// 승인된 셀러의 상품수·평균 별점을 집계 — 평균 별점 내림차순, 동률이면 상품수 내림차순.
  Future<List<StoreSellerSummary>> getSellerSummaries(
    List<StoreProduct> allProducts,
  ) async {
    final approved = await getSellers(status: StoreSellerStatus.approved);
    final summaries = approved.map((seller) {
      final products = allProducts
          .where((p) => p.sellerId == seller.id)
          .toList();
      final totalReviews = products.fold<int>(
        0,
        (sum, p) => sum + p.reviewCount,
      );
      final ratingSum = products.fold<double>(
        0,
        (sum, p) => sum + p.averageRating * p.reviewCount,
      );
      final averageRating = totalReviews == 0 ? 0.0 : ratingSum / totalReviews;
      return StoreSellerSummary(
        seller: seller,
        productCount: products.length,
        averageRating: averageRating,
      );
    }).toList();

    summaries.sort((a, b) {
      final byRating = b.averageRating.compareTo(a.averageRating);
      if (byRating != 0) return byRating;
      return b.productCount.compareTo(a.productCount);
    });
    return summaries;
  }
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/store_seller_summary_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/models/store_seller.dart lib/services/store_seller_service.dart test/store_seller_summary_test.dart
git commit -m "feat: 셀러별 상품수·평점 집계 로직 추가 (StoreSellerSummary)"
```

---

## Task 2: `StoreService.getFeaturedSellerProducts()`

**Files:**
- Modify: `lib/services/store_service.dart`
- Test: `test/store_featured_seller_products_test.dart`

**Interfaces:**
- Produces: `Future<List<StoreProduct>> StoreService.getFeaturedSellerProducts(List<String> sellerIds, {int limit = 8})` — `sellerIds`에 속한 상품 중 베스트셀러 우선, 그다음 평점 내림차순, `limit`개까지.

- [ ] **Step 1: Write the failing test**

```dart
// test/store_featured_seller_products_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:hairspare/services/store_service.dart';

void main() {
  group('StoreService.getFeaturedSellerProducts', () {
    test('베스트셀러 우선 정렬 후 limit 만큼 반환한다', () async {
      final service = StoreService();
      final results = await service.getFeaturedSellerProducts(
        ['seller-hairspare-official', 'seller-junscissors'],
        limit: 2,
      );

      expect(results.length, 2);
      expect(results[0].id, 'store-scissors-1');
      expect(results[1].id, 'store-tools-1');
      expect(results.every((p) => p.isBestSeller), isTrue);
    });

    test('지정하지 않은 셀러의 상품은 제외한다', () async {
      final service = StoreService();
      final results = await service.getFeaturedSellerProducts([
        'seller-curlstar',
      ]);

      expect(results, isNotEmpty);
      expect(results.every((p) => p.sellerId == 'seller-curlstar'), isTrue);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/store_featured_seller_products_test.dart`
Expected: FAIL — 메서드 없음.

- [ ] **Step 3: Write minimal implementation**

`lib/services/store_service.dart`의 `getProductsBySeller` 메서드 뒤에 추가:

```dart
  /// [sellerIds]에 속한 상품 중 베스트셀러·평점 우선으로 골라 [limit]개 반환 —
  /// 홈 "지금 뜨는 스토어의 상품" 섹션용.
  Future<List<StoreProduct>> getFeaturedSellerProducts(
    List<String> sellerIds, {
    int limit = 8,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final results = _mockProducts
        .where((p) => sellerIds.contains(p.sellerId))
        .toList();
    results.sort((a, b) {
      if (a.isBestSeller != b.isBestSeller) {
        return a.isBestSeller ? -1 : 1;
      }
      return b.averageRating.compareTo(a.averageRating);
    });
    return results.take(limit).toList();
  }
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/store_featured_seller_products_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/services/store_service.dart test/store_featured_seller_products_test.dart
git commit -m "feat: 인기 셀러 상품 조회 API 추가 (getFeaturedSellerProducts)"
```

---

## Task 3: `StoreSellerFollowProvider`

**Files:**
- Create: `lib/providers/store_seller_follow_provider.dart`
- Test: `test/store_seller_follow_provider_test.dart`

**Interfaces:**
- Produces: `class StoreSellerFollowProvider with ChangeNotifier { bool isFollowing(String sellerId); int followerCount(String sellerId); void toggle(String sellerId); }`

- [ ] **Step 1: Write the failing test**

```dart
// test/store_seller_follow_provider_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:hairspare/providers/store_seller_follow_provider.dart';

void main() {
  group('StoreSellerFollowProvider', () {
    test('기본 상태는 팔로우하지 않음, 팔로워수는 기준값', () {
      final provider = StoreSellerFollowProvider();
      expect(provider.isFollowing('seller-junscissors'), isFalse);
      expect(provider.followerCount('seller-junscissors'), 216);
    });

    test('toggle 하면 팔로우 상태와 팔로워수가 +1 된다', () {
      final provider = StoreSellerFollowProvider();
      var notified = 0;
      provider.addListener(() => notified++);

      provider.toggle('seller-junscissors');

      expect(provider.isFollowing('seller-junscissors'), isTrue);
      expect(provider.followerCount('seller-junscissors'), 217);
      expect(notified, 1);

      provider.toggle('seller-junscissors');

      expect(provider.isFollowing('seller-junscissors'), isFalse);
      expect(provider.followerCount('seller-junscissors'), 216);
    });

    test('기준값이 없는 셀러는 팔로워수 0에서 시작한다', () {
      final provider = StoreSellerFollowProvider();
      expect(provider.followerCount('seller-unknown'), 0);
      provider.toggle('seller-unknown');
      expect(provider.followerCount('seller-unknown'), 1);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/store_seller_follow_provider_test.dart`
Expected: FAIL — 파일 없음.

- [ ] **Step 3: Write minimal implementation**

```dart
// lib/providers/store_seller_follow_provider.dart
import 'package:flutter/foundation.dart';

/// 스토어 셀러 팔로우 상태 — 결제와 마찬가지로 로컬(앱 세션) 상태로만 관리.
/// 팔로워수는 mock 기준값에 현재 사용자의 팔로우 여부를 반영해 계산한다.
class StoreSellerFollowProvider with ChangeNotifier {
  static const Map<String, int> _baseFollowerCounts = {
    'seller-hairspare-official': 482,
    'seller-junscissors': 216,
    'seller-herzen': 138,
    'seller-curlstar': 97,
    'seller-keracis': 64,
    'seller-colorlab': 41,
  };

  final Set<String> _followedSellerIds = {};

  bool isFollowing(String sellerId) => _followedSellerIds.contains(sellerId);

  int followerCount(String sellerId) {
    final base = _baseFollowerCounts[sellerId] ?? 0;
    return isFollowing(sellerId) ? base + 1 : base;
  }

  void toggle(String sellerId) {
    if (!_followedSellerIds.remove(sellerId)) {
      _followedSellerIds.add(sellerId);
    }
    notifyListeners();
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/store_seller_follow_provider_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/providers/store_seller_follow_provider.dart test/store_seller_follow_provider_test.dart
git commit -m "feat: 스토어 셀러 팔로우 Provider 추가"
```

---

## Task 4: `RecentlyViewedStoreProvider`

**Files:**
- Create: `lib/providers/recently_viewed_store_provider.dart`
- Test: `test/recently_viewed_store_provider_test.dart`

**Interfaces:**
- Produces: `class RecentlyViewedStoreProvider with ChangeNotifier { List<String> get productIds; void recordView(String productId); }` — 최신순, 최대 20개.

- [ ] **Step 1: Write the failing test**

```dart
// test/recently_viewed_store_provider_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:hairspare/providers/recently_viewed_store_provider.dart';

void main() {
  group('RecentlyViewedStoreProvider', () {
    test('최근 본 순서대로(최신 먼저) 기록한다', () {
      final provider = RecentlyViewedStoreProvider();
      provider.recordView('p1');
      provider.recordView('p2');
      provider.recordView('p3');

      expect(provider.productIds, ['p3', 'p2', 'p1']);
    });

    test('이미 본 상품을 다시 보면 맨 앞으로 이동하고 중복되지 않는다', () {
      final provider = RecentlyViewedStoreProvider();
      provider.recordView('p1');
      provider.recordView('p2');
      provider.recordView('p1');

      expect(provider.productIds, ['p1', 'p2']);
    });

    test('20개를 초과하면 오래된 항목부터 제거한다', () {
      final provider = RecentlyViewedStoreProvider();
      for (var i = 0; i < 25; i++) {
        provider.recordView('p$i');
      }

      expect(provider.productIds.length, 20);
      expect(provider.productIds.first, 'p24');
      expect(provider.productIds.contains('p4'), isFalse);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/recently_viewed_store_provider_test.dart`
Expected: FAIL — 파일 없음.

- [ ] **Step 3: Write minimal implementation**

```dart
// lib/providers/recently_viewed_store_provider.dart
import 'package:flutter/foundation.dart';

/// 최근 본 스토어 상품 — 최신순, 최대 [_maxItems]개까지 로컬(앱 세션) 상태로 보관.
class RecentlyViewedStoreProvider with ChangeNotifier {
  static const int _maxItems = 20;

  final List<String> _productIds = [];

  /// 최근 본 순서(최신이 먼저).
  List<String> get productIds => List.unmodifiable(_productIds);

  void recordView(String productId) {
    _productIds.remove(productId);
    _productIds.insert(0, productId);
    if (_productIds.length > _maxItems) {
      _productIds.removeRange(_maxItems, _productIds.length);
    }
    notifyListeners();
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/recently_viewed_store_provider_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/providers/recently_viewed_store_provider.dart test/recently_viewed_store_provider_test.dart
git commit -m "feat: 최근 본 스토어 상품 Provider 추가"
```

---

## Task 5: 새 Provider를 DI·앱 전역에 연결

**Files:**
- Modify: `lib/core/di/service_locator.dart:134-137` 부근
- Modify: `lib/main.dart:97-99` 부근

**Interfaces:**
- Consumes: `StoreSellerFollowProvider` (Task 3), `RecentlyViewedStoreProvider` (Task 4)

- [ ] **Step 1: `service_locator.dart`에 등록 추가**

`sl.registerLazySingleton<StoreCouponProvider>(() => StoreCouponProvider());` 바로 뒤에 추가:

```dart
  sl.registerLazySingleton<StoreSellerFollowProvider>(
    () => StoreSellerFollowProvider(),
  );
  sl.registerLazySingleton<RecentlyViewedStoreProvider>(
    () => RecentlyViewedStoreProvider(),
  );
```

파일 상단 import에도 추가:

```dart
import '../../providers/store_seller_follow_provider.dart';
import '../../providers/recently_viewed_store_provider.dart';
```

- [ ] **Step 2: `main.dart`의 `MultiProvider`에 노출**

`ChangeNotifierProvider.value(value: sl<StoreCouponProvider>()),` 바로 뒤에 추가:

```dart
        ChangeNotifierProvider.value(value: sl<StoreSellerFollowProvider>()),
        ChangeNotifierProvider.value(
          value: sl<RecentlyViewedStoreProvider>(),
        ),
```

`main.dart` 상단 import에도 추가:

```dart
import 'providers/store_seller_follow_provider.dart';
import 'providers/recently_viewed_store_provider.dart';
```

(실제 상대 경로는 `main.dart`에 이미 있는 다른 provider import 문의 경로 스타일을 그대로 따를 것 — 기존 `import 'providers/store_wishlist_provider.dart';` 형태와 동일하게 맞춘다.)

- [ ] **Step 3: 정적 분석으로 검증**

Run: `flutter analyze`
Expected: 0 error (새 클래스가 어디서도 쓰이지 않아 `unused_import` 경고가 뜨면, 이후 Task에서 실제로 사용되므로 이 시점엔 무시 가능 — 단 `error` 레벨은 없어야 함)

- [ ] **Step 4: Commit**

```bash
git add lib/core/di/service_locator.dart lib/main.dart
git commit -m "chore: 셀러 팔로우·최근 본 상품 Provider를 앱 전역에 연결"
```

---

## Task 6: `StoreCategoryRow` 소프트 배지 스타일로 교체

**Files:**
- Modify: `lib/widgets/store/store_category_row.dart:90-109` (`_CategoryTile.build`의 `Container` 부분)
- Test: `test/store_category_row_test.dart`

**Interfaces:**
- 외부 인터페이스 변경 없음 (`StoreCategoryRow({selected, onSelected})` 그대로).

- [ ] **Step 1: Write the failing test**

```dart
// test/store_category_row_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hairspare/models/store_product.dart';
import 'package:hairspare/widgets/store/store_category_row.dart';

void main() {
  testWidgets('카테고리를 탭하면 onSelected로 해당 카테고리를 전달한다', (tester) async {
    StoreProductCategory? selected;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StoreCategoryRow(
            selected: null,
            onSelected: (value) => selected = value,
          ),
        ),
      ),
    );

    await tester.tap(find.text('가위'));
    await tester.pump();

    expect(selected, StoreProductCategory.scissors);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/store_category_row_test.dart`
Expected: 이 시점엔 기존 코드로도 통과할 수 있음(동작 자체는 안 바꾸므로) — 통과하면 다음 스텝에서 스타일만 바꾸고 다시 실행해 회귀가 없는지 확인하는 용도로 사용.

- [ ] **Step 3: 스타일 변경**

`lib/widgets/store/store_category_row.dart`의 `_CategoryTile.build` 안 `Container` 부분을:

```dart
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: selected
                      ? HairSpareColors.activeStructural
                      : HairSpareColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(14),
                  border: selected
                      ? null
                      : Border.all(color: HairSpareColors.border),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: selected
                      ? Colors.white
                      : HairSpareColors.textStrong,
                ),
              ),
```

다음으로 교체:

```dart
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: selected
                      ? HairSpareColors.activeStructural
                      : HairSpareColors.brandPrimarySoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: selected
                      ? Colors.white
                      : HairSpareColors.brandPrimary,
                ),
              ),
```

(선택되지 않은 상태의 배경을 연한 회색+테두리에서 연한 berry 배지로, 아이콘 색을 회색에서 berry로 바꿔 소프트 배지 톤을 준다. 선택된 상태는 기존 검정 active 톤 그대로 유지.)

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/store_category_row_test.dart`
Expected: PASS (탭 동작은 그대로이므로 회귀 없음 확인)

- [ ] **Step 5: Commit**

```bash
git add lib/widgets/store/store_category_row.dart test/store_category_row_test.dart
git commit -m "style: 스토어 카테고리 아이콘을 소프트 배지 스타일로 변경"
```

---

## Task 7: `StoreScreen`에 `sellerId` 필터 지원 추가

**Files:**
- Modify: `lib/core/router/app_routes.dart` (`spareHomeStore` 상수 근처)
- Modify: `lib/core/router/app_router.dart:242-246` (`store` `GoRoute`)
- Modify: `lib/screens/spare/store_screen.dart` (`StoreScreen` 위젯 선언부, `_loadProducts`, `build`)
- Test: `test/store_screen_seller_filter_test.dart`

**Interfaces:**
- Produces: `AppRoutes.spareHomeStoreForSeller(String sellerId) -> String` (경로 헬퍼, 기존 `spareHomeStoreProductDetail`과 동일 패턴)
- Produces: `StoreScreen({super.key, this.sellerId})` — `sellerId`가 있으면 해당 셀러 상품만 그리드에 노출하고 "OOO 스토어 상품만 보는 중 · 전체보기" 칩을 보여준다.

- [ ] **Step 1: `app_routes.dart`에 헬퍼 추가**

`spareHomeStoreMy` 선언 바로 아래에 추가:

```dart
  static String spareHomeStoreForSeller(String sellerId) =>
      '$spareHomeStore?sellerId=$sellerId';
```

- [ ] **Step 2: Write the failing test**

```dart
// test/store_screen_seller_filter_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hairspare/core/di/service_locator.dart';
import 'package:hairspare/providers/cart_provider.dart';
import 'package:hairspare/providers/store_wishlist_provider.dart';
import 'package:hairspare/screens/spare/store_screen.dart';
import 'package:hairspare/utils/api_client.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    dotenv.testLoad(fileInput: '');
    ApiClient().init(
      onSessionExpired: () async {},
      onSessionExpiredMessage: (_) {},
    );
    configureDependencies();
  });

  tearDown(() async {
    await sl.reset();
  });

  testWidgets('sellerId가 있으면 안내 칩이 뜨고 전체보기로 해제할 수 있다', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<CartProvider>.value(
            value: sl<CartProvider>(),
          ),
          ChangeNotifierProvider<StoreWishlistProvider>.value(
            value: sl<StoreWishlistProvider>(),
          ),
        ],
        child: const MaterialApp(
          home: StoreScreen(sellerId: 'seller-hairspare-official'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('스토어 상품만 보는 중'), findsOneWidget);

    await tester.tap(find.text('전체보기'));
    await tester.pumpAndSettle();

    expect(find.textContaining('스토어 상품만 보는 중'), findsNothing);
  });
}
```

- [ ] **Step 3: Run test to verify it fails**

Run: `flutter test test/store_screen_seller_filter_test.dart`
Expected: FAIL — `StoreScreen`에 `sellerId` 파라미터가 없어 컴파일 에러.

- [ ] **Step 4: `store_screen.dart` 수정**

클래스 선언부를:

```dart
class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}
```

다음으로 교체:

```dart
class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key, this.sellerId});

  /// 특정 셀러 상품만 보고 있을 때(예: "인기 스토어" 카드 탭) 설정됨.
  final String? sellerId;

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}
```

`_StoreScreenState`에 필드 추가 (`String? _error;` 바로 아래):

```dart
  String? _sellerFilter;
```

`initState`를:

```dart
  @override
  void initState() {
    super.initState();
    _loadProducts();
    StoreShellActions.openCategorySheet.addListener(_onCategorySheetRequested);
  }
```

다음으로 교체:

```dart
  @override
  void initState() {
    super.initState();
    _sellerFilter = widget.sellerId;
    _loadProducts();
    StoreShellActions.openCategorySheet.addListener(_onCategorySheetRequested);
  }
```

`_loadProducts`의 `setState` 블록 안, `_products = results[0] as List<StoreProduct>;` 줄을:

```dart
      setState(() {
        _products = results[0] as List<StoreProduct>;
        _banners = results[1] as List<StorePromoBanner>;
        _bestSellers = (results[2] as List<StoreProduct>)
            .where((p) => p.isBestSeller)
            .take(6)
            .toList();
        _isLoading = false;
      });
```

다음으로 교체:

```dart
      var products = results[0] as List<StoreProduct>;
      if (_sellerFilter != null) {
        products = products
            .where((p) => p.sellerId == _sellerFilter)
            .toList();
      }
      setState(() {
        _products = products;
        _banners = results[1] as List<StorePromoBanner>;
        _bestSellers = _sellerFilter != null
            ? []
            : (results[2] as List<StoreProduct>)
                  .where((p) => p.isBestSeller)
                  .take(6)
                  .toList();
        _isLoading = false;
      });
```

`_onCategorySelected` 아래에 필터 해제 메서드 추가:

```dart
  void _clearSellerFilter() {
    setState(() => _sellerFilter = null);
    _loadProducts();
  }
```

`_gridSectionTitle` 게터 바로 위에 셀러 이름 게터 추가:

```dart
  String? get _sellerFilterName {
    final sellerId = _sellerFilter;
    if (sellerId == null) return null;
    return sl<StoreSellerService>().getSellerByIdSync(sellerId)?.shopName;
  }
```

파일 상단 import에 추가:

```dart
import '../../services/store_seller_service.dart';
```

`build`의 `CustomScrollView`의 `slivers` 리스트에서, 검색바 `SliverToBoxAdapter` 바로 뒤(배너/카테고리 `SliverToBoxAdapter` 앞)에 삽입:

```dart
                  if (_sellerFilter != null)
                    SliverToBoxAdapter(
                      child: Container(
                        width: double.infinity,
                        color: HairSpareColors.brandPrimarySoft,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacing4,
                          vertical: AppTheme.spacing2,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${_sellerFilterName ?? '선택한'} 스토어 상품만 보는 중',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: HairSpareColors.brandPrimary,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: _clearSellerFilter,
                              child: const Text('전체보기'),
                            ),
                          ],
                        ),
                      ),
                    ),
```

`_gridSectionTitle` 대신 필터 시 셀러 이름을 쓰도록, `_SectionHeader(title: _gridSectionTitle)` 부분을:

```dart
                  SliverToBoxAdapter(
                    child: _SectionHeader(title: _gridSectionTitle),
                  ),
```

다음으로 교체:

```dart
                  SliverToBoxAdapter(
                    child: _SectionHeader(
                      title: _sellerFilter != null
                          ? '${_sellerFilterName ?? ''} 상품'
                          : _gridSectionTitle,
                    ),
                  ),
```

- [ ] **Step 5: `app_router.dart`의 `store` 라우트가 쿼리 파라미터를 읽도록 수정**

```dart
                        GoRoute(
                          path: 'store',
                          builder:
                              (BuildContext context, GoRouterState state) =>
                                  const StoreScreen(),
                        ),
```

다음으로 교체:

```dart
                        GoRoute(
                          path: 'store',
                          builder: (BuildContext context, GoRouterState state) {
                            final sellerId =
                                state.uri.queryParameters['sellerId'];
                            return StoreScreen(sellerId: sellerId);
                          },
                        ),
```

- [ ] **Step 6: Run test to verify it passes**

Run: `flutter test test/store_screen_seller_filter_test.dart`
Expected: PASS

- [ ] **Step 7: Commit**

```bash
git add lib/core/router/app_routes.dart lib/core/router/app_router.dart lib/screens/spare/store_screen.dart test/store_screen_seller_filter_test.dart
git commit -m "feat: 스토어 홈에서 특정 셀러 상품만 보는 필터 뷰 추가"
```

---

## Task 8: 상품 상세 조회 시 "최근 본 상품" 기록

**Files:**
- Modify: `lib/screens/spare/store_product_detail_screen.dart:46-77` (`_loadProduct`)
- Test: `test/store_product_detail_recently_viewed_test.dart`

**Interfaces:**
- Consumes: `RecentlyViewedStoreProvider.recordView(String productId)` (Task 4)

- [ ] **Step 1: Write the failing test**

```dart
// test/store_product_detail_recently_viewed_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hairspare/core/di/service_locator.dart';
import 'package:hairspare/providers/cart_provider.dart';
import 'package:hairspare/providers/recently_viewed_store_provider.dart';
import 'package:hairspare/providers/store_wishlist_provider.dart';
import 'package:hairspare/screens/spare/store_product_detail_screen.dart';
import 'package:hairspare/utils/api_client.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    dotenv.testLoad(fileInput: '');
    ApiClient().init(
      onSessionExpired: () async {},
      onSessionExpiredMessage: (_) {},
    );
    configureDependencies();
  });

  tearDown(() async {
    await sl.reset();
  });

  testWidgets('상품 상세를 열면 최근 본 상품에 기록된다', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<CartProvider>.value(
            value: sl<CartProvider>(),
          ),
          ChangeNotifierProvider<StoreWishlistProvider>.value(
            value: sl<StoreWishlistProvider>(),
          ),
          ChangeNotifierProvider<RecentlyViewedStoreProvider>.value(
            value: sl<RecentlyViewedStoreProvider>(),
          ),
        ],
        child: const MaterialApp(
          home: StoreProductDetailScreen(productId: 'store-scissors-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      sl<RecentlyViewedStoreProvider>().productIds,
      contains('store-scissors-1'),
    );
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/store_product_detail_recently_viewed_test.dart`
Expected: FAIL — `productIds`에 기록이 없어 `contains` 매처 실패.

- [ ] **Step 3: `_loadProduct`에 기록 로직 추가**

```dart
  Future<void> _loadProduct() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final product = await _storeService.getProductById(widget.productId);
      final sellerProducts = await _storeService.getProductsBySeller(
        product.sellerId,
        excludeId: product.id,
      );
      if (!mounted) return;
      setState(() {
        _product = product;
        _sellerProducts = sellerProducts;
        _isLoading = false;
      });
    } catch (error) {
```

`setState` 블록 뒤에 한 줄 추가:

```dart
      if (!mounted) return;
      setState(() {
        _product = product;
        _sellerProducts = sellerProducts;
        _isLoading = false;
      });
      sl<RecentlyViewedStoreProvider>().recordView(product.id);
    } catch (error) {
```

파일 상단 import에 추가:

```dart
import '../../providers/recently_viewed_store_provider.dart';
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/store_product_detail_recently_viewed_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/screens/spare/store_product_detail_screen.dart test/store_product_detail_recently_viewed_test.dart
git commit -m "feat: 상품 상세 진입 시 최근 본 상품에 기록"
```

---

## Task 9: `StoreSellerCard` 위젯 (인기 스토어 카드)

**Files:**
- Create: `lib/widgets/store/store_seller_card.dart`
- Test: `test/store_seller_card_test.dart`

**Interfaces:**
- Consumes: `StoreSellerSummary` (Task 1)
- Produces: `StoreSellerCard({required StoreSellerSummary summary, required bool isFollowing, required int followerCount, required VoidCallback onTap, required VoidCallback onFollowToggle})`

- [ ] **Step 1: Write the failing test**

```dart
// test/store_seller_card_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hairspare/models/store_seller.dart';
import 'package:hairspare/widgets/store/store_seller_card.dart';

StoreSellerSummary _summary() => StoreSellerSummary(
  seller: StoreSeller(
    id: 'seller-junscissors',
    shopName: '준가위 공구몰',
    ownerName: '김준호',
    status: StoreSellerStatus.approved,
    appliedAt: DateTime(2026, 1, 1),
  ),
  productCount: 12,
  averageRating: 4.7,
);

void main() {
  testWidgets('카드를 탭하면 onTap, 팔로우 버튼을 탭하면 onFollowToggle이 호출된다', (
    tester,
  ) async {
    var tapped = false;
    var followToggled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StoreSellerCard(
            summary: _summary(),
            isFollowing: false,
            followerCount: 216,
            onTap: () => tapped = true,
            onFollowToggle: () => followToggled = true,
          ),
        ),
      ),
    );

    expect(find.text('준가위 공구몰'), findsOneWidget);
    expect(find.text('+ 팔로우'), findsOneWidget);

    await tester.tap(find.text('+ 팔로우'));
    await tester.pump();
    expect(followToggled, isTrue);
    expect(tapped, isFalse);

    await tester.tap(find.text('준가위 공구몰'));
    await tester.pump();
    expect(tapped, isTrue);
  });

  testWidgets('isFollowing이 true면 "팔로잉"으로 표시된다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StoreSellerCard(
            summary: _summary(),
            isFollowing: true,
            followerCount: 217,
            onTap: () {},
            onFollowToggle: () {},
          ),
        ),
      ),
    );

    expect(find.text('팔로잉'), findsOneWidget);
    expect(find.text('+ 팔로우'), findsNothing);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/store_seller_card_test.dart`
Expected: FAIL — 파일 없음.

- [ ] **Step 3: Write minimal implementation**

```dart
// lib/widgets/store/store_seller_card.dart
import 'package:flutter/material.dart';

import '../../models/store_seller.dart';
import '../../theme/app_theme.dart';
import '../../theme/hairspare_colors.dart';

/// 스토어 홈 "인기 스토어" 섹션 카드 — 아바타·이름·상품수·별점·팔로우 버튼.
class StoreSellerCard extends StatelessWidget {
  const StoreSellerCard({
    super.key,
    required this.summary,
    required this.isFollowing,
    required this.followerCount,
    required this.onTap,
    required this.onFollowToggle,
  });

  final StoreSellerSummary summary;
  final bool isFollowing;
  final int followerCount;
  final VoidCallback onTap;
  final VoidCallback onFollowToggle;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: HairSpareColors.surface,
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: Container(
          width: 130,
          padding: const EdgeInsets.symmetric(
            vertical: AppTheme.spacing3,
            horizontal: AppTheme.spacing2,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(color: HairSpareColors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: HairSpareColors.brandPrimarySoft,
                child: Text(
                  summary.seller.shopName.substring(0, 1),
                  style: const TextStyle(
                    color: HairSpareColors.brandPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacing2),
              Text(
                summary.seller.shopName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: HairSpareColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '상품 ${summary.productCount} · ★${summary.averageRating.toStringAsFixed(1)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10,
                  color: HairSpareColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppTheme.spacing2),
              SizedBox(
                width: double.infinity,
                height: 28,
                child: OutlinedButton(
                  onPressed: onFollowToggle,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    side: BorderSide(
                      color: isFollowing
                          ? HairSpareColors.border
                          : HairSpareColors.brandPrimary,
                    ),
                    foregroundColor: isFollowing
                        ? HairSpareColors.textSecondary
                        : HairSpareColors.brandPrimary,
                  ),
                  child: Text(
                    isFollowing ? '팔로잉' : '+ 팔로우',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/store_seller_card_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/widgets/store/store_seller_card.dart test/store_seller_card_test.dart
git commit -m "feat: 인기 스토어 카드 위젯 추가 (StoreSellerCard)"
```

---

## Task 10: `StoreFeatureShortcuts` 위젯 (바로가기 숏컷)

**Files:**
- Create: `lib/widgets/store/store_feature_shortcuts.dart`
- Test: `test/store_feature_shortcuts_test.dart`

**Interfaces:**
- Produces: `StoreFeatureShortcuts({required int cartCount, required int wishlistCount, required VoidCallback onCart, required VoidCallback onWishlist, required VoidCallback onOrders, required VoidCallback onAllSellers, required VoidCallback onCouponBox, required VoidCallback onRecentlyViewed})`

- [ ] **Step 1: Write the failing test**

```dart
// test/store_feature_shortcuts_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hairspare/widgets/store/store_feature_shortcuts.dart';

void main() {
  testWidgets('각 숏컷을 탭하면 해당 콜백이 호출된다', (tester) async {
    final tapped = <String>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StoreFeatureShortcuts(
            cartCount: 2,
            wishlistCount: 5,
            onCart: () => tapped.add('cart'),
            onWishlist: () => tapped.add('wishlist'),
            onOrders: () => tapped.add('orders'),
            onAllSellers: () => tapped.add('allSellers'),
            onCouponBox: () => tapped.add('couponBox'),
            onRecentlyViewed: () => tapped.add('recentlyViewed'),
          ),
        ),
      ),
    );

    expect(find.text('2'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);

    await tester.tap(find.text('장바구니'));
    await tester.tap(find.text('찜한 상품'));
    await tester.tap(find.text('주문내역'));
    await tester.tap(find.text('전체 스토어'));
    await tester.tap(find.text('쿠폰함'));
    await tester.tap(find.text('최근 본 상품'));
    await tester.pump();

    expect(
      tapped,
      containsAll([
        'cart',
        'wishlist',
        'orders',
        'allSellers',
        'couponBox',
        'recentlyViewed',
      ]),
    );
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/store_feature_shortcuts_test.dart`
Expected: FAIL — 파일 없음.

- [ ] **Step 3: Write minimal implementation**

```dart
// lib/widgets/store/store_feature_shortcuts.dart
import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../theme/hairspare_colors.dart';

/// 스토어 홈 바로가기 숏컷 — 장바구니/찜/주문내역/전체스토어/쿠폰함/최근본상품.
class StoreFeatureShortcuts extends StatelessWidget {
  const StoreFeatureShortcuts({
    super.key,
    required this.cartCount,
    required this.wishlistCount,
    required this.onCart,
    required this.onWishlist,
    required this.onOrders,
    required this.onAllSellers,
    required this.onCouponBox,
    required this.onRecentlyViewed,
  });

  final int cartCount;
  final int wishlistCount;
  final VoidCallback onCart;
  final VoidCallback onWishlist;
  final VoidCallback onOrders;
  final VoidCallback onAllSellers;
  final VoidCallback onCouponBox;
  final VoidCallback onRecentlyViewed;

  @override
  Widget build(BuildContext context) {
    final items = <_ShortcutItem>[
      _ShortcutItem(Icons.shopping_cart_outlined, '장바구니', cartCount, onCart),
      _ShortcutItem(
        Icons.favorite_border,
        '찜한 상품',
        wishlistCount,
        onWishlist,
      ),
      _ShortcutItem(Icons.receipt_long_outlined, '주문내역', 0, onOrders),
      _ShortcutItem(
        Icons.storefront_outlined,
        '전체 스토어',
        0,
        onAllSellers,
      ),
      _ShortcutItem(
        Icons.confirmation_number_outlined,
        '쿠폰함',
        0,
        onCouponBox,
      ),
      _ShortcutItem(Icons.history, '최근 본 상품', 0, onRecentlyViewed),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing2),
      child: Wrap(
        children: [
          for (final item in items)
            SizedBox(
              width: MediaQuery.of(context).size.width / 3,
              child: _ShortcutTile(item: item),
            ),
        ],
      ),
    );
  }
}

class _ShortcutItem {
  const _ShortcutItem(this.icon, this.label, this.badge, this.onTap);

  final IconData icon;
  final String label;
  final int badge;
  final VoidCallback onTap;
}

class _ShortcutTile extends StatelessWidget {
  const _ShortcutTile({required this.item});

  final _ShortcutItem item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing3),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: HairSpareColors.brandPrimarySoft,
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                  ),
                  child: Icon(
                    item.icon,
                    size: 20,
                    color: HairSpareColors.brandPrimary,
                  ),
                ),
                if (item.badge > 0)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1,
                      ),
                      decoration: const BoxDecoration(
                        color: HairSpareColors.statusUrgent,
                        borderRadius: BorderRadius.all(Radius.circular(999)),
                      ),
                      constraints: const BoxConstraints(minWidth: 16),
                      child: Text(
                        '${item.badge}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: HairSpareColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/store_feature_shortcuts_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/widgets/store/store_feature_shortcuts.dart test/store_feature_shortcuts_test.dart
git commit -m "feat: 스토어 홈 바로가기 숏컷 위젯 추가 (StoreFeatureShortcuts)"
```

---

## Task 11: `StoreAllSellersScreen` (전체 스토어 목록)

**Files:**
- Create: `lib/screens/spare/store_all_sellers_screen.dart`
- Modify: `lib/core/router/app_routes.dart`
- Modify: `lib/core/router/shared_leaf_routes.dart`
- Test: `test/store_all_sellers_screen_test.dart`

**Interfaces:**
- Consumes: `StoreSellerService.getSellerSummaries` (Task 1), `StoreSellerFollowProvider` (Task 3), `AppRoutes.spareHomeStoreForSeller` (Task 7)
- Produces: `AppRoutes.spareHomeStoreAllSellers` (경로 상수), `StoreAllSellersScreen` 위젯

- [ ] **Step 1: `app_routes.dart`에 경로 상수 추가**

`spareHomeStoreMy` 선언 아래, Task 7에서 추가한 `spareHomeStoreForSeller` 헬퍼 위나 아래에 추가:

```dart
  static const spareHomeStoreAllSellers = '/spare/home/store_all_sellers';
```

- [ ] **Step 2: Write the failing test**

```dart
// test/store_all_sellers_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hairspare/core/di/service_locator.dart';
import 'package:hairspare/providers/store_seller_follow_provider.dart';
import 'package:hairspare/screens/spare/store_all_sellers_screen.dart';
import 'package:hairspare/utils/api_client.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    dotenv.testLoad(fileInput: '');
    ApiClient().init(
      onSessionExpired: () async {},
      onSessionExpiredMessage: (_) {},
    );
    configureDependencies();
  });

  tearDown(() async {
    await sl.reset();
  });

  testWidgets('승인된 셀러 목록을 보여준다', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<StoreSellerFollowProvider>.value(
            value: sl<StoreSellerFollowProvider>(),
          ),
        ],
        child: const MaterialApp(home: StoreAllSellersScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('준가위 공구몰'), findsOneWidget);
    expect(find.text('봄이네뷰티'), findsNothing); // pending 셀러는 제외
  });

  testWidgets('팔로우 버튼을 탭하면 상태가 바뀐다', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<StoreSellerFollowProvider>.value(
            value: sl<StoreSellerFollowProvider>(),
          ),
        ],
        child: const MaterialApp(home: StoreAllSellersScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('+ 팔로우').first);
    await tester.pump();

    expect(find.text('팔로잉'), findsOneWidget);
  });
}
```

- [ ] **Step 3: Run test to verify it fails**

Run: `flutter test test/store_all_sellers_screen_test.dart`
Expected: FAIL — 파일 없음.

- [ ] **Step 4: Write minimal implementation**

```dart
// lib/screens/spare/store_all_sellers_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/di/service_locator.dart';
import '../../core/router/app_routes.dart';
import '../../models/store_seller.dart';
import '../../providers/store_seller_follow_provider.dart';
import '../../services/store_seller_service.dart';
import '../../services/store_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/hairspare_colors.dart';
import '../../utils/error_handler.dart';
import '../../widgets/common/spare_subpage_app_bar.dart';

/// 전체 스토어(셀러) 목록 — 스토어 홈 "인기 스토어" 섹션 더보기·바로가기에서 진입.
class StoreAllSellersScreen extends StatefulWidget {
  const StoreAllSellersScreen({super.key});

  @override
  State<StoreAllSellersScreen> createState() => _StoreAllSellersScreenState();
}

class _StoreAllSellersScreenState extends State<StoreAllSellersScreen> {
  final StoreService _storeService = sl<StoreService>();
  final StoreSellerService _sellerService = sl<StoreSellerService>();
  List<StoreSellerSummary> _summaries = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final products = await _storeService.getProducts();
      final summaries = await _sellerService.getSellerSummaries(products);
      if (!mounted) return;
      setState(() {
        _summaries = summaries;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      final appException = ErrorHandler.handleException(error);
      setState(() {
        _error = ErrorHandler.getUserFriendlyMessage(appException);
        _isLoading = false;
      });
    }
  }

  void _openSellerProducts(StoreSeller seller) {
    context.push(AppRoutes.spareHomeStoreForSeller(seller.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: const SpareSubpageAppBar(
        title: '전체 스토어',
        showToolbarActions: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_error!),
                  const SizedBox(height: AppTheme.spacing3),
                  TextButton(onPressed: _load, child: const Text('다시 시도')),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppTheme.spacing4),
              itemCount: _summaries.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppTheme.spacing3),
              itemBuilder: (context, index) {
                final summary = _summaries[index];
                return Consumer<StoreSellerFollowProvider>(
                  builder: (context, follow, _) {
                    final sellerId = summary.seller.id;
                    return _SellerRow(
                      summary: summary,
                      isFollowing: follow.isFollowing(sellerId),
                      followerCount: follow.followerCount(sellerId),
                      onTap: () => _openSellerProducts(summary.seller),
                      onFollowToggle: () => follow.toggle(sellerId),
                    );
                  },
                );
              },
            ),
    );
  }
}

class _SellerRow extends StatelessWidget {
  const _SellerRow({
    required this.summary,
    required this.isFollowing,
    required this.followerCount,
    required this.onTap,
    required this.onFollowToggle,
  });

  final StoreSellerSummary summary;
  final bool isFollowing;
  final int followerCount;
  final VoidCallback onTap;
  final VoidCallback onFollowToggle;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: HairSpareColors.surface,
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing4),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: HairSpareColors.brandPrimarySoft,
                child: Text(
                  summary.seller.shopName.substring(0, 1),
                  style: const TextStyle(
                    color: HairSpareColors.brandPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spacing3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      summary.seller.shopName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: HairSpareColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '상품 ${summary.productCount} · 팔로워 $followerCount',
                      style: const TextStyle(
                        fontSize: 12,
                        color: HairSpareColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: onFollowToggle,
                child: Text(isFollowing ? '팔로잉' : '+ 팔로우'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 5: 라우트 등록**

`lib/core/router/shared_leaf_routes.dart` 상단 import에 추가:

```dart
import '../../screens/spare/store_all_sellers_screen.dart';
```

`GoRoute(path: 'store_my', ...)` 뒤에 추가:

```dart
    GoRoute(
      path: 'store_all_sellers',
      builder: (_, __) => const StoreAllSellersScreen(),
    ),
```

- [ ] **Step 6: Run test to verify it passes**

Run: `flutter test test/store_all_sellers_screen_test.dart`
Expected: PASS

- [ ] **Step 7: Commit**

```bash
git add lib/screens/spare/store_all_sellers_screen.dart lib/core/router/app_routes.dart lib/core/router/shared_leaf_routes.dart test/store_all_sellers_screen_test.dart
git commit -m "feat: 전체 스토어 목록 화면 추가 (StoreAllSellersScreen)"
```

---

## Task 12: `StoreCouponBoxScreen` (쿠폰함)

**Files:**
- Create: `lib/screens/spare/store_coupon_box_screen.dart`
- Modify: `lib/core/router/app_routes.dart`
- Modify: `lib/core/router/shared_leaf_routes.dart`
- Test: `test/store_coupon_box_screen_test.dart`

**Interfaces:**
- Consumes: 기존 `StoreCouponService.getCoupons()`, `StoreCouponProvider.isClaimed/claim` (변경 없음)
- Produces: `AppRoutes.spareHomeStoreCouponBox`, `StoreCouponBoxScreen`

- [ ] **Step 1: `app_routes.dart`에 경로 상수 추가**

```dart
  static const spareHomeStoreCouponBox = '/spare/home/store_coupon_box';
```

- [ ] **Step 2: Write the failing test**

```dart
// test/store_coupon_box_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hairspare/core/di/service_locator.dart';
import 'package:hairspare/providers/store_coupon_provider.dart';
import 'package:hairspare/screens/spare/store_coupon_box_screen.dart';
import 'package:hairspare/utils/api_client.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    dotenv.testLoad(fileInput: '');
    ApiClient().init(
      onSessionExpired: () async {},
      onSessionExpiredMessage: (_) {},
    );
    configureDependencies();
  });

  tearDown(() async {
    await sl.reset();
  });

  testWidgets('보유 쿠폰 목록을 보여주고 받기를 누르면 받음으로 바뀐다', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<StoreCouponProvider>.value(
            value: sl<StoreCouponProvider>(),
          ),
        ],
        child: const MaterialApp(home: StoreCouponBoxScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('스토어 첫 구매 5,000원 할인'), findsOneWidget);

    await tester.tap(find.text('받기').first);
    await tester.pump();

    expect(find.text('받음'), findsOneWidget);
  });
}
```

- [ ] **Step 3: Run test to verify it fails**

Run: `flutter test test/store_coupon_box_screen_test.dart`
Expected: FAIL — 파일 없음.

- [ ] **Step 4: Write minimal implementation**

```dart
// lib/screens/spare/store_coupon_box_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/di/service_locator.dart';
import '../../models/store_coupon.dart';
import '../../providers/store_coupon_provider.dart';
import '../../services/store_coupon_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/hairspare_colors.dart';
import '../../widgets/common/spare_subpage_app_bar.dart';

/// 보유 쿠폰함 — 스토어 홈 바로가기 숏컷에서 진입.
class StoreCouponBoxScreen extends StatefulWidget {
  const StoreCouponBoxScreen({super.key});

  @override
  State<StoreCouponBoxScreen> createState() => _StoreCouponBoxScreenState();
}

class _StoreCouponBoxScreenState extends State<StoreCouponBoxScreen> {
  final StoreCouponService _couponService = sl<StoreCouponService>();
  List<StoreCoupon> _coupons = [];
  bool _isLoading = true;

  static final _priceFmt = NumberFormat('#,###');

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final coupons = await _couponService.getCoupons();
    if (!mounted) return;
    setState(() {
      _coupons = coupons;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: const SpareSubpageAppBar(
        title: '쿠폰함',
        showToolbarActions: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _coupons.isEmpty
          ? const Center(child: Text('보유한 쿠폰이 없습니다'))
          : Consumer<StoreCouponProvider>(
              builder: (context, couponState, _) {
                return ListView.separated(
                  padding: const EdgeInsets.all(AppTheme.spacing4),
                  itemCount: _coupons.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppTheme.spacing3),
                  itemBuilder: (context, index) {
                    final coupon = _coupons[index];
                    final claimed = couponState.isClaimed(coupon.id);
                    return _CouponTile(
                      coupon: coupon,
                      claimed: claimed,
                      onClaim: () => couponState.claim(coupon.id),
                      priceFmt: _priceFmt,
                    );
                  },
                );
              },
            ),
    );
  }
}

class _CouponTile extends StatelessWidget {
  const _CouponTile({
    required this.coupon,
    required this.claimed,
    required this.onClaim,
    required this.priceFmt,
  });

  final StoreCoupon coupon;
  final bool claimed;
  final VoidCallback onClaim;
  final NumberFormat priceFmt;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing4),
      decoration: BoxDecoration(
        color: HairSpareColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: HairSpareColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  coupon.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: HairSpareColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${priceFmt.format(coupon.minPurchaseAmount)}원 이상 구매 시 · '
                  '${DateFormat('yyyy.MM.dd').format(coupon.expiresAt)}까지',
                  style: const TextStyle(
                    fontSize: 12,
                    color: HairSpareColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: claimed ? null : onClaim,
            child: Text(claimed ? '받음' : '받기'),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 5: 라우트 등록**

`shared_leaf_routes.dart` 상단 import에 추가:

```dart
import '../../screens/spare/store_coupon_box_screen.dart';
```

방금 추가한 `store_all_sellers` `GoRoute` 뒤에 추가:

```dart
    GoRoute(
      path: 'store_coupon_box',
      builder: (_, __) => const StoreCouponBoxScreen(),
    ),
```

- [ ] **Step 6: Run test to verify it passes**

Run: `flutter test test/store_coupon_box_screen_test.dart`
Expected: PASS

- [ ] **Step 7: Commit**

```bash
git add lib/screens/spare/store_coupon_box_screen.dart lib/core/router/app_routes.dart lib/core/router/shared_leaf_routes.dart test/store_coupon_box_screen_test.dart
git commit -m "feat: 스토어 쿠폰함 화면 추가 (StoreCouponBoxScreen)"
```

---

## Task 13: `StoreRecentlyViewedScreen` (최근 본 상품)

**Files:**
- Create: `lib/screens/spare/store_recently_viewed_screen.dart`
- Modify: `lib/core/router/app_routes.dart`
- Modify: `lib/core/router/shared_leaf_routes.dart`
- Test: `test/store_recently_viewed_screen_test.dart`

**Interfaces:**
- Consumes: `RecentlyViewedStoreProvider.productIds` (Task 4), `StoreService.getProductById`, `StoreWishlistProvider`, `StoreProductCard`
- Produces: `AppRoutes.spareHomeStoreRecentlyViewed`, `StoreRecentlyViewedScreen`

- [ ] **Step 1: `app_routes.dart`에 경로 상수 추가**

```dart
  static const spareHomeStoreRecentlyViewed =
      '/spare/home/store_recently_viewed';
```

- [ ] **Step 2: Write the failing test**

```dart
// test/store_recently_viewed_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hairspare/core/di/service_locator.dart';
import 'package:hairspare/providers/recently_viewed_store_provider.dart';
import 'package:hairspare/providers/store_wishlist_provider.dart';
import 'package:hairspare/screens/spare/store_recently_viewed_screen.dart';
import 'package:hairspare/utils/api_client.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    dotenv.testLoad(fileInput: '');
    ApiClient().init(
      onSessionExpired: () async {},
      onSessionExpiredMessage: (_) {},
    );
    configureDependencies();
  });

  tearDown(() async {
    await sl.reset();
  });

  testWidgets('기록이 없으면 빈 상태 문구를 보여준다', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<StoreWishlistProvider>.value(
            value: sl<StoreWishlistProvider>(),
          ),
        ],
        child: const MaterialApp(home: StoreRecentlyViewedScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('최근 본 상품이 없습니다'), findsOneWidget);
  });

  testWidgets('기록된 상품을 보여준다', (tester) async {
    sl<RecentlyViewedStoreProvider>().recordView('store-scissors-1');

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<StoreWishlistProvider>.value(
            value: sl<StoreWishlistProvider>(),
          ),
        ],
        child: const MaterialApp(home: StoreRecentlyViewedScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('프로 커팅 가위 6인치'), findsOneWidget);
  });
}
```

- [ ] **Step 3: Run test to verify it fails**

Run: `flutter test test/store_recently_viewed_screen_test.dart`
Expected: FAIL — 파일 없음.

- [ ] **Step 4: Write minimal implementation**

```dart
// lib/screens/spare/store_recently_viewed_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/di/service_locator.dart';
import '../../core/router/app_routes.dart';
import '../../models/store_product.dart';
import '../../providers/recently_viewed_store_provider.dart';
import '../../providers/store_wishlist_provider.dart';
import '../../services/store_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/spare_subpage_app_bar.dart';
import '../../widgets/store/store_product_card.dart';

/// 최근 본 상품 — 스토어 홈 바로가기 숏컷에서 진입.
class StoreRecentlyViewedScreen extends StatefulWidget {
  const StoreRecentlyViewedScreen({super.key});

  @override
  State<StoreRecentlyViewedScreen> createState() =>
      _StoreRecentlyViewedScreenState();
}

class _StoreRecentlyViewedScreenState
    extends State<StoreRecentlyViewedScreen> {
  final StoreService _storeService = sl<StoreService>();
  List<StoreProduct> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final ids = sl<RecentlyViewedStoreProvider>().productIds;
    final products = <StoreProduct>[];
    for (final id in ids) {
      try {
        products.add(await _storeService.getProductById(id));
      } catch (_) {
        // 삭제된 상품은 건너뜀.
      }
    }
    if (!mounted) return;
    setState(() {
      _products = products;
      _isLoading = false;
    });
  }

  void _openProductDetail(StoreProduct product) {
    context.push(AppRoutes.spareHomeStoreProductDetail(product.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: const SpareSubpageAppBar(
        title: '최근 본 상품',
        showToolbarActions: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _products.isEmpty
          ? const Center(child: Text('최근 본 상품이 없습니다'))
          : GridView.builder(
              padding: const EdgeInsets.all(AppTheme.spacing4),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: AppTheme.spacing4,
                crossAxisSpacing: AppTheme.spacing3,
                childAspectRatio: 0.54,
              ),
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                return Consumer<StoreWishlistProvider>(
                  builder: (context, wishlist, _) {
                    return StoreProductCard(
                      product: product,
                      onTap: () => _openProductDetail(product),
                      isWishlisted: wishlist.isWishlisted(product.id),
                      onWishlistToggle: () => wishlist.toggle(product),
                    );
                  },
                );
              },
            ),
    );
  }
}
```

- [ ] **Step 5: 라우트 등록**

`shared_leaf_routes.dart` 상단 import에 추가:

```dart
import '../../screens/spare/store_recently_viewed_screen.dart';
```

방금 추가한 `store_coupon_box` `GoRoute` 뒤에 추가:

```dart
    GoRoute(
      path: 'store_recently_viewed',
      builder: (_, __) => const StoreRecentlyViewedScreen(),
    ),
```

- [ ] **Step 6: Run test to verify it passes**

Run: `flutter test test/store_recently_viewed_screen_test.dart`
Expected: PASS

- [ ] **Step 7: Commit**

```bash
git add lib/screens/spare/store_recently_viewed_screen.dart lib/core/router/app_routes.dart lib/core/router/shared_leaf_routes.dart test/store_recently_viewed_screen_test.dart
git commit -m "feat: 최근 본 상품 화면 추가 (StoreRecentlyViewedScreen)"
```

---

## Task 14: `StoreScreen` 홈 화면에 신규 섹션 통합

**Files:**
- Modify: `lib/screens/spare/store_screen.dart`
- Test: `test/store_screen_home_sections_test.dart`

**Interfaces:**
- Consumes: `StoreSellerService.getSellerSummaries` (Task 1), `StoreService.getFeaturedSellerProducts` (Task 2), `StoreSellerFollowProvider` (Task 3), `StoreSellerCard` (Task 9), `StoreFeatureShortcuts` (Task 10), `AppRoutes.spareHomeStoreAllSellers` (Task 11), `AppRoutes.spareHomeStoreCouponBox` (Task 12), `AppRoutes.spareHomeStoreRecentlyViewed` (Task 13), `AppRoutes.spareHomeStoreMy`(기존)

- [ ] **Step 1: Write the failing test**

```dart
// test/store_screen_home_sections_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hairspare/core/di/service_locator.dart';
import 'package:hairspare/providers/cart_provider.dart';
import 'package:hairspare/providers/store_seller_follow_provider.dart';
import 'package:hairspare/providers/store_wishlist_provider.dart';
import 'package:hairspare/screens/spare/store_screen.dart';
import 'package:hairspare/utils/api_client.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    dotenv.testLoad(fileInput: '');
    ApiClient().init(
      onSessionExpired: () async {},
      onSessionExpiredMessage: (_) {},
    );
    configureDependencies();
  });

  tearDown(() async {
    await sl.reset();
  });

  testWidgets('필터가 없을 때 인기 스토어·바로가기·지금 뜨는 스토어의 상품 섹션이 보인다', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<CartProvider>.value(
            value: sl<CartProvider>(),
          ),
          ChangeNotifierProvider<StoreWishlistProvider>.value(
            value: sl<StoreWishlistProvider>(),
          ),
          ChangeNotifierProvider<StoreSellerFollowProvider>.value(
            value: sl<StoreSellerFollowProvider>(),
          ),
        ],
        child: const MaterialApp(home: StoreScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('인기 스토어'), findsOneWidget);
    expect(find.text('바로가기'), findsOneWidget);
    expect(find.text('지금 뜨는 스토어의 상품'), findsOneWidget);
    expect(find.text('장바구니'), findsOneWidget); // 숏컷 라벨
  });

  testWidgets('셀러 필터가 있으면 신규 섹션은 숨겨진다', (tester) async {
    tester.view.physicalSize = const Size(390, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<CartProvider>.value(
            value: sl<CartProvider>(),
          ),
          ChangeNotifierProvider<StoreWishlistProvider>.value(
            value: sl<StoreWishlistProvider>(),
          ),
          ChangeNotifierProvider<StoreSellerFollowProvider>.value(
            value: sl<StoreSellerFollowProvider>(),
          ),
        ],
        child: const MaterialApp(
          home: StoreScreen(sellerId: 'seller-hairspare-official'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('인기 스토어'), findsNothing);
    expect(find.text('바로가기'), findsNothing);
    expect(find.text('지금 뜨는 스토어의 상품'), findsNothing);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/store_screen_home_sections_test.dart`
Expected: FAIL — 새 섹션 텍스트가 아직 없음.

- [ ] **Step 3: `store_screen.dart` 수정**

파일 상단 import에 추가:

```dart
import 'package:go_router/go_router.dart';

import '../../models/store_seller.dart';
import '../../providers/store_seller_follow_provider.dart';
import '../../widgets/store/store_feature_shortcuts.dart';
import '../../widgets/store/store_seller_card.dart';
```

(`go_router`는 이미 import돼 있을 수 있으니 중복 없이 확인)

`_StoreScreenState`에 필드 추가 (`List<StorePromoBanner> _banners = [];` 아래):

```dart
  List<StoreSellerSummary> _sellerSummaries = [];
  List<StoreProduct> _featuredSellerProducts = [];
```

파일 상단 import에 `StoreSellerService`가 이미 Task 7에서 추가돼 있으므로 재사용, `_StoreScreenState`에 필드 추가:

```dart
  final StoreSellerService _sellerService = sl<StoreSellerService>();
```

`_loadProducts`의 `Future.wait` 이후 로직을:

```dart
      var products = results[0] as List<StoreProduct>;
      if (_sellerFilter != null) {
        products = products
            .where((p) => p.sellerId == _sellerFilter)
            .toList();
      }
      setState(() {
        _products = products;
        _banners = results[1] as List<StorePromoBanner>;
        _bestSellers = _sellerFilter != null
            ? []
            : (results[2] as List<StoreProduct>)
                  .where((p) => p.isBestSeller)
                  .take(6)
                  .toList();
        _isLoading = false;
      });
```

다음으로 교체:

```dart
      var products = results[0] as List<StoreProduct>;
      if (_sellerFilter != null) {
        products = products
            .where((p) => p.sellerId == _sellerFilter)
            .toList();
      }

      var sellerSummaries = <StoreSellerSummary>[];
      var featuredSellerProducts = <StoreProduct>[];
      if (_sellerFilter == null) {
        final allProducts = await _storeService.getProducts();
        sellerSummaries = await _sellerService.getSellerSummaries(
          allProducts,
        );
        final topSellerIds = sellerSummaries
            .take(6)
            .map((s) => s.seller.id)
            .toList();
        featuredSellerProducts = await _storeService.getFeaturedSellerProducts(
          topSellerIds,
        );
      }

      if (!mounted) return;
      setState(() {
        _products = products;
        _banners = results[1] as List<StorePromoBanner>;
        _bestSellers = _sellerFilter != null
            ? []
            : (results[2] as List<StoreProduct>)
                  .where((p) => p.isBestSeller)
                  .take(6)
                  .toList();
        _sellerSummaries = sellerSummaries;
        _featuredSellerProducts = featuredSellerProducts;
        _isLoading = false;
      });
```

(주의: 기존 코드엔 이 위치에 `if (!mounted) return;`가 `Future.wait` 직후 한 번만 있었다 — 위처럼 새 `await` 호출들 뒤에 다시 한번 `mounted` 체크를 추가해 화면이 dispose된 뒤 setState 호출을 막는다. 기존의 첫 `if (!mounted) return;`는 그대로 유지한다.)

`_StoreScreenState`에 네비게이션 메서드 추가 (`_openSearch` 아래):

```dart
  void _openAllSellers() => context.push(AppRoutes.spareHomeStoreAllSellers);

  void _openCouponBox() => context.push(AppRoutes.spareHomeStoreCouponBox);

  void _openOrders() => context.push(AppRoutes.spareHomeStoreMy);

  void _openRecentlyViewed() =>
      context.push(AppRoutes.spareHomeStoreRecentlyViewed);

  void _openSellerFromCard(StoreSeller seller) {
    context.push(AppRoutes.spareHomeStoreForSeller(seller.id));
  }
```

`build`의 `CustomScrollView` `slivers` 리스트에서, 배너/카테고리/필터칩 `SliverToBoxAdapter`(Task 7에서 셀러 필터 칩을 넣은 바로 그 블록) **뒤**, 기존 `if (_bestSellers.isNotEmpty) ...` 블록 **앞**에 다음 3개 섹션을 삽입:

```dart
                  if (_sellerFilter == null && _sellerSummaries.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: _SectionHeader(
                        title: '인기 스토어',
                        trailing: TextButton(
                          onPressed: _openAllSellers,
                          child: const Text('더보기 ›'),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 168,
                        child: Consumer<StoreSellerFollowProvider>(
                          builder: (context, follow, _) {
                            return ListView.separated(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppTheme.spacing4,
                              ),
                              itemCount: _sellerSummaries.take(6).length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: AppTheme.spacing3),
                              itemBuilder: (context, index) {
                                final summary = _sellerSummaries[index];
                                final sellerId = summary.seller.id;
                                return StoreSellerCard(
                                  summary: summary,
                                  isFollowing: follow.isFollowing(sellerId),
                                  followerCount: follow.followerCount(
                                    sellerId,
                                  ),
                                  onTap: () =>
                                      _openSellerFromCard(summary.seller),
                                  onFollowToggle: () => follow.toggle(
                                    sellerId,
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: AppTheme.spacing2),
                    ),
                  ],
                  if (_sellerFilter == null) ...[
                    SliverToBoxAdapter(child: _SectionHeader(title: '바로가기')),
                    SliverToBoxAdapter(
                      child: Consumer<CartProvider>(
                        builder: (context, cart, _) {
                          return Consumer<StoreWishlistProvider>(
                            builder: (context, wishlist, _) {
                              return StoreFeatureShortcuts(
                                cartCount: cart.totalCount,
                                wishlistCount: wishlist.count,
                                onCart: _openCart,
                                onWishlist: _openWishlist,
                                onOrders: _openOrders,
                                onAllSellers: _openAllSellers,
                                onCouponBox: _openCouponBox,
                                onRecentlyViewed: _openRecentlyViewed,
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: AppTheme.spacing2),
                    ),
                  ],
```

기존 `if (_bestSellers.isNotEmpty) ...` 블록 **바로 뒤**(전체 상품 그리드의 `_SectionHeader` **앞**)에 추가:

```dart
                  if (_sellerFilter == null &&
                      _featuredSellerProducts.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: _SectionHeader(title: '지금 뜨는 스토어의 상품'),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 248,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacing4,
                          ),
                          itemCount: _featuredSellerProducts.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: AppTheme.spacing3),
                          itemBuilder: (context, index) {
                            final product = _featuredSellerProducts[index];
                            return SizedBox(
                              width: 156,
                              child: Consumer<StoreWishlistProvider>(
                                builder: (context, wishlist, _) {
                                  return StoreProductCard(
                                    product: product,
                                    onTap: () => _openProductDetail(product),
                                    isWishlisted: wishlist.isWishlisted(
                                      product.id,
                                    ),
                                    onWishlistToggle: () =>
                                        wishlist.toggle(product),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
```

마지막으로 `_SectionHeader`가 선택적 `trailing`을 받도록 확장:

```dart
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacing4,
        AppTheme.spacing2,
        AppTheme.spacing4,
        AppTheme.spacing3,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w800,
          color: HairSpareColors.textPrimary,
        ),
      ),
    );
  }
}
```

다음으로 교체:

```dart
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacing4,
        AppTheme.spacing2,
        AppTheme.spacing2,
        AppTheme.spacing3,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: HairSpareColors.textPrimary,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/store_screen_home_sections_test.dart`
Expected: PASS

- [ ] **Step 5: 전체 리그레션 확인**

Run: `flutter test test/store_screen_seller_filter_test.dart test/store_screen_home_sections_test.dart`
Expected: 둘 다 PASS (Task 7에서 만든 필터 기능이 새 섹션들과 함께도 정상 동작하는지 확인)

Run: `flutter analyze`
Expected: 0 error

- [ ] **Step 6: Commit**

```bash
git add lib/screens/spare/store_screen.dart test/store_screen_home_sections_test.dart
git commit -m "feat: 스토어 홈에 인기 스토어·바로가기·지금 뜨는 스토어의 상품 섹션 통합"
```

---

## Task 15: 에뮬레이터 수동 QA

**Files:** 없음 (수동 검증)

- [ ] **Step 1: 전체 테스트 스위트 실행**

Run: `flutter test`
Expected: 모든 테스트 PASS (기존 26개 + 이번에 추가한 테스트 전부)

- [ ] **Step 2: 정적 분석**

Run: `flutter analyze`
Expected: 0 error, 0 warning (경고가 있다면 원인 확인 후 정리)

- [ ] **Step 3: 에뮬레이터 실행**

Run: `flutter run` (또는 이미 부팅된 iOS Simulator/Pixel 8 에뮬레이터 대상)

- [ ] **Step 4: 수동 체크리스트**

- [ ] 스토어 홈 진입 → 검색바 → 배너 → **인기 스토어**(가로 스크롤, 통계·팔로우 버튼) → 카테고리(소프트 배지) → **바로가기**(6칸) → 정렬칩 → **지금 뜨는 스토어의 상품** → 살롱 베스트 → 전체 상품, 순서대로 렌더링되는지 확인
- [ ] 인기 스토어 카드의 "+ 팔로우" 탭 → "팔로잉"으로 바뀌고 팔로워수 +1, 다시 탭하면 원복되는지 확인
- [ ] 인기 스토어 카드(팔로우 버튼 제외 영역) 탭 → 해당 셀러 상품만 보이는 필터 뷰로 이동, 상단에 "OOO 스토어 상품만 보는 중 · 전체보기" 칩 노출 확인
- [ ] 필터 뷰에서 "전체보기" 탭 → 인기 스토어·바로가기·지금 뜨는 스토어의 상품 섹션이 다시 나타나는지 확인
- [ ] 바로가기 "전체 스토어" 탭 → 승인된 셀러 전체 목록(대기중인 "봄이네뷰티"는 제외) 확인, 목록에서도 팔로우 토글 가능한지 확인
- [ ] 바로가기 "쿠폰함" 탭 → 쿠폰 3종 노출, "받기" 탭 시 "받음"으로 바뀌는지 확인
- [ ] 상품 상세 2~3개 순서대로 열람 후 바로가기 "최근 본 상품" 탭 → 열람 역순(최신이 먼저)으로 그리드에 노출되는지 확인
- [ ] 바로가기 "주문내역" 탭 → 기존 "스토어 마이" 화면으로 이동하는지 확인
- [ ] iOS/Android 양쪽에서 뒤로가기 동작, SafeArea 여백 확인

- [ ] **Step 5: 발견된 문제 기록**

체크리스트에서 문제가 발견되면 이 태스크를 완료 처리하지 말고, 문제를 새 태스크로 분리해 수정 후 다시 QA한다.
