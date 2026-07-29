// test/store_feature_shortcuts_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hairspare/widgets/store/store_feature_shortcuts.dart';

void main() {
  testWidgets('각 숏컷을 탭하면 해당 콜백이 호출된다', (tester) async {
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

    expect(find.text('2'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);

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
}
