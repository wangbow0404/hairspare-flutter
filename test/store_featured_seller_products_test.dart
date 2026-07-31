import 'package:flutter_test/flutter_test.dart';
import 'package:hairspare/services/store_service.dart';

void main() {
  group('StoreService.getFeaturedSellerProducts', () {
    test('평점 높은 순으로 limit 만큼 반환한다', () async {
      final service = StoreService();
      final results = await service.getFeaturedSellerProducts(
        ['seller-hairspare-official', 'seller-herzen'],
        limit: 2,
      );

      expect(results.length, 2);
      // 두 셀러의 비(非)베스트셀러 중 평점이 가장 높은 상품(4.5)이 맨 앞.
      expect(results.first.id, 'store-apparel-1');
      expect(
        results.first.averageRating,
        greaterThanOrEqualTo(results.last.averageRating),
      );
    });

    test('살롱 베스트 레일과 겹치지 않도록 베스트셀러는 제외한다', () async {
      final service = StoreService();
      final results = await service.getFeaturedSellerProducts([
        'seller-hairspare-official',
        'seller-junscissors',
        'seller-herzen',
        'seller-curlstar',
        'seller-keracis',
        'seller-colorlab',
      ]);

      expect(results, isNotEmpty);
      expect(results.every((p) => !p.isBestSeller), isTrue);
      // mock 베스트셀러 3종은 살롱 베스트 레일이 이미 보여주므로 여기 없어야 한다.
      final ids = results.map((p) => p.id).toList();
      expect(ids, isNot(contains('store-scissors-1')));
      expect(ids, isNot(contains('store-tools-1')));
      expect(ids, isNot(contains('store-haircare-1')));
    });

    test('excludeBestSellers: false면 베스트셀러도 포함한다', () async {
      final service = StoreService();
      final results = await service.getFeaturedSellerProducts(
        ['seller-hairspare-official'],
        excludeBestSellers: false,
      );

      expect(results.map((p) => p.id), contains('store-scissors-1'));
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
