import 'package:flutter_test/flutter_test.dart';
import 'package:hairspare/core/di/service_locator.dart';
import 'package:hairspare/services/store_seller_service.dart';
import 'package:hairspare/services/store_service.dart';

void main() {
  setUpAll(() {
    // Initialize dependencies for tests
    configureDependencies();
  });

  group('StoreSellerService.getSellerReviews', () {
    test('셀러의 여러 상품 리뷰를 모아 최신순으로 반환한다', () async {
      final service = StoreSellerService();
      final storeService = StoreService();

      // seller-hairspare-official은 여러 상품에 리뷰가 달려있다 (mock 데이터 기준).
      const sellerId = 'seller-hairspare-official';
      final sellerProducts = await storeService.getProductsBySeller(sellerId);
      final entries = await service.getSellerReviews(sellerId, sellerProducts);

      expect(entries, isNotEmpty);
      for (var i = 0; i < entries.length - 1; i++) {
        expect(
          entries[i].review.createdAt.isAfter(
                entries[i + 1].review.createdAt,
              ) ||
              entries[i].review.createdAt.isAtSameMomentAs(
                entries[i + 1].review.createdAt,
              ),
          isTrue,
          reason: '리뷰가 최신순으로 정렬되지 않았습니다',
        );
      }
      for (final entry in entries) {
        expect(entry.productName, isNotEmpty);
      }

      // 단순히 첫 상품 리뷰만 돌려주는 구현으로도 통과하지 않도록,
      // 실제로 여러 상품의 리뷰가 "섞여서" 모였는지 검증한다.
      final productIds = entries.map((e) => e.productId).toSet();
      expect(
        productIds.length,
        greaterThan(1),
        reason: '여러 상품의 리뷰가 모여야 합니다',
      );

      // mock 기준: store-scissors-1 리뷰 3건 + store-tools-1 리뷰 2건 = 5건.
      final expectedTotal = sellerProducts.fold<int>(
        0,
        (sum, p) => sum + p.reviews.length,
      );
      expect(entries.length, expectedTotal);
      expect(entries.length, 5);
      expect(productIds, {'store-scissors-1', 'store-tools-1'});

      // 각 상품의 리뷰가 하나도 빠지지 않았는지 (연결이 아니라 전량 집계인지) 확인.
      for (final product in sellerProducts) {
        expect(
          entries.where((e) => e.productId == product.id).length,
          product.reviews.length,
          reason: '${product.name}의 리뷰 수가 맞지 않습니다',
        );
      }
    });

    test('리뷰가 없는 셀러는 빈 리스트를 반환한다', () async {
      final service = StoreSellerService();
      final storeService = StoreService();

      const sellerId = 'seller-bomne';
      final sellerProducts = await storeService.getProductsBySeller(sellerId);
      final entries = await service.getSellerReviews(sellerId, sellerProducts);

      expect(entries, isEmpty);
    });

    test('다른 셀러 상품이 섞여 들어와도 해당 셀러 리뷰만 집계한다', () async {
      final service = StoreSellerService();
      final storeService = StoreService();

      const sellerId = 'seller-hairspare-official';
      final allProducts = await storeService.getProducts();
      final entries = await service.getSellerReviews(sellerId, allProducts);

      expect(entries, isNotEmpty);
      final ownProductIds = allProducts
          .where((p) => p.sellerId == sellerId)
          .map((p) => p.id)
          .toSet();
      for (final entry in entries) {
        expect(ownProductIds, contains(entry.productId));
      }
    });
  });
}
