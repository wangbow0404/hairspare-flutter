// test/store_seller_follow_provider_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:hairspare/providers/store_seller_follow_provider.dart';

void main() {
  group('StoreSellerFollowProvider', () {
    test('기본 상태는 팔로우하지 않음, 팔로워수는 기준값', () {
      final provider = StoreSellerFollowProvider();
      expect(provider.isFollowing('seller-junscissors'), isFalse);
      expect(provider.followerCount('seller-junscissors'), 216);
    });

    test('toggle 하면 팔로우 상태와 팔로워수가 +1 된다', () {
      final provider = StoreSellerFollowProvider();
      var notified = 0;
      provider.addListener(() => notified++);

      provider.toggle('seller-junscissors');

      expect(provider.isFollowing('seller-junscissors'), isTrue);
      expect(provider.followerCount('seller-junscissors'), 217);
      expect(notified, 1);

      provider.toggle('seller-junscissors');

      expect(provider.isFollowing('seller-junscissors'), isFalse);
      expect(provider.followerCount('seller-junscissors'), 216);
    });

    test('기준값이 없는 셀러는 팔로워수 0에서 시작한다', () {
      final provider = StoreSellerFollowProvider();
      expect(provider.followerCount('seller-unknown'), 0);
      provider.toggle('seller-unknown');
      expect(provider.followerCount('seller-unknown'), 1);
    });
  });
}
