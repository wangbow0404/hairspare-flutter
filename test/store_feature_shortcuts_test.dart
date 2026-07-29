// test/store_feature_shortcuts_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hairspare/widgets/store/store_feature_shortcuts.dart';

void main() {
  testWidgets('각 숏컷을 탭하면 해당 콜백이 호출되고 배지는 카트/찜에만 나타난다', (tester) async {
    final tapped = <String>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StoreFeatureShortcuts(
            cartCount: 2,
            wishlistCount: 5,
            onCart: () => tapped.add('cart'),
            onWishlist: () => tapped.add('wishlist'),
            onOrders: () => tapped.add('orders'),
            onAllSellers: () => tapped.add('allSellers'),
            onCouponBox: () => tapped.add('couponBox'),
            onRecentlyViewed: () => tapped.add('recentlyViewed'),
          ),
        ),
      ),
    );

    // Verify badge counts display correctly
    expect(find.text('2'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);

    // Verify only 2 badges are rendered (cart and wishlist only)
    expect(find.byType(Positioned), findsWidgets);
    expect(find.byType(Positioned), findsNWidgets(2));

    // Verify other items have no badge text
    expect(find.text('주문내역'), findsOneWidget);
    expect(find.text('전체 스토어'), findsOneWidget);
    expect(find.text('쿠폰함'), findsOneWidget);
    expect(find.text('최근 본 상품'), findsOneWidget);

    await tester.tap(find.text('장바구니'));
    await tester.tap(find.text('찜한 상품'));
    await tester.tap(find.text('주문내역'));
    await tester.tap(find.text('전체 스토어'));
    await tester.tap(find.text('쿠폰함'));
    await tester.tap(find.text('최근 본 상품'));
    await tester.pump();

    expect(
      tapped,
      containsAll([
        'cart',
        'wishlist',
        'orders',
        'allSellers',
        'couponBox',
        'recentlyViewed',
      ]),
    );
  });

  testWidgets('배지 카운트가 0일 때 배지가 나타나지 않는다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StoreFeatureShortcuts(
            cartCount: 0,
            wishlistCount: 0,
            onCart: () {},
            onWishlist: () {},
            onOrders: () {},
            onAllSellers: () {},
            onCouponBox: () {},
            onRecentlyViewed: () {},
          ),
        ),
      ),
    );

    // Verify badge counts ('0') are NOT displayed
    expect(find.text('0'), findsNothing);

    // Verify no badges are rendered when all counts are 0
    expect(find.byType(Positioned), findsNothing);

    // Verify all labels are still present
    expect(find.text('장바구니'), findsOneWidget);
    expect(find.text('찜한 상품'), findsOneWidget);
    expect(find.text('주문내역'), findsOneWidget);
    expect(find.text('전체 스토어'), findsOneWidget);
    expect(find.text('쿠폰함'), findsOneWidget);
    expect(find.text('최근 본 상품'), findsOneWidget);
  });
}
