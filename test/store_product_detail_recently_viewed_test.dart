import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hairspare/core/di/service_locator.dart';
import 'package:hairspare/providers/cart_provider.dart';
import 'package:hairspare/providers/chat_provider.dart';
import 'package:hairspare/providers/notification_provider.dart';
import 'package:hairspare/providers/recently_viewed_store_provider.dart';
import 'package:hairspare/providers/store_wishlist_provider.dart';
import 'package:hairspare/screens/spare/store_product_detail_screen.dart';
import 'package:hairspare/utils/api_client.dart';
import 'package:intl/date_symbol_data_local.dart';
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
    await initializeDateFormatting('ko_KR');
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
          ChangeNotifierProvider<ChatProvider>.value(
            value: sl<ChatProvider>(),
          ),
          ChangeNotifierProvider<NotificationProvider>.value(
            value: sl<NotificationProvider>(),
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
