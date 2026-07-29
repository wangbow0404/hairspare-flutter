import 'package:flutter_test/flutter_test.dart';
import 'package:hairspare/services/store_service.dart';

void main() {
  group('StoreService.getFeaturedSellerProducts', () {
    test('베스트셀러 우선 정렬 후 limit 만큼 반환한다', () async {
      final service = StoreService();
      final results = await service.getFeaturedSellerProducts(
        ['seller-hairspare-official', 'seller-junscissors'],
        limit: 2,
      );

      expect(results.length, 2);
      expect(results[0].id, 'store-scissors-1');
      expect(results[1].id, 'store-tools-1');
      expect(results.every((p) => p.isBestSeller), isTrue);
    });

    test('지정하지 않은 셀러의 상품은 제외한다', () async {
      final service = StoreService();
      final results = await service.getFeaturedSellerProducts([
        'seller-curlstar',
      ]);

      expect(results, isNotEmpty);
      expect(results.every((p) => p.sellerId == 'seller-curlstar'), isTrue);
    });
  });
}
