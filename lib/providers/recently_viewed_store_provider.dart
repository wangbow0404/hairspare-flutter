import 'package:flutter/foundation.dart';

/// 최근 본 스토어 상품 — 최신순, 최대 [_maxItems]개까지 로컬(앱 세션) 상태로 보관.
class RecentlyViewedStoreProvider with ChangeNotifier {
  static const int _maxItems = 20;

  final List<String> _productIds = [];

  /// 최근 본 순서(최신이 먼저).
  List<String> get productIds => List.unmodifiable(_productIds);

  void recordView(String productId) {
    _productIds.remove(productId);
    _productIds.insert(0, productId);
    if (_productIds.length > _maxItems) {
      _productIds.removeRange(_maxItems, _productIds.length);
    }
    notifyListeners();
  }
}
