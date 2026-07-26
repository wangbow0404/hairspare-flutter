/// 스토어 플로우 라우트 판별·하단 탭 인덱스.
abstract final class StoreRouteHelper {
  static const storeTabHome = 0;
  static const storeTabCategory = 1;
  static const storeTabWishlist = 2;
  static const storeTabMy = 3;

  static String _pathOnly(String pathOrUri) {
    return Uri.parse(
      pathOrUri.startsWith('/') ? pathOrUri : '/$pathOrUri',
    ).path;
  }

  /// 스토어 전용 하단 바를 쓸 경로인지 (쿼리스트링 무시).
  static bool isStoreFlow(String pathOrUri) {
    final path = _pathOnly(pathOrUri);
    if (path.endsWith('/store')) return true;
    if (path.contains('/store_')) return true;
    return false;
  }

  static int tabIndexForPath(String pathOrUri) {
    final path = _pathOnly(pathOrUri);
    if (path.contains('/store_my')) return storeTabMy;
    if (path.contains('/store_wishlist')) return storeTabWishlist;
    if (path.contains('/store_cart')) return storeTabMy;
    return storeTabHome;
  }
}
