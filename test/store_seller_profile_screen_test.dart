import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hairspare/core/di/service_locator.dart';
import 'package:hairspare/providers/cart_provider.dart';
import 'package:hairspare/providers/store_seller_follow_provider.dart';
import 'package:hairspare/providers/store_wishlist_provider.dart';
import 'package:hairspare/screens/spare/store_seller_profile_screen.dart';
import 'package:hairspare/utils/api_client.dart';
import 'package:hairspare/widgets/store/store_app_bar_actions.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    dotenv.testLoad(fileInput: '');
    await initializeDateFormatting('ko_KR');
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
          ChangeNotifierProvider<CartProvider>.value(value: sl<CartProvider>()),
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

  testWidgets('상단바에 찜·장바구니 아이콘이 있다', (tester) async {
    await pumpScreen(tester, 'seller-hairspare-official');

    expect(find.byType(StoreWishlistAction), findsOneWidget);
    expect(find.byType(StoreCartAction), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(StoreWishlistAction),
        matching: find.byIcon(Icons.favorite_border),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(StoreCartAction),
        matching: find.byIcon(Icons.shopping_cart_outlined),
      ),
      findsOneWidget,
    );
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

  testWidgets('브랜드명으로도 검색되고 앞뒤 공백은 무시된다', (tester) async {
    await pumpScreen(tester, 'seller-hairspare-official');

    // '하츠'는 상품명이 아니라 브랜드명 (프로 커팅 가위 6인치 · 일회용 위생 가운).
    await tester.enterText(find.byType(TextField), '  하츠 ');
    await tester.pumpAndSettle();

    expect(find.text('검색 결과가 없습니다'), findsNothing);
    expect(find.text('프로 커팅 가위 6인치'), findsOneWidget);
  });

  testWidgets('없는 셀러 id로 들어오면 무한 로딩 대신 없음 화면을 보여준다', (tester) async {
    await pumpScreen(tester, 'seller-does-not-exist');

    expect(find.text('스토어를 찾을 수 없습니다'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('빈 셀러 id로 들어와도 없음 화면을 보여준다', (tester) async {
    await pumpScreen(tester, '');

    expect(find.text('스토어를 찾을 수 없습니다'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('리뷰 탭을 누르면 이 셀러 상품들의 리뷰가 최신순으로 보인다', (tester) async {
    await pumpScreen(tester, 'seller-hairspare-official');

    await tester.tap(find.text('리뷰').last);
    await tester.pumpAndSettle();

    expect(find.byType(ListView), findsOneWidget);
    // mock 데이터의 실제 리뷰 내용이 렌더링되는지 (빈 리스트뷰가 아닌지) 확인.
    expect(find.text('김디자이너'), findsOneWidget);
    expect(
      find.text('손에 착 감기고 날이 오래가요. 재구매 의사 100%입니다.'),
      findsOneWidget,
    );
    // 서로 다른 상품의 리뷰가 함께 모여 있어야 한다
    // (김디자이너 = 프로 커팅 가위, 최미용 = 이온 고속 드라이기).
    expect(find.text('최미용'), findsOneWidget);
    expect(find.text('프로 커팅 가위 6인치'), findsWidgets);
    expect(find.text('이온 고속 드라이기 프로'), findsWidgets);
  });
}
