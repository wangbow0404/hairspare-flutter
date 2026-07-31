import 'package:flutter/foundation.dart';

/// 스토어 셀러 팔로우 상태 — 결제와 마찬가지로 로컬(앱 세션) 상태로만 관리.
///
/// 이 Provider는 "이 사용자가 팔로우했는지"라는 로컬 변화량만 들고 있고,
/// 팔로워 기준값은 서버(현재는 mock) 데이터인 `StoreSellerSummary.followerCount`가
/// 가진다. 화면에 표시할 값은 [displayFollowerCount]로 둘을 합쳐 계산한다.
class StoreSellerFollowProvider with ChangeNotifier {
  final Set<String> _followedSellerIds = {};

  bool isFollowing(String sellerId) => _followedSellerIds.contains(sellerId);

  /// 화면 표시용 팔로워수 = 서버 기준값([baseFollowerCount]) + 내가 팔로우했으면 +1.
  int displayFollowerCount(String sellerId, int baseFollowerCount) {
    return isFollowing(sellerId) ? baseFollowerCount + 1 : baseFollowerCount;
  }

  void toggle(String sellerId) {
    if (!_followedSellerIds.remove(sellerId)) {
      _followedSellerIds.add(sellerId);
    }
    notifyListeners();
  }
}
