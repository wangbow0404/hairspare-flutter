import 'package:flutter/foundation.dart';
import '../models/store_product.dart';

/// 장바구니 담긴 상품 1건 (상품 + 수량).
class CartItem {
  CartItem({required this.product, required this.quantity});

  final StoreProduct product;
  int quantity;

  int get subtotal => product.price * quantity;
}

/// 스토어 장바구니 상태 — 결제 연동 전까지는 로컬(앱 세션) 상태로만 관리.
class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList();

  bool get isEmpty => _items.isEmpty;

  int get totalCount =>
      _items.values.fold(0, (sum, item) => sum + item.quantity);

  int get totalPrice =>
      _items.values.fold(0, (sum, item) => sum + item.subtotal);

  int quantityOf(String productId) => _items[productId]?.quantity ?? 0;

  void addProduct(StoreProduct product, {int quantity = 1}) {
    final existing = _items[product.id];
    if (existing != null) {
      existing.quantity += quantity;
    } else {
      _items[product.id] = CartItem(product: product, quantity: quantity);
    }
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    final existing = _items[productId];
    if (existing == null) return;
    if (quantity <= 0) {
      _items.remove(productId);
    } else {
      existing.quantity = quantity;
    }
    notifyListeners();
  }

  void removeProduct(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
