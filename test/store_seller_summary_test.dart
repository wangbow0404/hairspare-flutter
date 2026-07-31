// test/store_seller_summary_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:hairspare/models/store_product.dart';
import 'package:hairspare/services/store_seller_service.dart';

StoreProduct _product({
  required String id,
  required String sellerId,
  List<StoreProductReview> reviews = const [],
}) {
  return StoreProduct(
    id: id,
    name: '테스트 상품',
    brand: '테스트 브랜드',
    sellerId: sellerId,
    category: StoreProductCategory.scissors,
    price: 10000,
    imageUrls: const ['https://example.com/a.png'],
    description: '설명',
    reviews: reviews,
  );
}

List<StoreProductReview> _fiveStarReviews(int count) => List.generate(
  count,
  (_) => StoreProductReview(
    userName: '테스터',
    rating: 5,
    comment: '좋아요',
    createdAt: DateTime.now(),
  ),
);

void main() {
  group('StoreSellerService.getSellerSummaries', () {
    test('승인된 셀러만 포함하고 평점·상품수로 정렬한다', () async {
      final products = [
        _product(
          id: 'p1',
          sellerId: 'seller-hairspare-official',
          reviews: _fiveStarReviews(2),
        ),
        _product(
          id: 'p2',
          sellerId: 'seller-hairspare-official',
          reviews: _fiveStarReviews(1),
        ),
        _product(
          id: 'p3',
          sellerId: 'seller-junscissors',
          reviews: [
            StoreProductReview(
              userName: '테스터',
              rating: 4,
              comment: '좋아요',
              createdAt: DateTime.now(),
            ),
          ],
        ),
        _product(id: 'p4', sellerId: 'seller-curlstar'),
        _product(id: 'p5', sellerId: 'seller-curlstar'),
        // pending 상태인 seller-bomne는 결과에서 제외되어야 함
        _product(
          id: 'p6',
          sellerId: 'seller-bomne',
          reviews: _fiveStarReviews(5),
        ),
      ];

      final service = StoreSellerService();
      final summaries = await service.getSellerSummaries(products);

      expect(
        summaries.any((s) => s.seller.id == 'seller-bomne'),
        isFalse,
        reason: 'pending 셀러는 제외되어야 함',
      );

      final top = summaries.first;
      expect(top.seller.id, 'seller-hairspare-official');
      expect(top.productCount, 2);
      expect(top.averageRating, 5.0);

      final second = summaries[1];
      expect(second.seller.id, 'seller-junscissors');
      expect(second.productCount, 1);
      expect(second.averageRating, 4.0);

      final curlstar = summaries.firstWhere(
        (s) => s.seller.id == 'seller-curlstar',
      );
      expect(curlstar.productCount, 2);
      expect(curlstar.averageRating, 0.0);
    });

    test('셀러 팔로워수(서버 기준값)를 요약에 함께 담는다', () async {
      final service = StoreSellerService();
      final summaries = await service.getSellerSummaries([
        _product(id: 'p1', sellerId: 'seller-hairspare-official'),
      ]);

      final official = summaries.firstWhere(
        (s) => s.seller.id == 'seller-hairspare-official',
      );
      final junscissors = summaries.firstWhere(
        (s) => s.seller.id == 'seller-junscissors',
      );

      // 팔로워수는 상품/리뷰 집계와 무관한 별도 데이터라 상품이 없어도 채워진다.
      expect(official.followerCount, 482);
      expect(junscissors.followerCount, 216);
      expect(junscissors.productCount, 0);
    });
  });
}
