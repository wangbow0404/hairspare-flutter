import '../models/user.dart';

/// 인증용 Mock 데이터 (Spare/Shop 로그인)
class MockAuthData {
  static User spareUser() {
    return User.fromJson({
      'id': 'mock-spare-1',
      'username': 'spare_mock',
      'email': 'spare@example.com',
      'name': '김디자이너',
      'phone': '010-1234-5678',
      'role': 'spare',
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  static User shopUser() {
    return User.fromJson({
      'id': 'mock-shop-1',
      'username': 'shop_mock',
      'email': 'shop@salon.co.kr',
      'name': '이미용실',
      'phone': '02-1234-5678',
      'role': 'shop',
      'createdAt': DateTime.now().toIso8601String(),
    });
  }
}
