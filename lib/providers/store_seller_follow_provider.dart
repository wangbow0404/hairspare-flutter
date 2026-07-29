import 'package:flutter/foundation.dart';

/// 스토어 셀러 팔로우 상태 — 결제와 마찬가지로 로컬(앱 세션) 상태로만 관리.
/// 팔로워수는 mock 기준값에 현재 사용자의 팔로우 여부를 반영해 계산한다.
class StoreSellerFollowProvider with ChangeNotifier {
  static const Map<String, int> _baseFollowerCounts = {
    'seller-hairspare-official': 482,
    'seller-junscissors': 216,
    'seller-herzen': 138,
    'seller-curlstar': 97,
    'seller-keracis': 64,
    'seller-colorlab': 41,
  };

  final Set<String> _followedSellerIds = {};

  bool isFollowing(String sellerId) => _followedSellerIds.contains(sellerId);

  int followerCount(String sellerId) {
    final base = _baseFollowerCounts[sellerId] ?? 0;
    return isFollowing(sellerId) ? base + 1 : base;
  }

  void toggle(String sellerId) {
    if (!_followedSellerIds.remove(sellerId)) {
      _followedSellerIds.add(sellerId);
    }
    notifyListeners();
  }
}
