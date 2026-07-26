import 'package:flutter/foundation.dart';
import '../models/store_product.dart';

/// 스토어 상품 찜(위시리스트) 상태 — 결제와 마찬가지로 아직 로컬(앱 세션) 상태로만 관리.
class StoreWishlistProvider with ChangeNotifier {
  final Map<String, StoreProduct> _wishlisted = {};

  List<StoreProduct> get products => _wishlisted.values.toList();

  int get count => _wishlisted.length;

  bool isWishlisted(String productId) => _wishlisted.containsKey(productId);

  void toggle(StoreProduct product) {
    if (_wishlisted.containsKey(product.id)) {
      _wishlisted.remove(product.id);
    } else {
      _wishlisted[product.id] = product;
    }
    notifyListeners();
  }

  void remove(String productId) {
    _wishlisted.remove(productId);
    notifyListeners();
  }
}
