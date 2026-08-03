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

    expect(find.text('HairSpare 공식스토어'), findsNWidgets(2));
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
