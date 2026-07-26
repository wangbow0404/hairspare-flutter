import '../models/store_order.dart';

/// 스토어 마이 — 주문·배송·배송지 (mock).
class StoreAccountService {
  static final List<StoreOrder> _orders = [
    StoreOrder(
      id: 'ORD-20260720-001',
      productName: '프로 커팅 가위 6인치',
      productThumbnailUrl:
          'https://picsum.photos/seed/hairspare-store-scissors-1/200/200',
      quantity: 1,
      totalPrice: 89000,
      status: StoreOrderStatus.shipping,
      orderedAt: DateTime(2026, 7, 20, 14, 32),
      trackingNumber: 'HS7263849201',
      recipientName: '김디자이너',
      addressSummary: '경기 부천시 고강동 123-4',
    ),
    StoreOrder(
      id: 'ORD-20260712-002',
      productName: '이온 고속 드라이기 프로',
      productThumbnailUrl:
          'https://picsum.photos/seed/hairspare-store-tools-1/200/200',
      quantity: 1,
      totalPrice: 159000,
      status: StoreOrderStatus.delivered,
      orderedAt: DateTime(2026, 7, 12, 10, 5),
      trackingNumber: 'HS7260112388',
      recipientName: '김디자이너',
      addressSummary: '경기 부천시 고강동 123-4',
    ),
    StoreOrder(
      id: 'ORD-20260705-003',
      productName: '살롱 전용 가운 (블랙)',
      productThumbnailUrl:
          'https://picsum.photos/seed/hairspare-store-apparel-1/200/200',
      quantity: 2,
      totalPrice: 70000,
      status: StoreOrderStatus.preparing,
      orderedAt: DateTime(2026, 7, 5, 18, 20),
      recipientName: '김디자이너',
      addressSummary: '경기 부천시 고강동 123-4',
    ),
  ];

  static final List<StoreShippingAddress> _addresses = [
    const StoreShippingAddress(
      id: 'addr-1',
      label: '살롱',
      recipientName: '김디자이너',
      phone: '010-1234-5678',
      addressLine: '경기 부천시 고강동 123-4',
      detailAddress: '2층 헤어스페어샵',
      isDefault: true,
    ),
    const StoreShippingAddress(
      id: 'addr-2',
      label: '집',
      recipientName: '김디자이너',
      phone: '010-1234-5678',
      addressLine: '경기 부천시 원미구 중동 45-1',
      detailAddress: '101동 1203호',
    ),
  ];

  Future<List<StoreOrder>> getOrders() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List<StoreOrder>.from(_orders);
  }

  Future<StoreOrder?> getOrderById(String id) async {
    await Future.delayed(const Duration(milliseconds: 120));
    for (final order in _orders) {
      if (order.id == id) return order;
    }
    return null;
  }

  Future<List<StoreShippingAddress>> getAddresses() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return List<StoreShippingAddress>.from(_addresses);
  }

  Future<void> setDefaultAddress(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    for (var i = 0; i < _addresses.length; i++) {
      final a = _addresses[i];
      _addresses[i] = StoreShippingAddress(
        id: a.id,
        label: a.label,
        recipientName: a.recipientName,
        phone: a.phone,
        addressLine: a.addressLine,
        detailAddress: a.detailAddress,
        isDefault: a.id == id,
      );
    }
  }
}
