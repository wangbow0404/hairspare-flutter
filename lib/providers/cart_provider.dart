import 'package:flutter/foundation.dart';
import '../models/store_product.dart';

/// 장바구니 담긴 상품 1건 (상품 + 수량 + 선택한 옵션).
class CartItem {
  CartItem({
    required this.product,
    required this.quantity,
    this.selectedOptions = const {},
  });

  final StoreProduct product;
  int quantity;

  /// 옵션 그룹명 → 선택한 옵션 값.
  final Map<String, StoreProductOptionValue> selectedOptions;

  /// 옵션이 적용된 개당 가격 (기본가 + 선택 옵션들의 추가금액 합).
  int get unitPrice =>
      product.price +
      selectedOptions.values.fold(0, (sum, v) => sum + v.priceDelta);

  int get subtotal => unitPrice * quantity;

  /// 같은 상품이라도 옵션 조합이 다르면 별도 라인으로 취급하기 위한 키.
  String get lineKey {
    if (selectedOptions.isEmpty) return product.id;
    final optionPart = selectedOptions.entries
        .map((e) => '${e.key}:${e.value.label}')
        .join('|');
    return '${product.id}::$optionPart';
  }

  /// 선택 옵션을 "5.5인치 / 블랙"처럼 사람이 읽는 요약으로 변환.
  String get optionSummary =>
      selectedOptions.values.map((v) => v.label).join(' / ');
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

  void addProduct(
    StoreProduct product, {
    int quantity = 1,
    Map<String, StoreProductOptionValue> selectedOptions = const {},
  }) {
    final newItem = CartItem(
      product: product,
      quantity: quantity,
      selectedOptions: selectedOptions,
    );
    final key = newItem.lineKey;
    final existing = _items[key];
    if (existing != null) {
      existing.quantity += quantity;
    } else {
      _items[key] = newItem;
    }
    notifyListeners();
  }

  void updateQuantity(String lineKey, int quantity) {
    final existing = _items[lineKey];
    if (existing == null) return;
    if (quantity <= 0) {
      _items.remove(lineKey);
    } else {
      existing.quantity = quantity;
    }
    notifyListeners();
  }

  void removeProduct(String lineKey) {
    _items.remove(lineKey);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
