import 'package:flutter_test/flutter_test.dart';
import 'package:hairspare/providers/recently_viewed_store_provider.dart';

void main() {
  group('RecentlyViewedStoreProvider', () {
    test('최근 본 순서대로(최신 먼저) 기록한다', () {
      final provider = RecentlyViewedStoreProvider();
      provider.recordView('p1');
      provider.recordView('p2');
      provider.recordView('p3');

      expect(provider.productIds, ['p3', 'p2', 'p1']);
    });

    test('이미 본 상품을 다시 보면 맨 앞으로 이동하고 중복되지 않는다', () {
      final provider = RecentlyViewedStoreProvider();
      provider.recordView('p1');
      provider.recordView('p2');
      provider.recordView('p1');

      expect(provider.productIds, ['p1', 'p2']);
    });

    test('20개를 초과하면 오래된 항목부터 제거한다', () {
      final provider = RecentlyViewedStoreProvider();
      for (var i = 0; i < 25; i++) {
        provider.recordView('p$i');
      }

      expect(provider.productIds.length, 20);
      expect(provider.productIds.first, 'p24');
      expect(provider.productIds.contains('p4'), isFalse);
    });
  });
}
