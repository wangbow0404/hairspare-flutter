# 스토어 셀러 프로필 페이지 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 셀러 카드/목록을 탭하면 단순 상품 필터가 아니라, 로고·소개글·통계·팔로우 버튼과 "상품"/"리뷰" 탭을 가진 진짜 스토어 프로필 페이지(`StoreSellerProfileScreen`)로 이동하게 만든다.

**Architecture:** 기존 `StoreSeller` 모델에 소개글 필드를 추가하고, 기존 `StoreService.getProductsBySeller()`를 재사용해 셀러 리뷰를 집계하는 서비스 메서드를 새로 추가한다. 새 화면은 기존 서브페이지 패턴(`SpareSubpageAppBar`)과 기존 위젯(`StoreProductCard`, `StoreSellerFollowProvider`)을 그대로 재사용한다. 기존 `StoreScreen(sellerId: ...)` 필터 뷰와 `spareHomeStoreForSeller` 라우트는 코드·테스트 그대로 유지하되(삭제하지 않음), 카드/목록의 탭 핸들러만 새 라우트로 바꾼다. 백엔드 없음 — 전부 mock 데이터.

**Tech Stack:** Flutter, `provider` (ChangeNotifier), `go_router`, 기존 `hairspare` 패키지 구조.

## Global Constraints

- 패키지명은 `hairspare` — 테스트 import는 `package:hairspare/...` 사용.
- 색상·간격은 반드시 `HairSpareColors`/`AppTheme`의 기존 토큰만 사용 (임의 하드코딩 색상 금지).
- 신규 서브페이지 AppBar는 `SpareSubpageAppBar(title: ..., showToolbarActions: false)` 패턴을 따른다.
- 위젯 테스트에서 `ApiClient().init(...)`은 반드시 `setUp(() async { ... await ApiClient().init(...); configureDependencies(); })` 형태로 await할 것 (unawaited init은 LateInitializationError/hang을 유발하는 known bug — 이 코드베이스 전체에서 이미 수정된 패턴을 따를 것).
- 기존 `StoreScreen`의 `sellerId` 쿼리파라미터 필터 기능과 `AppRoutes.spareHomeStoreForSeller`, 관련 테스트(`test/store_screen_seller_filter_test.dart`)는 이번 계획에서 **삭제하지 않는다** — 그대로 둔다.
- `flutter analyze`는 항상 0 error를 유지해야 한다.

---

## Task 1: `StoreSeller.introText` 필드 + mock 소개글 채우기

**Files:**
- Modify: `lib/models/store_seller.dart`
- Modify: `lib/services/store_seller_service.dart`
- Test: `test/store_seller_intro_text_test.dart`

**Interfaces:**
- Produces: `StoreSeller.introText` (`String?`)

- [ ] **Step 1: Write the failing test**

```dart
// test/store_seller_intro_text_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:hairspare/models/store_seller.dart';
import 'package:hairspare/services/store_seller_service.dart';

void main() {
  test('mock 셀러 전원이 소개글(introText)을 가지고 있다', () async {
    final service = StoreSellerService();
    final sellers = await service.getSellers();

    expect(sellers, isNotEmpty);
    for (final seller in sellers) {
      expect(
        seller.introText,
        isNotNull,
        reason: '${seller.shopName}에 introText가 없습니다',
      );
      expect(seller.introText, isNotEmpty);
    }
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/store_seller_intro_text_test.dart`
Expected: FAIL — `introText` getter가 없어 컴파일 에러.

- [ ] **Step 3: `StoreSeller`에 필드 추가**

`lib/models/store_seller.dart`의 `StoreSeller` 클래스를:

```dart
class StoreSeller {
  const StoreSeller({
    required this.id,
    required this.shopName,
    required this.ownerName,
    required this.status,
    required this.appliedAt,
    this.businessNumber,
    this.approvedAt,
    this.rejectReason,
    this.logoUrl,
  });

  final String id;
  final String shopName;
  final String ownerName;
  final StoreSellerStatus status;
  final DateTime appliedAt;
  final String? businessNumber;
  final DateTime? approvedAt;
  final String? rejectReason;
  final String? logoUrl;

  bool get isApproved => status == StoreSellerStatus.approved;
}
```

다음으로 교체 (`introText` 필드 추가):

```dart
class StoreSeller {
  const StoreSeller({
    required this.id,
    required this.shopName,
    required this.ownerName,
    required this.status,
    required this.appliedAt,
    this.businessNumber,
    this.approvedAt,
    this.rejectReason,
    this.logoUrl,
    this.introText,
  });

  final String id;
  final String shopName;
  final String ownerName;
  final StoreSellerStatus status;
  final DateTime appliedAt;
  final String? businessNumber;
  final DateTime? approvedAt;
  final String? rejectReason;
  final String? logoUrl;

  /// 스토어 프로필 페이지 상단에 노출되는 한 줄 소개글.
  final String? introText;

  bool get isApproved => status == StoreSellerStatus.approved;
}
```

- [ ] **Step 4: mock 데이터에 소개글 채우기**

`lib/services/store_seller_service.dart`의 mock 셀러 목록(생성자 리스트) 7개 항목 각각에 `introText:` 라인을 추가한다. 아래는 각 셀러 id에 맞춰 넣을 정확한 문구다 — 기존 필드(`id`, `shopName` 등)는 그대로 두고 `introText`만 추가:

- `seller-hairspare-official` → `introText: 'HairSpare가 직접 검수한 프로 시술 도구만 모았습니다.'`
- `seller-junscissors` → `introText: '20년 경력 헤어디자이너가 고른 가위 전문 셀렉샵입니다.'`
- `seller-herzen` → `introText: '살롱 전용 뷰티 서플라이 — 대용량·업소용 특가로 만나보세요.'`
- `seller-curlstar` → `introText: '펌·컬 전문 도구 브랜드, 컬리스타의 공식 스토어입니다.'`
- `seller-keracis` → `introText: '손상모 케어 전문 케라시스 프로 라인을 소개합니다.'`
- `seller-colorlab` → `introText: '저자극 컬러·케미컬 전문 연구소, 컬러랩입니다.'`
- `seller-bomne` → `introText: '합리적인 가격의 헤어 소모품을 준비 중입니다.'`

예를 들어 `seller-hairspare-official` 항목은:

```dart
    StoreSeller(
      id: 'seller-hairspare-official',
      shopName: 'HairSpare 공식스토어',
      ownerName: 'HairSpare',
      status: StoreSellerStatus.approved,
      appliedAt: DateTime(2026, 1, 5),
      approvedAt: DateTime(2026, 1, 6),
    ),
```

다음으로 교체:

```dart
    StoreSeller(
      id: 'seller-hairspare-official',
      shopName: 'HairSpare 공식스토어',
      ownerName: 'HairSpare',
      status: StoreSellerStatus.approved,
      appliedAt: DateTime(2026, 1, 5),
      approvedAt: DateTime(2026, 1, 6),
      introText: 'HairSpare가 직접 검수한 프로 시술 도구만 모았습니다.',
    ),
```

나머지 6개 셀러도 동일하게 각자의 `appliedAt`/`approvedAt` 줄 바로 아래에 위 목록의 `introText` 값을 추가한다 (`seller-bomne`는 `approvedAt`이 없으므로 `appliedAt` 줄 아래에 추가).

- [ ] **Step 5: Run test to verify it passes**

Run: `flutter test test/store_seller_intro_text_test.dart`
Expected: PASS

- [ ] **Step 6: Commit**

```bash
git add lib/models/store_seller.dart lib/services/store_seller_service.dart test/store_seller_intro_text_test.dart
git commit -m "feat: 스토어 셀러 소개글(introText) 필드 추가"
```

---

## Task 2: `StoreSellerService.getSellerReviews()` — 셀러 리뷰 집계

**Files:**
- Modify: `lib/models/store_seller.dart`
- Modify: `lib/services/store_seller_service.dart`
- Test: `test/store_seller_reviews_test.dart`

**Interfaces:**
- Consumes: `StoreService.getProductsBySeller(String sellerId)` (기존)
- Produces: `class StoreSellerReviewEntry { final String productId; final String productName; final StoreProductReview review; }`, `Future<List<StoreSellerReviewEntry>> StoreSellerService.getSellerReviews(String sellerId)` — 이 셀러의 모든 상품 리뷰를 최신순으로 반환.

- [ ] **Step 1: Write the failing test**

```dart
// test/store_seller_reviews_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:hairspare/services/store_seller_service.dart';

void main() {
  group('StoreSellerService.getSellerReviews', () {
    test('셀러의 여러 상품 리뷰를 모아 최신순으로 반환한다', () async {
      final service = StoreSellerService();

      // seller-hairspare-official은 여러 상품에 리뷰가 달려있다 (mock 데이터 기준).
      final entries = await service.getSellerReviews(
        'seller-hairspare-official',
      );

      expect(entries, isNotEmpty);
      for (var i = 0; i < entries.length - 1; i++) {
        expect(
          entries[i].review.createdAt.isAfter(
                entries[i + 1].review.createdAt,
              ) ||
              entries[i].review.createdAt.isAtSameMomentAs(
                entries[i + 1].review.createdAt,
              ),
          isTrue,
          reason: '리뷰가 최신순으로 정렬되지 않았습니다',
        );
      }
      for (final entry in entries) {
        expect(entry.productName, isNotEmpty);
      }
    });

    test('리뷰가 없는 셀러는 빈 리스트를 반환한다', () async {
      final service = StoreSellerService();

      final entries = await service.getSellerReviews('seller-bomne');

      expect(entries, isEmpty);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/store_seller_reviews_test.dart`
Expected: FAIL — `getSellerReviews` 메서드가 없어 컴파일 에러.

- [ ] **Step 3: `StoreSellerReviewEntry` 모델 추가**

`lib/models/store_seller.dart` 맨 끝에 추가 (파일 상단에 `import 'store_product.dart';` 이미 있는지 확인하고 없으면 추가):

```dart
import 'store_product.dart';
```

(이미 이 import가 파일에 있다면 중복 추가하지 말 것 — 파일 상단 import 목록을 먼저 확인.)

파일 맨 끝에 추가:

```dart
/// 셀러 리뷰 탭용 — 리뷰 1건 + 그 리뷰가 달린 상품 정보.
class StoreSellerReviewEntry {
  const StoreSellerReviewEntry({
    required this.productId,
    required this.productName,
    required this.review,
  });

  final String productId;
  final String productName;
  final StoreProductReview review;
}
```

- [ ] **Step 4: `StoreSellerService.getSellerReviews()` 구현**

`lib/services/store_seller_service.dart` 상단 import에 추가 (없으면):

```dart
import '../core/di/service_locator.dart';
import 'store_service.dart';
```

(이미 있는 import와 중복되지 않게 확인 후 추가.)

클래스 내부 마지막 메서드(`getSellerSummaries`) 뒤에 추가:

```dart
  /// [sellerId]의 모든 상품에 달린 리뷰를 최신순으로 모아 반환 — 스토어 프로필
  /// 페이지 "리뷰" 탭용.
  Future<List<StoreSellerReviewEntry>> getSellerReviews(
    String sellerId,
  ) async {
    final products = await sl<StoreService>().getProductsBySeller(sellerId);
    final entries = <StoreSellerReviewEntry>[
      for (final product in products)
        for (final review in product.reviews)
          StoreSellerReviewEntry(
            productId: product.id,
            productName: product.name,
            review: review,
          ),
    ];
    entries.sort((a, b) => b.review.createdAt.compareTo(a.review.createdAt));
    return entries;
  }
```

- [ ] **Step 5: Run test to verify it passes**

Run: `flutter test test/store_seller_reviews_test.dart`
Expected: PASS

- [ ] **Step 6: Commit**

```bash
git add lib/models/store_seller.dart lib/services/store_seller_service.dart test/store_seller_reviews_test.dart
git commit -m "feat: 셀러 리뷰 집계 API 추가 (getSellerReviews)"
```

---

## Task 3: 라우트 상수 + 등록

**Files:**
- Modify: `lib/core/router/app_routes.dart`
- Modify: `lib/core/router/shared_leaf_routes.dart`

**Interfaces:**
- Produces: `AppRoutes.spareHomeStoreSellerProfile(String sellerId) -> String`

- [ ] **Step 1: `app_routes.dart`에 헬퍼 추가**

`spareHomeStoreForSeller` 헬퍼 선언 바로 아래에 추가:

```dart
  static String spareHomeStoreSellerProfile(String sellerId) =>
      '/spare/home/store_seller_profile?sellerId=$sellerId';
```

- [ ] **Step 2: `shared_leaf_routes.dart`에 GoRoute 등록**

파일 상단 import에 추가:

```dart
import '../../screens/spare/store_seller_profile_screen.dart';
```

기존 `store_recently_viewed` `GoRoute` 뒤에 추가:

```dart
    GoRoute(
      path: 'store_seller_profile',
      builder: (_, state) {
        final sellerId = state.uri.queryParameters['sellerId'] ?? '';
        return StoreSellerProfileScreen(sellerId: sellerId);
      },
    ),
```

(`StoreSellerProfileScreen`은 Task 4에서 만든다 — 이 시점에는 아직 파일이 없어 컴파일 에러가 나는 게 정상이다. Task 4를 먼저 구현한 뒤 이 Task를 진행해도 되고, 이 Task를 먼저 커밋 없이 작성해두고 Task 4 완료 후 함께 커밋해도 된다. 아래 Step 3의 커밋은 Task 4 완료 후에 실행할 것.)

- [ ] **Step 3: Commit (Task 4 완료 후 함께)**

```bash
git add lib/core/router/app_routes.dart lib/core/router/shared_leaf_routes.dart
git commit -m "feat: 스토어 셀러 프로필 화면 라우트 추가"
```

---

## Task 4: `StoreSellerProfileScreen` — 프로필 헤더 + 상품 탭

**Files:**
- Create: `lib/screens/spare/store_seller_profile_screen.dart`
- Test: `test/store_seller_profile_screen_test.dart`

**Interfaces:**
- Consumes: `StoreSellerService.getSellerSummaries` (기존), `StoreService.getProductsBySeller` (기존), `StoreSellerFollowProvider` (기존), `StoreWishlistProvider` (기존), `StoreProductCard` (기존)
- Produces: `StoreSellerProfileScreen({required String sellerId})`

- [ ] **Step 1: Write the failing test**

```dart
// test/store_seller_profile_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hairspare/core/di/service_locator.dart';
import 'package:hairspare/providers/store_seller_follow_provider.dart';
import 'package:hairspare/providers/store_wishlist_provider.dart';
import 'package:hairspare/screens/spare/store_seller_profile_screen.dart';
import 'package:hairspare/utils/api_client.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    dotenv.testLoad(fileInput: '');
    await ApiClient().init(
      onSessionExpired: () async {},
      onSessionExpiredMessage: (_) {},
    );
    configureDependencies();
  });

  tearDown(() async {
    await sl.reset();
  });

  Future<void> pumpScreen(WidgetTester tester, String sellerId) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<StoreWishlistProvider>.value(
            value: sl<StoreWishlistProvider>(),
          ),
          ChangeNotifierProvider<StoreSellerFollowProvider>.value(
            value: sl<StoreSellerFollowProvider>(),
          ),
        ],
        child: MaterialApp(
          home: StoreSellerProfileScreen(sellerId: sellerId),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('스토어명·소개글·통계·상품 그리드가 노출된다', (tester) async {
    await pumpScreen(tester, 'seller-hairspare-official');

    expect(find.text('HairSpare 공식스토어'), findsOneWidget);
    expect(
      find.text('HairSpare가 직접 검수한 프로 시술 도구만 모았습니다.'),
      findsOneWidget,
    );
    expect(find.textContaining('상품 4'), findsOneWidget);
    expect(find.text('상품'), findsWidgets);
    expect(find.text('리뷰'), findsWidgets);
  });

  testWidgets('팔로우 버튼을 탭하면 팔로잉 상태로 바뀐다', (tester) async {
    await pumpScreen(tester, 'seller-hairspare-official');

    expect(find.text('+ 팔로우'), findsOneWidget);
    await tester.tap(find.text('+ 팔로우'));
    await tester.pump();

    expect(find.text('팔로잉'), findsOneWidget);
  });

  testWidgets('검색창에 입력하면 상품 목록이 필터링된다', (tester) async {
    await pumpScreen(tester, 'seller-hairspare-official');

    expect(find.byType(GridView), findsOneWidget);

    await tester.enterText(find.byType(TextField), '존재하지않는상품이름');
    await tester.pumpAndSettle();

    expect(find.text('검색 결과가 없습니다'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/store_seller_profile_screen_test.dart`
Expected: FAIL — 파일 없음.

- [ ] **Step 3: Write minimal implementation**

```dart
// lib/screens/spare/store_seller_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/di/service_locator.dart';
import '../../models/store_product.dart';
import '../../models/store_seller.dart';
import '../../providers/store_seller_follow_provider.dart';
import '../../providers/store_wishlist_provider.dart';
import '../../services/store_seller_service.dart';
import '../../services/store_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/hairspare_colors.dart';
import '../../widgets/common/spare_subpage_app_bar.dart';
import '../../widgets/store/store_product_card.dart';

/// 스토어 셀러 프로필 페이지 — 로고·소개글·통계·팔로우 + 상품/리뷰 탭.
/// "인기 스토어" 카드, "전체 스토어" 목록에서 진입.
class StoreSellerProfileScreen extends StatefulWidget {
  const StoreSellerProfileScreen({super.key, required this.sellerId});

  final String sellerId;

  @override
  State<StoreSellerProfileScreen> createState() =>
      _StoreSellerProfileScreenState();
}

class _StoreSellerProfileScreenState extends State<StoreSellerProfileScreen>
    with SingleTickerProviderStateMixin {
  final StoreSellerService _sellerService = sl<StoreSellerService>();
  final StoreService _storeService = sl<StoreService>();
  late final TabController _tabController;

  StoreSellerSummary? _summary;
  List<StoreProduct> _products = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final allProducts = await _storeService.getProducts();
    final summaries = await _sellerService.getSellerSummaries(allProducts);
    final sellerProducts = await _storeService.getProductsBySeller(
      widget.sellerId,
    );
    if (!mounted) return;
    final matches = summaries.where((s) => s.seller.id == widget.sellerId);
    setState(() {
      _summary = matches.isEmpty ? null : matches.first;
      _products = sellerProducts;
      _isLoading = false;
    });
  }

  List<StoreProduct> get _filteredProducts {
    if (_searchQuery.isEmpty) return _products;
    final query = _searchQuery.toLowerCase();
    return _products
        .where((p) => p.name.toLowerCase().contains(query))
        .toList();
  }

  void _openProductDetail(StoreProduct product) {
    Navigator.of(context).pushNamed('/spare/home/store/product/${product.id}');
  }

  @override
  Widget build(BuildContext context) {
    final summary = _summary;
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: SpareSubpageAppBar(
        title: summary?.seller.shopName ?? '스토어',
        showToolbarActions: false,
      ),
      body: _isLoading || summary == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _ProfileHeader(summary: summary),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing4,
                  ),
                  child: TextField(
                    onChanged: (value) =>
                        setState(() => _searchQuery = value),
                    decoration: InputDecoration(
                      hintText: '${summary.seller.shopName} 상품 검색',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: HairSpareColors.surfaceMuted,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusLg,
                        ),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacing2),
                TabBar(
                  controller: _tabController,
                  labelColor: HairSpareColors.brandPrimary,
                  unselectedLabelColor: HairSpareColors.textSecondary,
                  indicatorColor: HairSpareColors.brandPrimary,
                  tabs: const [Tab(text: '상품'), Tab(text: '리뷰')],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _ProductGrid(
                        products: _filteredProducts,
                        onTapProduct: _openProductDetail,
                      ),
                      _SellerReviewsTab(sellerId: widget.sellerId),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.summary});

  final StoreSellerSummary summary;

  @override
  Widget build(BuildContext context) {
    final seller = summary.seller;
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacing4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: HairSpareColors.brandPrimarySoft,
            child: Text(
              seller.shopName.substring(0, 1),
              style: const TextStyle(
                color: HairSpareColors.brandPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 22,
              ),
            ),
          ),
          const SizedBox(width: AppTheme.spacing3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  seller.shopName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: HairSpareColors.textPrimary,
                  ),
                ),
                if (seller.introText != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    seller.introText!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: HairSpareColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Consumer<StoreSellerFollowProvider>(
                  builder: (context, follow, _) {
                    final isFollowing = follow.isFollowing(seller.id);
                    final followerCount = follow.displayFollowerCount(
                      seller.id,
                      summary.followerCount,
                    );
                    return Row(
                      children: [
                        Expanded(
                          child: Text(
                            '상품 ${summary.productCount} · ★${summary.averageRating.toStringAsFixed(1)} · 팔로워 $followerCount',
                            style: const TextStyle(
                              fontSize: 12,
                              color: HairSpareColors.textSecondary,
                            ),
                          ),
                        ),
                        OutlinedButton(
                          onPressed: () => follow.toggle(seller.id),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: isFollowing
                                  ? HairSpareColors.border
                                  : HairSpareColors.brandPrimary,
                            ),
                            foregroundColor: isFollowing
                                ? HairSpareColors.textSecondary
                                : HairSpareColors.brandPrimary,
                          ),
                          child: Text(isFollowing ? '팔로잉' : '+ 팔로우'),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductGrid extends StatelessWidget {
  const _ProductGrid({required this.products, required this.onTapProduct});

  final List<StoreProduct> products;
  final ValueChanged<StoreProduct> onTapProduct;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const Center(child: Text('검색 결과가 없습니다'));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(AppTheme.spacing4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppTheme.spacing4,
        crossAxisSpacing: AppTheme.spacing3,
        childAspectRatio: 0.54,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Consumer<StoreWishlistProvider>(
          builder: (context, wishlist, _) {
            return StoreProductCard(
              product: product,
              onTap: () => onTapProduct(product),
              isWishlisted: wishlist.isWishlisted(product.id),
              onWishlistToggle: () => wishlist.toggle(product),
            );
          },
        );
      },
    );
  }
}

class _SellerReviewsTab extends StatelessWidget {
  const _SellerReviewsTab({required this.sellerId});

  final String sellerId;

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
```

(`_SellerReviewsTab`은 이 Task에서는 빈 위젯으로 둔다 — Task 5에서 실제 리뷰 리스트로 구현한다. `_openProductDetail`의 `pushNamed` 경로는 실제로 동작하지 않아도 이 Task의 테스트에는 영향 없다 — Task 6에서 기존 `AppRoutes.spareHomeStoreProductDetail` 헬퍼를 쓰도록 바로잡는다.)

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/store_seller_profile_screen_test.dart`
Expected: PASS

- [ ] **Step 5: Task 3의 라우트 등록과 함께 정적 분석 확인**

Run: `flutter analyze`
Expected: 0 error

- [ ] **Step 6: Commit**

```bash
git add lib/screens/spare/store_seller_profile_screen.dart lib/core/router/app_routes.dart lib/core/router/shared_leaf_routes.dart test/store_seller_profile_screen_test.dart
git commit -m "feat: 스토어 셀러 프로필 화면 추가 (프로필 헤더 + 상품 탭)"
```

---

## Task 5: 리뷰 탭 구현

**Files:**
- Modify: `lib/screens/spare/store_seller_profile_screen.dart`
- Test: `test/store_seller_profile_screen_test.dart`

**Interfaces:**
- Consumes: `StoreSellerService.getSellerReviews` (Task 2), `StoreSellerReviewEntry` (Task 2)

- [ ] **Step 1: Write the failing test**

`test/store_seller_profile_screen_test.dart` 파일 `main()` 안, 기존 테스트들 뒤에 추가:

```dart
  testWidgets('리뷰 탭을 누르면 이 셀러 상품들의 리뷰가 최신순으로 보인다', (tester) async {
    await pumpScreen(tester, 'seller-hairspare-official');

    await tester.tap(find.text('리뷰').last);
    await tester.pumpAndSettle();

    expect(find.byType(ListView), findsOneWidget);
  });
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/store_seller_profile_screen_test.dart`
Expected: FAIL — `_SellerReviewsTab`이 빈 `SizedBox`라 `ListView`가 없음.

- [ ] **Step 3: `_SellerReviewsTab` 구현**

`lib/screens/spare/store_seller_profile_screen.dart`의 `_SellerReviewsTab` 클래스 전체를:

```dart
class _SellerReviewsTab extends StatelessWidget {
  const _SellerReviewsTab({required this.sellerId});

  final String sellerId;

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
```

다음으로 교체:

```dart
class _SellerReviewsTab extends StatefulWidget {
  const _SellerReviewsTab({required this.sellerId});

  final String sellerId;

  @override
  State<_SellerReviewsTab> createState() => _SellerReviewsTabState();
}

class _SellerReviewsTabState extends State<_SellerReviewsTab> {
  final StoreSellerService _sellerService = sl<StoreSellerService>();
  List<StoreSellerReviewEntry> _entries = [];
  bool _isLoading = true;

  static final _dateFmt = DateFormat('yyyy.MM.dd');

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final entries = await _sellerService.getSellerReviews(widget.sellerId);
    if (!mounted) return;
    setState(() {
      _entries = entries;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_entries.isEmpty) {
      return const Center(child: Text('아직 등록된 리뷰가 없습니다'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppTheme.spacing4),
      itemCount: _entries.length,
      separatorBuilder: (_, __) =>
          const SizedBox(height: AppTheme.spacing3),
      itemBuilder: (context, index) {
        final entry = _entries[index];
        return Container(
          padding: const EdgeInsets.all(AppTheme.spacing3),
          decoration: BoxDecoration(
            color: HairSpareColors.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(color: HairSpareColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    entry.review.userName,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: HairSpareColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '★' * entry.review.rating,
                    style: const TextStyle(
                      fontSize: 12,
                      color: HairSpareColors.brandPrimary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _dateFmt.format(entry.review.createdAt),
                    style: const TextStyle(
                      fontSize: 11,
                      color: HairSpareColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                entry.productName,
                style: const TextStyle(
                  fontSize: 11,
                  color: HairSpareColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                entry.review.comment,
                style: const TextStyle(
                  fontSize: 13,
                  color: HairSpareColors.textStrong,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
```

파일 상단 import에 추가 (없으면):

```dart
import 'package:intl/intl.dart';
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/store_seller_profile_screen_test.dart`
Expected: PASS (전체 4개 테스트)

- [ ] **Step 5: Commit**

```bash
git add lib/screens/spare/store_seller_profile_screen.dart test/store_seller_profile_screen_test.dart
git commit -m "feat: 스토어 셀러 프로필 화면 리뷰 탭 구현"
```

---

## Task 6: 네비게이션 연결 (인기 스토어 카드 · 전체 스토어 목록)

**Files:**
- Modify: `lib/screens/spare/store_screen.dart`
- Modify: `lib/screens/spare/store_all_sellers_screen.dart`
- Modify: `lib/screens/spare/store_seller_profile_screen.dart` (상품 상세 이동 경로 수정)
- Test: `test/store_home_routing_test.dart` (new test added), `test/store_screen_home_sections_test.dart` / `test/store_all_sellers_screen_test.dart` (regression check only, not modified)

**Interfaces:**
- Consumes: `AppRoutes.spareHomeStoreSellerProfile` (Task 3)

- [ ] **Step 1: `store_seller_profile_screen.dart`의 상품 상세 이동 경로 바로잡기**

파일 상단 import에 추가:

```dart
import '../../core/router/app_routes.dart';
```

(이미 있다면 중복 추가하지 말 것.)

`_openProductDetail` 메서드를:

```dart
  void _openProductDetail(StoreProduct product) {
    Navigator.of(context).pushNamed('/spare/home/store/product/${product.id}');
  }
```

다음으로 교체:

```dart
  void _openProductDetail(StoreProduct product) {
    context.push(AppRoutes.spareHomeStoreProductDetail(product.id));
  }
```

`package:go_router/go_router.dart` import가 파일 상단에 없다면 추가:

```dart
import 'package:go_router/go_router.dart';
```

- [ ] **Step 2: Write the failing test — 인기 스토어 카드 탭 시 프로필 화면으로 이동**

`StoreScreen`을 단독으로 렌더링하는 기존 위젯 테스트로는 실제 라우트 이동(push)을 검증할 수 없다 (go_router가 없으면 `context.push`가 예외를 던진다) — 그러므로 이 동작은 실제 앱 라우터를 빌드하는 `test/store_home_routing_test.dart`에서만 검증한다. `test/store_screen_home_sections_test.dart`는 이번 Task에서 수정하지 않는다.

`test/store_home_routing_test.dart`를 열어 기존 테스트들이 있는 `main()` 안에 아래를 추가:

```dart
  testWidgets('인기 스토어 카드를 탭하면 스토어 프로필 화면으로 이동한다', (tester) async {
    final auth = sl<AuthProvider>();
    await auth.setUser(MockAuthData.spareUser());
    final router = AppRouter.createRouter(auth);
    registerGoRouter(router);
    router.go(AppRoutes.spareHomeStore);

    await tester.pumpWidget(MyApp(router: router));
    await tester.pumpAndSettle();

    await tester.tap(find.text('HairSpare 공식스...').first);
    await tester.pumpAndSettle();

    expect(find.text('상품'), findsWidgets);
    expect(find.text('리뷰'), findsWidgets);
  });
```

(이미 파일에 있는 import들 — `AuthProvider`, `MockAuthData`, `AppRouter`, `registerGoRouter`, `MyApp`, `AppRoutes` — 을 그대로 사용한다. 없는 import가 있다면 파일 상단에 추가한다.)

- [ ] **Step 3: Run test to verify it fails**

Run: `flutter test test/store_home_routing_test.dart`
Expected: FAIL — 카드 탭 시 아직 필터 뷰(`_sellerFilter`)로만 바뀌고 "상품"/"리뷰" 탭 텍스트가 없음.

- [ ] **Step 4: `store_screen.dart`의 `_openSellerFromCard` 수정**

`_openSellerFromCard` 메서드 (현재 `setState`로 `_sellerFilter`를 바꾸는 형태)를 찾아:

```dart
  void _openSellerFromCard(StoreSeller seller) {
```

로 시작하는 메서드 전체를, 아래로 교체한다 (본문만 교체 — 메서드 시그니처는 동일하게 유지):

```dart
  void _openSellerFromCard(StoreSeller seller) {
    context.push(AppRoutes.spareHomeStoreSellerProfile(seller.id));
  }
```

(주의: 이 메서드가 기존에 `setState(() => _sellerFilter = seller.id)`와 `_loadProducts()` 등을 호출하던 로직을 전부 지우고, 위 한 줄로 교체하는 것이다. `_sellerFilter`/`_clearSellerFilter`/`_loadHomeSections` 등 다른 메서드는 전혀 건드리지 않는다 — 오직 `_openSellerFromCard`의 본문만 바꾼다.)

- [ ] **Step 5: `store_all_sellers_screen.dart`의 `_openSellerProducts` 수정**

```dart
  void _openSellerProducts(StoreSeller seller) {
    context.push(AppRoutes.spareHomeStoreForSeller(seller.id));
  }
```

다음으로 교체:

```dart
  void _openSellerProducts(StoreSeller seller) {
    context.push(AppRoutes.spareHomeStoreSellerProfile(seller.id));
  }
```

- [ ] **Step 6: Run tests to verify they pass**

Run: `flutter test test/store_home_routing_test.dart test/store_screen_home_sections_test.dart test/store_all_sellers_screen_test.dart`
Expected: 전부 PASS. `test/store_all_sellers_screen_test.dart`는 현재 셀러 행을 탭했을 때의 실제 라우팅(어느 경로로 이동하는지)을 검증하지 않는다 (그리드/팔로우 텍스트만 검증) — 그러므로 `_openSellerProducts` 수정만으로 이 파일의 테스트는 수정 없이 그대로 통과해야 한다. 만약 실행 결과 실패한다면, 실패 메시지를 그대로 읽고 원인을 파악할 것 — 이 계획에서 예상하지 못한 회귀일 수 있다.

- [ ] **Step 7: 전체 리그레션 확인**

Run: `flutter test`
Expected: 기존 통과 개수 + 이번에 추가한 테스트 전부 PASS (기존 `model_route_redirect_test.dart`의 2개 실패는 이 계획과 무관한 pre-existing 이슈이므로 그대로 남아있어도 된다).

Run: `flutter analyze`
Expected: 0 error

- [ ] **Step 8: Commit**

```bash
git add lib/screens/spare/store_screen.dart lib/screens/spare/store_all_sellers_screen.dart lib/screens/spare/store_seller_profile_screen.dart test/store_home_routing_test.dart
git commit -m "feat: 인기 스토어 카드·전체 스토어 목록을 스토어 프로필 화면으로 연결"
```

---
