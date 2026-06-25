/// 관리자 회원 관리 — 역할 필터·라벨 (스페어·디자이너 / 샵 / 모델)
abstract final class AdminMemberRole {
  static const filterTabs = ['전체', '스페어·디자이너', '샵', '모델'];

  static const _filterMap = {
    '전체': '',
    '스페어·디자이너': 'spare_designer',
    '샵': 'shop',
    '모델': 'model',
  };

  static String filterToQuery(String tab) => _filterMap[tab] ?? '';

  static String queryToTab(String query) {
    for (final entry in _filterMap.entries) {
      if (entry.value == query) return entry.key;
    }
    return '전체';
  }

  static String categoryKey(Map<String, dynamic> user) {
    if (isShop(user)) return 'shop';
    if (isModel(user)) return 'model';
    return 'spare_designer';
  }

  static bool isShop(Map<String, dynamic> user) =>
      user['role']?.toString() == 'shop';

  static bool isModel(Map<String, dynamic> user) {
    final role = user['role']?.toString();
    if (role == 'model') return true;
    return role == 'spare' && user['spareSubtype']?.toString() == 'model';
  }

  static bool isSpareDesigner(Map<String, dynamic> user) =>
      !isShop(user) && !isModel(user);

  static bool matchesFilter(Map<String, dynamic> user, String filterQuery) {
    if (filterQuery.isEmpty) return true;
    return categoryKey(user) == filterQuery;
  }

  /// 목록·상세 뱃지 — 스페어 / 디자이너 / 샵 / 모델
  static String badgeLabel(Map<String, dynamic> user) {
    if (isShop(user)) return '샵';
    if (isModel(user)) return '모델';

    final spareRole = user['spareRole']?.toString();
    if (spareRole == 'designer') return '디자이너';

    final role = user['role']?.toString();
    if (role == 'seller') return '디자이너';

    return '스페어';
  }

  /// 기본정보 «역할» 필드
  static String detailRoleLabel(Map<String, dynamic> user) => badgeLabel(user);

  /// 기본정보 «회원 유형» 필드
  static String categoryLabel(Map<String, dynamic> user) {
    if (isShop(user)) return '샵';
    if (isModel(user)) return '모델';
    return '스페어·디자이너';
  }
}
