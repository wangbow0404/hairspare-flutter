/// 스토어 상품 카테고리.
enum StoreProductCategory {
  scissors('가위'),
  tools('드라이기·고데기'),
  perm('펌·염색'),
  hairCare('샴푸·트리트먼트'),
  supplies('소모품'),
  apparel('가운·타올');

  const StoreProductCategory(this.label);
  final String label;
}

/// 스토어(미용 도구·용품) 상품.
class StoreProduct {
  const StoreProduct({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.price,
    required this.imageUrls,
    required this.description,
    this.originalPrice,
    this.isBestSeller = false,
    this.tags = const [],
    this.stock = 999,
  });

  final String id;
  final String name;
  final String brand;
  final StoreProductCategory category;
  final int price;
  final int? originalPrice;
  final List<String> imageUrls;
  final String description;
  final bool isBestSeller;
  final List<String> tags;
  final int stock;

  bool get isSoldOut => stock <= 0;

  bool get hasDiscount => originalPrice != null && originalPrice! > price;

  /// 할인율 (%) — 할인 없으면 0.
  int get discountPercent {
    if (!hasDiscount) return 0;
    return (((originalPrice! - price) / originalPrice!) * 100).round();
  }

  String get thumbnailUrl => imageUrls.isNotEmpty ? imageUrls.first : '';
}
