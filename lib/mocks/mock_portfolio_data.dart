/// 사용자별 작업 포트폴리오 mock 저장소.
abstract final class MockPortfolioData {
  static String mockUrl(String ownerId, String key) =>
      'mock://portfolio/$ownerId/$key';

  static final Map<String, List<String>> _store = {
    'spare:mock-spare-1': [
      mockUrl('mock-spare-1', 'work-1'),
      mockUrl('mock-spare-1', 'work-2'),
      mockUrl('mock-spare-1', 'work-3'),
    ],
    'shop:mock-shop-1': [
      mockUrl('mock-shop-1', 'salon-1'),
      mockUrl('mock-shop-1', 'salon-2'),
    ],
  };

  static String _key(String ownerRole, String ownerId) =>
      '$ownerRole:$ownerId';

  static List<String> getImages({
    required String ownerRole,
    required String ownerId,
  }) {
    return List<String>.from(
      _store[_key(ownerRole, ownerId)] ?? const [],
    );
  }

  static List<String> setImages({
    required String ownerRole,
    required String ownerId,
    required List<String> images,
  }) {
    final key = _key(ownerRole, ownerId);
    _store[key] = List<String>.from(images);
    return getImages(ownerRole: ownerRole, ownerId: ownerId);
  }

  /// [SpareProfile.id] → 포트폴리오 owner id (목 mock-spare-1 계정).
  static String? portfolioOwnerIdForSpareProfile(String spareProfileId) {
    return switch (spareProfileId) {
      'spare-mock-1' => 'mock-spare-1',
      _ => null,
    };
  }
}
