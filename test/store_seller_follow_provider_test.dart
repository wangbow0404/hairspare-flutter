// test/store_seller_follow_provider_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:hairspare/providers/store_seller_follow_provider.dart';

void main() {
  group('StoreSellerFollowProvider', () {
    test('기본 상태는 팔로우하지 않음, 표시 팔로워수는 전달받은 기준값 그대로', () {
      final provider = StoreSellerFollowProvider();
      expect(provider.isFollowing('seller-junscissors'), isFalse);
      expect(provider.displayFollowerCount('seller-junscissors', 216), 216);
    });

    test('toggle 하면 팔로우 상태와 표시 팔로워수가 +1 된다', () {
      final provider = StoreSellerFollowProvider();
      var notified = 0;
      provider.addListener(() => notified++);

      provider.toggle('seller-junscissors');

      expect(provider.isFollowing('seller-junscissors'), isTrue);
      expect(provider.displayFollowerCount('seller-junscissors', 216), 217);
      expect(notified, 1);

      provider.toggle('seller-junscissors');

      expect(provider.isFollowing('seller-junscissors'), isFalse);
      expect(provider.displayFollowerCount('seller-junscissors', 216), 216);
    });

    test('팔로우는 셀러별로 독립적이다 — 다른 셀러 기준값은 그대로', () {
      final provider = StoreSellerFollowProvider();
      provider.toggle('seller-junscissors');

      expect(provider.displayFollowerCount('seller-junscissors', 216), 217);
      expect(provider.displayFollowerCount('seller-herzen', 138), 138);
    });

    test('기준값이 0인(팔로워 데이터가 없는) 셀러도 팔로우하면 1이 된다', () {
      final provider = StoreSellerFollowProvider();
      expect(provider.displayFollowerCount('seller-unknown', 0), 0);
      provider.toggle('seller-unknown');
      expect(provider.displayFollowerCount('seller-unknown', 0), 1);
    });
  });
}
