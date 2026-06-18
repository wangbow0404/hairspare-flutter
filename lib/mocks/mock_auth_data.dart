import '../models/login_portal.dart';
import '../models/spare_subtype.dart';
import '../models/user.dart';
import '../utils/app_exception.dart';

/// 인증용 Mock 데이터 (Spare/Shop/Admin).
///
/// [ApiConfig.useMockData] 가 켜진 디버그 빌드에서만 사용됩니다.
/// 자격 증명은 [MockAuthData] 상수와 [AuthService]의 검증 로직과 맞춥니다.
class MockAuthData {
  /// 목업 로그인·회원가입(모크 모드) 시 사용하는 고정 계정입니다.
  static const String devSpareUsername = '1';
  static const String devSparePassword = '1';
  static const String devShopUsername = '2';
  static const String devShopPassword = '2';
  static const String devAdminUsername = '3';
  static const String devAdminPassword = '3';
  static const String devModelUsername = '4';
  static const String devModelPassword = '4';

  static const String _mockTokenSpareModel = 'mock_token_spare_model';

  static User spareUser({SpareSubtype? spareSubtype}) {
    return User.fromJson({
      'id': 'mock-spare-1',
      'username': devSpareUsername,
      'email': 'spare@example.com',
      'name': '김디자이너',
      'phone': '010-1234-5678',
      'role': 'spare',
      'spareSubtype': (spareSubtype ?? _registeredSpareSubtype ?? SpareSubtype.professional).name,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  static User modelUser() {
    return User.fromJson({
      'id': 'mock-model-dev',
      'username': devModelUsername,
      'email': 'model@example.com',
      'name': '모델테스트',
      'phone': '010-4444-4444',
      'role': 'spare',
      'spareSubtype': SpareSubtype.model.name,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  static SpareSubtype? _registeredSpareSubtype;
  static Map<String, dynamic>? _registeredProfilePayload;

  static User registerSpareUser({
    required String username,
    String? name,
    String? email,
    String? phone,
    required SpareSubtype spareSubtype,
    Map<String, dynamic>? profilePayload,
  }) {
    _registeredSpareSubtype = spareSubtype;
    _registeredProfilePayload = profilePayload;
    return User.fromJson({
      'id': spareSubtype == SpareSubtype.model ? 'mock-model-1' : 'mock-spare-1',
      'username': username,
      'email': email ?? 'spare@example.com',
      'name': name ?? (spareSubtype == SpareSubtype.model ? '모델회원' : '김디자이너'),
      'phone': phone ?? '010-1234-5678',
      'role': 'spare',
      'spareSubtype': spareSubtype.name,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  static bool get isRegisteredModel =>
      _registeredSpareSubtype == SpareSubtype.model;

  static Map<String, dynamic>? get registeredProfilePayload =>
      _registeredProfilePayload;

  static User shopUser() {
    return User.fromJson({
      'id': 'mock-shop-1',
      'username': devShopUsername,
      'email': 'shop@salon.co.kr',
      'name': '이미용실',
      'phone': '02-1234-5678',
      'role': 'shop',
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  static User adminUser() {
    return User.fromJson({
      'id': 'mock-admin-1',
      'username': devAdminUsername,
      'email': 'admin@hairspare.dev',
      'name': '관리자',
      'phone': '02-0000-0000',
      'role': 'admin',
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  /// mock 로그인: 아이디·비밀번호로 유저 판별.
  static User? userForCredentials(String username, String password) {
    if (isShopAccountTerminated &&
        username == devShopUsername &&
        password == devShopPassword) {
      return null;
    }
    if (username == devSpareUsername && password == devSparePassword) {
      return spareUser();
    }
    if (username == devModelUsername && password == devModelPassword) {
      return modelUser();
    }
    if (username == devShopUsername && password == devShopPassword) {
      return shopUser();
    }
    if (username == devAdminUsername && password == devAdminPassword) {
      return adminUser();
    }
    return null;
  }

  /// [portal] 로그인 화면 기준 허용 계정만 반환 (스페어 화면: 1/1·3/3, 샵 화면: 2/2·3/3).
  static User? userForCredentialsOnPortal(
    String username,
    String password,
    LoginPortal portal,
  ) {
    final user = userForCredentials(username, password);
    if (user == null) return null;
    return switch (portal) {
      LoginPortal.spare =>
        user.role == UserRole.shop ? null : user,
      LoginPortal.shop =>
        user.role == UserRole.spare ? null : user,
    };
  }

  static String mockTokenForRole(UserRole role) => 'mock_token_${role.name}';

  static String mockTokenForUser(User user) {
    if (user.role == UserRole.spare && user.isModelAccount) {
      return _mockTokenSpareModel;
    }
    return mockTokenForRole(user.role);
  }

  static const String _mockTokenPrefix = 'mock_token_';

  /// 저장된 mock 토큰에서 역할 복원. 레거시 `mock_token`은 spare.
  static UserRole? roleFromMockToken(String? token) {
    if (token == null || token.isEmpty) return null;
    if (token == 'mock_token') return UserRole.spare;
    if (!token.startsWith(_mockTokenPrefix)) return null;
    final roleName = token.substring(_mockTokenPrefix.length);
    for (final role in UserRole.values) {
      if (role.name == roleName) return role;
    }
    return null;
  }

  static User? userForMockToken(String? token) {
    if (isShopAccountTerminated &&
        roleFromMockToken(token) == UserRole.shop) {
      return null;
    }
    if (token == _mockTokenSpareModel) {
      return modelUser();
    }
    final role = roleFromMockToken(token);
    return switch (role) {
      UserRole.spare => spareUser(),
      UserRole.shop => shopUser(),
      UserRole.admin => adminUser(),
      null => null,
    };
  }

  static bool isShopAccountTerminated = false;

  /// 사업자 식별자(전화·사업자번호·shopId) 블랙리스트.
  static final Set<String> blacklistedBusinessIdentifiers = {};

  static void assertCanRegisterShop({
    String? phone,
    String? businessRegistrationNumber,
    String? username,
  }) {
    for (final id in [
      phone,
      businessRegistrationNumber,
      username,
    ]) {
      if (id != null &&
          id.trim().isNotEmpty &&
          blacklistedBusinessIdentifiers.contains(id.trim())) {
        throw ValidationException(
          '이용 정책 위반으로 해당 사업자는 HAIRSPARE 재가입이 '
          '불가합니다. 고객센터에 문의해 주세요.',
          code: 'SHOP_BLACKLISTED',
        );
      }
    }
  }

  /// 연락처 위반 누적 3회 → 계정 탈퇴·블랙리스트 등록.
  static void terminateShopAccount(String shopId) {
    isShopAccountTerminated = true;
    final shop = shopUser();
    blacklistedBusinessIdentifiers
      ..add(shopId)
      ..add(shop.phone ?? '')
      ..add(shop.username)
      ..add(shop.email ?? '');
  }

  static String loginBlockedMessageForTerminatedShop() =>
      '연락처 공유 위반 누적으로 계정이 탈퇴 처리되었습니다. '
      '재가입이 불가합니다.';
}
