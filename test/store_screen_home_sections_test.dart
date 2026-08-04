import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hairspare/core/di/service_locator.dart';
import 'package:hairspare/providers/cart_provider.dart';
import 'package:hairspare/providers/store_seller_follow_provider.dart';
import 'package:hairspare/providers/store_wishlist_provider.dart';
import 'package:hairspare/screens/spare/store_screen.dart';
import 'package:hairspare/utils/api_client.dart';
import 'package:hairspare/widgets/store/store_product_card.dart';
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

  /// "인기 스토어"·"지금 뜨는 스토어의 상품"은 카테고리·정렬 칩과 무관해서 상품 목록과
  /// 분리된 별도 요청으로(조금 늦게) 채워진다. 상품 목록이 그려지면 스켈레톤 애니메이션이
  /// 멈춰 pumpAndSettle이 먼저 끝나므로, mock 지연만큼 프레임을 더 진행해준다.
  Future<void> settleStoreHome(WidgetTester tester) async {
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();
  }

  testWidgets('필터가 없을 때 인기 스토어·바로가기·지금 뜨는 스토어의 상품 섹션이 보인다', (
    tester,
  ) async {
    // 신규 섹션(인기 스토어·바로가기·살롱 베스트·지금 뜨는 스토어의 상품)이 모두 CustomScrollView의
    // "onstage" 범위(뷰포트+캐시 익스텐트) 안에 들어오도록 충분히 큰 높이를 사용한다.
    // (뷰포트 밖 sliver 자식은 find.text()의 기본 skipOffstage:true에 의해 걸러짐)
    tester.view.physicalSize = const Size(390, 2600);
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
    await settleStoreHome(tester);

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

  testWidgets('살롱 베스트와 지금 뜨는 스토어의 상품은 같은 상품을 노출하지 않는다', (tester) async {
    // 두 레일의 아이템이 모두 빌드되도록 가로로 넉넉한 뷰포트를 쓴다.
    tester.view.physicalSize = const Size(1400, 2600);
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
    await settleStoreHome(tester);

    Set<String> railProductIds(Key railKey) {
      return tester
          .widgetList<StoreProductCard>(
            find.descendant(
              of: find.byKey(railKey),
              matching: find.byType(StoreProductCard),
              skipOffstage: false,
            ),
          )
          .map((card) => card.product.id)
          .toSet();
    }

    final bestSellerIds = railProductIds(StoreScreen.bestSellerRailKey);
    final featuredIds = railProductIds(StoreScreen.featuredSellerRailKey);

    expect(bestSellerIds, isNotEmpty);
    expect(featuredIds, isNotEmpty);
    expect(
      bestSellerIds.intersection(featuredIds),
      isEmpty,
      reason: '두 레일이 같은 상품을 중복 노출하면 안 된다',
    );
  });
}
