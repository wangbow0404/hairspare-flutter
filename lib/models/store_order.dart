/// 스토어 주문 상태.
enum StoreOrderStatus {
  paid('결제완료'),
  preparing('상품준비중'),
  shipping('배송중'),
  delivered('배송완료'),
  cancelled('주문취소');

  const StoreOrderStatus(this.label);
  final String label;
}

/// 스토어 주문 1건.
class StoreOrder {
  const StoreOrder({
    required this.id,
    required this.productName,
    required this.productThumbnailUrl,
    required this.quantity,
    required this.totalPrice,
    required this.status,
    required this.orderedAt,
    this.trackingNumber,
    this.carrierName = 'HairSpare택배',
    required this.recipientName,
    required this.addressSummary,
  });

  final String id;
  final String productName;
  final String productThumbnailUrl;
  final int quantity;
  final int totalPrice;
  final StoreOrderStatus status;
  final DateTime orderedAt;
  final String? trackingNumber;
  final String carrierName;
  final String recipientName;
  final String addressSummary;

  bool get canTrack =>
      trackingNumber != null &&
      (status == StoreOrderStatus.shipping ||
          status == StoreOrderStatus.delivered);
}

/// 배송지.
class StoreShippingAddress {
  const StoreShippingAddress({
    required this.id,
    required this.label,
    required this.recipientName,
    required this.phone,
    required this.addressLine,
    required this.detailAddress,
    this.isDefault = false,
  });

  final String id;
  final String label;
  final String recipientName;
  final String phone;
  final String addressLine;
  final String detailAddress;
  final bool isDefault;

  String get fullAddress => '$addressLine $detailAddress'.trim();
}
