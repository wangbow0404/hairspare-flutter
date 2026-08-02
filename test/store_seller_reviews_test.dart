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

      // seller-hairspare-official은 여러 상품에 리뷰가 달려있다 (mock 데이터 기준).
      final entries = await service.getSellerReviews(
        'seller-hairspare-official',
      );

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
    });

    test('리뷰가 없는 셀러는 빈 리스트를 반환한다', () async {
      final service = StoreSellerService();

      final entries = await service.getSellerReviews('seller-bomne');

      expect(entries, isEmpty);
    });
  });
}
