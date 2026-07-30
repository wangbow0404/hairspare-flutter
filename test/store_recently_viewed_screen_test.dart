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
