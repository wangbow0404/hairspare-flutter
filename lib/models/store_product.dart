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

/// 스토어 목록 정렬·필터.
enum StoreSortFilter {
  all('전체'),
  recommended('프로추천'),
  bestSeller('MD픽'),
  onSale('특가'),
  newest('신상');

  const StoreSortFilter(this.label);
  final String label;
}

/// 스토어 프로모 배너.
class StorePromoBanner {
  const StorePromoBanner({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    this.imageUrl,
  });

  final String id;
  final String title;
  final String subtitle;
  final String ctaLabel;
  final String? imageUrl;
}

/// 상품 옵션 값 1개 (예: 색상 그룹의 "블랙").
class StoreProductOptionValue {
  const StoreProductOptionValue({
    required this.label,
    this.priceDelta = 0,
    this.stock,
  });

  final String label;

  /// 이 옵션 선택 시 기본가에 추가되는 금액 (없으면 0).
  final int priceDelta;

  /// 옵션별 재고 — null이면 상품 전체 재고([StoreProduct.stock])를 따름.
  final int? stock;
}

/// 상품 옵션 그룹 (예: "색상", "사이즈") — 판매자가 등록 시 지정.
class StoreProductOptionGroup {
  const StoreProductOptionGroup({required this.name, required this.values});

  final String name;
  final List<StoreProductOptionValue> values;
}

/// 스토어 상품 리뷰 1건.
class StoreProductReview {
  const StoreProductReview({
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  final String userName;
  final int rating; // 1~5
  final String comment;
  final DateTime createdAt;
}

/// 스토어(미용 도구·용품) 상품.
class StoreProduct {
  const StoreProduct({
    required this.id,
    required this.name,
    required this.brand,
    required this.sellerId,
    required this.category,
    required this.price,
    required this.imageUrls,
    required this.description,
    this.originalPrice,
    this.isBestSeller = false,
    this.tags = const [],
    this.stock = 999,
    this.reviews = const [],
    this.optionGroups = const [],
  });

  final String id;
  final String name;
  final String brand;

  /// 이 상품을 등록한 스토어 판매자 ([StoreSeller.id]).
  final String sellerId;
  final StoreProductCategory category;
  final int price;
  final int? originalPrice;
  final List<String> imageUrls;
  final String description;
  final bool isBestSeller;
  final List<String> tags;
  final int stock;
  final List<StoreProductReview> reviews;
  final List<StoreProductOptionGroup> optionGroups;

  bool get hasOptions => optionGroups.isNotEmpty;

  bool get isSoldOut => stock <= 0;

  bool get hasDiscount => originalPrice != null && originalPrice! > price;

  /// 할인율 (%) — 할인 없으면 0.
  int get discountPercent {
    if (!hasDiscount) return 0;
    return (((originalPrice! - price) / originalPrice!) * 100).round();
  }

  String get thumbnailUrl => imageUrls.isNotEmpty ? imageUrls.first : '';

  int get reviewCount => reviews.length;

  double get averageRating {
    if (reviews.isEmpty) return 0;
    final total = reviews.fold<int>(0, (sum, r) => sum + r.rating);
    return total / reviews.length;
  }
}
