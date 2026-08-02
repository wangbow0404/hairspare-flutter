import 'package:flutter_test/flutter_test.dart';
import 'package:hairspare/models/store_seller.dart';
import 'package:hairspare/services/store_seller_service.dart';

void main() {
  test('mock 셀러 전원이 소개글(introText)을 가지고 있다', () async {
    final service = StoreSellerService();
    final sellers = await service.getSellers();

    expect(sellers, isNotEmpty);
    for (final seller in sellers) {
      expect(
        seller.introText,
        isNotNull,
        reason: '${seller.shopName}에 introText가 없습니다',
      );
      expect(seller.introText, isNotEmpty);
    }
  });
}
