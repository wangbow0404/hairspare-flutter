import 'package:flutter/foundation.dart';

/// 스토어 쿠폰 발급·적용 상태 — 결제와 마찬가지로 로컬(앱 세션) 상태로만 관리.
class StoreCouponProvider with ChangeNotifier {
  final Set<String> _claimedIds = {};
  String? _appliedCouponId;

  bool isClaimed(String id) => _claimedIds.contains(id);

  int get claimedCount => _claimedIds.length;

  String? get appliedCouponId => _appliedCouponId;

  void claim(String id) {
    if (_claimedIds.add(id)) notifyListeners();
  }

  void claimAll(Iterable<String> ids) {
    _claimedIds.addAll(ids);
    notifyListeners();
  }

  void apply(String? id) {
    _appliedCouponId = id;
    notifyListeners();
  }
}
