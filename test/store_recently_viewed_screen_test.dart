import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hairspare/core/di/service_locator.dart';
import 'package:hairspare/providers/recently_viewed_store_provider.dart';
import 'package:hairspare/providers/store_wishlist_provider.dart';
import 'package:hairspare/screens/spare/store_recently_viewed_screen.dart';
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

  testWidgets('기록이 없으면 빈 상태 문구를 보여준다', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<StoreWishlistProvider>.value(
            value: sl<StoreWishlistProvider>(),
          ),
          ChangeNotifierProvider<RecentlyViewedStoreProvider>.value(
            value: sl<RecentlyViewedStoreProvider>(),
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
          ChangeNotifierProvider<RecentlyViewedStoreProvider>.value(
            value: sl<RecentlyViewedStoreProvider>(),
          ),
        ],
        child: const MaterialApp(home: StoreRecentlyViewedScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('프로 커팅 가위 6인치'), findsOneWidget);
  });

  testWidgets('위젯을 재생성하지 않아도 목록 변경이 반영된다', (tester) async {
    sl<RecentlyViewedStoreProvider>().recordView('store-scissors-1');

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<StoreWishlistProvider>.value(
            value: sl<StoreWishlistProvider>(),
          ),
          ChangeNotifierProvider<RecentlyViewedStoreProvider>.value(
            value: sl<RecentlyViewedStoreProvider>(),
          ),
        ],
        child: const MaterialApp(home: StoreRecentlyViewedScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('프로 커팅 가위 6인치'), findsOneWidget);

    // 위젯을 재생성하지 않고, 다른 상품을 조회해 provider 상태만 변경한다.
    sl<RecentlyViewedStoreProvider>().recordView('store-scissors-2');
    // provider의 notifyListeners()로 위젯이 다시 build되며 재조회가
    // addPostFrameCallback으로 예약된다. 이때는 로딩 스피너 애니메이션이 없어
    // pumpAndSettle이 추가 프레임을 기다리지 않고 바로 끝나버리므로, 각 상품
    // 조회(StoreService의 200ms 지연)가 끝날 때까지 시간을 명시적으로 흘려보낸다.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('프로 커팅 가위 6인치'), findsOneWidget);
    expect(find.text('틴닝 가위 (숱가위) 30단'), findsOneWidget);
    expect(find.byType(StoreProductCard), findsNWidgets(2));
  });
}
