import 'package:flutter/foundation.dart';
import '../models/store_product.dart';

/// 스토어 상품 찜(위시리스트) 상태 — 결제와 마찬가지로 아직 로컬(앱 세션) 상태로만 관리.
class StoreWishlistProvider with ChangeNotifier {
  final Map<String, StoreProduct> _wishlisted = {};

  /// 찜한 시점의 가격 — 이후 가격 하락 여부 판단용.
  final Map<String, int> _priceAtWishlist = {};

  /// 상품별로 지정한 폴더명 (null = 기본함).
  final Map<String, String?> _folderOf = {};

  /// 사용자가 만든 커스텀 폴더 목록.
  final List<String> _folders = [];

  List<StoreProduct> get products => _wishlisted.values.toList();

  List<String> get folders => List.unmodifiable(_folders);

  int get count => _wishlisted.length;

  bool isWishlisted(String productId) => _wishlisted.containsKey(productId);

  void toggle(StoreProduct product) {
    if (_wishlisted.containsKey(product.id)) {
      remove(product.id);
    } else {
      _wishlisted[product.id] = product;
      _priceAtWishlist[product.id] = product.price;
      notifyListeners();
    }
  }

  void remove(String productId) {
    _wishlisted.remove(productId);
    _priceAtWishlist.remove(productId);
    _folderOf.remove(productId);
    notifyListeners();
  }

  /// 찜한 시점 가격보다 현재가가 내려간 만큼(원). 내려가지 않았으면 0.
  int priceDropAmount(StoreProduct product) {
    final prev = _priceAtWishlist[product.id];
    if (prev == null || prev <= product.price) return 0;
    return prev - product.price;
  }

  String? folderOf(String productId) => _folderOf[productId];

  void assignFolder(String productId, String? folder) {
    _folderOf[productId] = folder;
    notifyListeners();
  }

  void createFolder(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty || _folders.contains(trimmed)) return;
    _folders.add(trimmed);
    notifyListeners();
  }
}
