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

    expect(find.textContaining('스토어 상품만 보는 중'), findsOneWidget);

    await tester.tap(find.text('전체보기'));
    await tester.pumpAndSettle();

    expect(find.textContaining('스토어 상품만 보는 중'), findsNothing);

    // 필터 해제 시 뒤늦게 시작되는 홈 섹션(인기 스토어·지금 뜨는 스토어의 상품) 요청까지
    // 마무리해야 "타이머가 아직 살아있다" 경고 없이 테스트가 끝난다.
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();

    expect(find.text('인기 스토어'), findsOneWidget);
  });
}
