import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hairspare/core/di/service_locator.dart';
import 'package:hairspare/providers/chat_provider.dart';
import 'package:hairspare/providers/notification_provider.dart';
import 'package:hairspare/providers/store_seller_follow_provider.dart';
import 'package:hairspare/screens/spare/store_all_sellers_screen.dart';
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

  testWidgets('승인된 셀러 목록을 보여준다', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<StoreSellerFollowProvider>.value(
            value: sl<StoreSellerFollowProvider>(),
          ),
          ChangeNotifierProvider<ChatProvider>.value(
            value: sl<ChatProvider>(),
          ),
          ChangeNotifierProvider<NotificationProvider>.value(
            value: sl<NotificationProvider>(),
          ),
        ],
        child: const MaterialApp(home: StoreAllSellersScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('준가위 공구몰'), findsOneWidget);
    expect(find.text('봄이네뷰티'), findsNothing); // pending 셀러는 제외
    // 팔로워수는 Provider가 아니라 셀러 요약(StoreSellerSummary.followerCount)에서 온다.
    expect(find.text('상품 2 · 팔로워 216'), findsOneWidget); // 준가위 공구몰
    expect(find.text('상품 4 · 팔로워 482'), findsOneWidget); // HairSpare 공식스토어
  });

  testWidgets('팔로우 버튼을 탭하면 상태가 바뀐다', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<StoreSellerFollowProvider>.value(
            value: sl<StoreSellerFollowProvider>(),
          ),
          ChangeNotifierProvider<ChatProvider>.value(
            value: sl<ChatProvider>(),
          ),
          ChangeNotifierProvider<NotificationProvider>.value(
            value: sl<NotificationProvider>(),
          ),
        ],
        child: const MaterialApp(home: StoreAllSellersScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // 첫 행은 평점 1위인 HairSpare 공식스토어(기준 팔로워 482명).
    expect(find.text('상품 4 · 팔로워 482'), findsOneWidget);

    await tester.tap(find.text('+ 팔로우').first);
    await tester.pump();

    expect(find.text('팔로잉'), findsOneWidget);
    // 내가 누른 팔로우는 로컬 delta로만 더해진다.
    expect(find.text('상품 4 · 팔로워 483'), findsOneWidget);
    expect(find.text('상품 4 · 팔로워 482'), findsNothing);
  });
}
