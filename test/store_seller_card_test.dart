// test/store_seller_card_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hairspare/models/store_seller.dart';
import 'package:hairspare/widgets/store/store_seller_card.dart';

StoreSellerSummary _summary() => StoreSellerSummary(
  seller: StoreSeller(
    id: 'seller-junscissors',
    shopName: '준가위 공구몰',
    ownerName: '김준호',
    status: StoreSellerStatus.approved,
    appliedAt: DateTime(2026, 1, 1),
  ),
  productCount: 12,
  averageRating: 4.7,
);

void main() {
  testWidgets('카드를 탭하면 onTap, 팔로우 버튼을 탭하면 onFollowToggle이 호출된다', (
    tester,
  ) async {
    var tapped = false;
    var followToggled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StoreSellerCard(
            summary: _summary(),
            isFollowing: false,
            followerCount: 216,
            onTap: () => tapped = true,
            onFollowToggle: () => followToggled = true,
          ),
        ),
      ),
    );

    expect(find.text('준가위 공구몰'), findsOneWidget);
    expect(find.text('+ 팔로우'), findsOneWidget);

    await tester.tap(find.text('+ 팔로우'));
    await tester.pump();
    expect(followToggled, isTrue);
    expect(tapped, isFalse);

    await tester.tap(find.text('준가위 공구몰'));
    await tester.pump();
    expect(tapped, isTrue);
  });

  testWidgets('isFollowing이 true면 "팔로잉"으로 표시된다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StoreSellerCard(
            summary: _summary(),
            isFollowing: true,
            followerCount: 217,
            onTap: () {},
            onFollowToggle: () {},
          ),
        ),
      ),
    );

    expect(find.text('팔로잉'), findsOneWidget);
    expect(find.text('+ 팔로우'), findsNothing);
  });
}
