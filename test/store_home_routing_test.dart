import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hairspare/core/di/service_locator.dart';
import 'package:hairspare/core/router/app_router.dart';
import 'package:hairspare/core/router/app_routes.dart';
import 'package:hairspare/main.dart';
import 'package:hairspare/mocks/mock_auth_data.dart';
import 'package:hairspare/providers/auth_provider.dart';
import 'package:hairspare/screens/spare/store_all_sellers_screen.dart';
import 'package:hairspare/screens/spare/store_coupon_box_screen.dart';
import 'package:hairspare/screens/spare/store_recently_viewed_screen.dart';
import 'package:hairspare/screens/spare/store_screen.dart';
import 'package:hairspare/utils/api_client.dart';

/// 스토어 홈에서 새로 추가된 4개 경로(전체 스토어·쿠폰함·최근 본 상품·셀러 필터)가
/// 실제 라우터(AppRouter.createRouter)에 제대로 물려 있는지 검증한다.
/// 경로 상수에 오타가 나면 GoRouter가 "no routes for location"으로 실패한다.
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

  testWidgets('스토어 홈의 신규 경로 4개가 라우터에 연결되어 있다', (tester) async {
    tester.view.physicalSize = const Size(390, 2200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    // 배너 자동스크롤 타이머 때문에 pumpAndSettle이 끝나지 않을 수 있어
    // 고정 프레임을 충분히(mock 지연 300~600ms) 진행한다.
    Future<void> settle() async {
      await tester.pump();
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 300));
      }
    }

    final auth = sl<AuthProvider>();
    await auth.setUser(MockAuthData.spareUser());
    final router = AppRouter.createRouter(auth);
    // 스페어 홈 화면이 sl<GoRouter>()를 쓰므로 앱 시작 시와 동일하게 등록해준다.
    registerGoRouter(router);
    await tester.pumpWidget(MyApp(router: router));
    await settle();

    router.go(AppRoutes.spareHomeStore);
    await settle();
    expect(find.byType(StoreScreen), findsOneWidget);

    // 1) 전체 스토어 — 홈 "인기 스토어" 더보기 버튼(실제 UI 경로)으로 이동.
    await tester.tap(find.text('더보기 ›').first);
    await settle();
    expect(find.byType(StoreAllSellersScreen), findsOneWidget);
    expect(find.text('준가위 공구몰'), findsOneWidget);

    router.pop();
    await settle();
    expect(find.byType(StoreAllSellersScreen), findsNothing);

    // 2) 쿠폰함
    router.push(AppRoutes.spareHomeStoreCouponBox);
    await settle();
    expect(find.byType(StoreCouponBoxScreen), findsOneWidget);
    expect(find.text('쿠폰함'), findsWidgets);

    router.pop();
    await settle();

    // 3) 최근 본 상품
    router.push(AppRoutes.spareHomeStoreRecentlyViewed);
    await settle();
    expect(find.byType(StoreRecentlyViewedScreen), findsOneWidget);
    expect(find.text('최근 본 상품'), findsWidgets);

    router.pop();
    await settle();

    // 4) 셀러 필터 — sellerId 쿼리 파라미터가 StoreScreen까지 전달되는지.
    router.push(
      AppRoutes.spareHomeStoreForSeller('seller-hairspare-official'),
    );
    await settle();
    expect(find.byType(StoreScreen), findsOneWidget);
    expect(find.textContaining('스토어 상품만 보는 중'), findsOneWidget);

    router.pop();
    await settle();
    expect(find.byType(StoreScreen), findsOneWidget);
  });

  testWidgets('인기 스토어 카드를 탭하면 스토어 프로필 화면으로 이동한다', (tester) async {
    // 배너 자동스크롤 타이머 때문에 pumpAndSettle이 끝나지 않을 수 있어
    // (위 테스트의 settle()과 동일한 이유) 고정 프레임을 진행한다.
    Future<void> settle() async {
      await tester.pump();
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 300));
      }
    }

    final auth = sl<AuthProvider>();
    await auth.setUser(MockAuthData.spareUser());
    final router = AppRouter.createRouter(auth);
    registerGoRouter(router);
    router.go(AppRoutes.spareHomeStore);

    await tester.pumpWidget(MyApp(router: router));
    await settle();

    await tester.tap(find.text('HairSpare 공식스토어').first);
    await settle();

    expect(find.text('상품'), findsWidgets);
    expect(find.text('리뷰'), findsWidgets);
  });
}
