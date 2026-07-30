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
