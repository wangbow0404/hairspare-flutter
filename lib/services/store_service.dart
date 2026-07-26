import '../models/store_product.dart';
import '../utils/app_exception.dart';

/// 스토어(미용 도구·용품) 서비스 — 아직 실 백엔드 연동 전이라 mock 데이터만 제공.
class StoreService {
  static List<StoreProductReview> _daysAgoReviews(
    List<(String, int, String, int)> entries,
  ) {
    final now = DateTime.now();
    return entries
        .map(
          (e) => StoreProductReview(
            userName: e.$1,
            rating: e.$2,
            comment: e.$3,
            createdAt: now.subtract(Duration(days: e.$4)),
          ),
        )
        .toList();
  }

  static final List<StoreProduct> _mockProducts = [
    StoreProduct(
      id: 'store-scissors-1',
      name: '프로 커팅 가위 6인치',
      brand: '하츠',
      category: StoreProductCategory.scissors,
      price: 89000,
      originalPrice: 128000,
      imageUrls: const [
        'https://picsum.photos/seed/hairspare-store-scissors-1/600/600',
      ],
      description:
          '일본산 코발트 합금 소재로 날이 오래 유지되는 프로용 커팅 가위입니다. 손목 부담을 줄여주는 인체공학 손잡이 설계.',
      isBestSeller: true,
      tags: const ['무료배송', 'MD추천'],
      reviews: _daysAgoReviews([
        ('김디자이너', 5, '손에 착 감기고 날이 오래가요. 재구매 의사 100%입니다.', 3),
        ('이헤어', 5, '가격 대비 정말 만족스러운 커팅감이에요.', 9),
        ('박스타일', 4, '무게감이 살짝 있는 편인데 그립감이 좋아서 금방 적응됐어요.', 21),
      ]),
    ),
    StoreProduct(
      id: 'store-scissors-2',
      name: '틴닝 가위 (숱가위) 30단',
      brand: '준가위',
      category: StoreProductCategory.scissors,
      price: 65000,
      imageUrls: const [
        'https://picsum.photos/seed/hairspare-store-scissors-2/600/600',
      ],
      description: '30단 세밀한 톱니로 자연스러운 숱 정리가 가능한 틴닝 가위. 초보자도 다루기 쉬운 무게감.',
    ),
    StoreProduct(
      id: 'store-tools-1',
      name: '이온 고속 드라이기 프로',
      brand: '헤어메이트',
      category: StoreProductCategory.tools,
      price: 159000,
      originalPrice: 199000,
      imageUrls: const [
        'https://picsum.photos/seed/hairspare-store-tools-1/600/600',
      ],
      description:
          '마이너스 이온 케어로 모발 손상을 줄이는 살롱용 고속 드라이기. 2.0m 롱 코드로 작업 편의성을 높였습니다.',
      isBestSeller: true,
      tags: const ['무료배송'],
      reviews: _daysAgoReviews([
        ('최미용', 5, '건조 속도가 확실히 빨라져서 시술 회전율이 좋아졌어요.', 5),
        ('정헤어샵', 4, '소음이 조금 있지만 파워는 확실합니다.', 14),
      ]),
    ),
    StoreProduct(
      id: 'store-tools-2',
      name: '티타늄 고데기 32mm',
      brand: '컬리스타',
      category: StoreProductCategory.tools,
      price: 72000,
      imageUrls: const [
        'https://picsum.photos/seed/hairspare-store-tools-2/600/600',
      ],
      description: '균일한 온도 유지가 강점인 티타늄 코팅 고데기. 자연스러운 웨이브 연출에 적합한 32mm.',
    ),
    StoreProduct(
      id: 'store-tools-3',
      name: '무선 헤어 아이론',
      brand: '컬리스타',
      category: StoreProductCategory.tools,
      price: 98000,
      imageUrls: const [
        'https://picsum.photos/seed/hairspare-store-tools-3/600/600',
      ],
      description: '출장 시술에 특화된 무선 충전식 아이론. 완충 시 최대 40분 연속 사용 가능.',
      tags: const ['신상품'],
    ),
    StoreProduct(
      id: 'store-perm-1',
      name: '저자극 매직 스트레이트 약',
      brand: '케라시스 프로',
      category: StoreProductCategory.perm,
      price: 45000,
      imageUrls: const [
        'https://picsum.photos/seed/hairspare-store-perm-1/600/600',
      ],
      description: '두피 자극을 최소화한 살롱 전용 스트레이트 펌제. 1·2제 세트 구성.',
    ),
    StoreProduct(
      id: 'store-perm-2',
      name: '데미지 케어 염색약 세트',
      brand: '컬러랩',
      category: StoreProductCategory.perm,
      price: 38000,
      originalPrice: 52000,
      imageUrls: const [
        'https://picsum.photos/seed/hairspare-store-perm-2/600/600',
      ],
      description: '염색과 동시에 모발 손상 케어가 가능한 트리트먼트 염모제.',
      tags: const ['무료배송'],
      reviews: _daysAgoReviews([('조컬러', 4, '발색이 선명하고 손상도 덜한 것 같아요.', 6)]),
    ),
    StoreProduct(
      id: 'store-haircare-1',
      name: '살롱 전용 샴푸 1L',
      brand: '헤르젠',
      category: StoreProductCategory.hairCare,
      price: 32000,
      imageUrls: const [
        'https://picsum.photos/seed/hairspare-store-haircare-1/600/600',
      ],
      description: '두피 밸런스를 맞춰주는 약산성 살롱 전용 샴푸. 대용량 1L 리필형.',
      isBestSeller: true,
      reviews: _daysAgoReviews([
        ('한스타일', 5, '두피가 덜 예민해지는 느낌이에요. 손님들 반응도 좋습니다.', 2),
        ('윤디자이너', 5, '향도 은은하고 세정력도 좋아요.', 8),
        ('강샵', 3, '용량 대비 가격이 조금 아쉬워요.', 30),
      ]),
    ),
    StoreProduct(
      id: 'store-haircare-2',
      name: '단백질 트리트먼트 팩',
      brand: '헤르젠',
      category: StoreProductCategory.hairCare,
      price: 41000,
      imageUrls: const [
        'https://picsum.photos/seed/hairspare-store-haircare-2/600/600',
      ],
      description: '시술 후 손상모 집중 케어용 단백질 트리트먼트. 5분 방치 후 헹굼.',
    ),
    StoreProduct(
      id: 'store-supplies-1',
      name: '일회용 위생 가운 (50매)',
      brand: '하츠',
      category: StoreProductCategory.supplies,
      price: 18000,
      imageUrls: const [
        'https://picsum.photos/seed/hairspare-store-supplies-1/600/600',
      ],
      description: '시술 시 옷 오염을 방지하는 일회용 위생 가운 50매입.',
      tags: const ['무료배송'],
    ),
    StoreProduct(
      id: 'store-supplies-2',
      name: '알루미늄 호일 (500매)',
      brand: '준가위',
      category: StoreProductCategory.supplies,
      price: 9800,
      imageUrls: const [
        'https://picsum.photos/seed/hairspare-store-supplies-2/600/600',
      ],
      description: '염색 시술용 알루미늄 호일 500매. 절취선으로 편리하게 사용.',
    ),
    StoreProduct(
      id: 'store-supplies-3',
      name: '롤빗 세트 (10개입)',
      brand: '헤어메이트',
      category: StoreProductCategory.supplies,
      price: 15000,
      imageUrls: const [
        'https://picsum.photos/seed/hairspare-store-supplies-3/600/600',
      ],
      description: '사이즈별로 구성된 롤빗 10개 세트. 블로우 드라이 스타일링에 필수.',
    ),
    StoreProduct(
      id: 'store-apparel-1',
      name: '발수 커트보 (다크그레이)',
      brand: '헤르젠',
      category: StoreProductCategory.apparel,
      price: 22000,
      originalPrice: 28000,
      imageUrls: const [
        'https://picsum.photos/seed/hairspare-store-apparel-1/600/600',
      ],
      description: '물과 커트 잔모가 잘 스며들지 않는 발수 원단 커트보.',
      reviews: _daysAgoReviews([
        ('임원장', 5, '물이 스며들지 않아서 관리가 훨씬 편해졌어요.', 11),
        ('서헤어', 4, '색상도 고급스럽고 재질이 튼튼합니다.', 25),
      ]),
    ),
    StoreProduct(
      id: 'store-apparel-2',
      name: '초극세사 헤어 타올 (3매)',
      brand: '케라시스 프로',
      category: StoreProductCategory.apparel,
      price: 19000,
      imageUrls: const [
        'https://picsum.photos/seed/hairspare-store-apparel-2/600/600',
      ],
      description: '빠른 흡수와 건조가 특징인 초극세사 헤어 타올 3매 세트.',
      tags: const ['신상품'],
    ),
  ];

  /// 상품 목록 조회 — [category]·[sort]·[searchQuery] 필터.
  Future<List<StoreProduct>> getProducts({
    StoreProductCategory? category,
    StoreSortFilter sort = StoreSortFilter.all,
    String? searchQuery,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    var results = List<StoreProduct>.from(_mockProducts);

    if (category != null) {
      results = results.where((p) => p.category == category).toList();
    }
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final query = searchQuery.trim().toLowerCase();
      results = results
          .where(
            (p) =>
                p.name.toLowerCase().contains(query) ||
                p.brand.toLowerCase().contains(query),
          )
          .toList();
    }

    switch (sort) {
      case StoreSortFilter.all:
        break;
      case StoreSortFilter.recommended:
        results = results
            .where((p) => p.isBestSeller || p.reviewCount > 0)
            .toList();
      case StoreSortFilter.bestSeller:
        results = results.where((p) => p.isBestSeller).toList();
      case StoreSortFilter.onSale:
        results = results.where((p) => p.hasDiscount).toList();
      case StoreSortFilter.newest:
        results = results
            .where((p) => p.tags.contains('신상품'))
            .toList();
    }

    return results;
  }

  /// 쇼핑 탭 상단 프로모 배너 (mock).
  Future<List<StorePromoBanner>> getPromoBanners() async {
    await Future.delayed(const Duration(milliseconds: 120));
    return const [
      StorePromoBanner(
        id: 'banner-deal-1',
        title: '프로 가위 특가 ~40%',
        subtitle: '베스트셀러 + 포인트 5% 적립',
        ctaLabel: '쿠폰 받기',
        imageUrl:
            'https://picsum.photos/seed/hairspare-store-banner-1/800/400',
      ),
      StorePromoBanner(
        id: 'banner-deal-2',
        title: '드라이기·고데기 여름 세일',
        subtitle: '살롱 필수템 한정 할인',
        ctaLabel: '특가 상품 보기',
        imageUrl:
            'https://picsum.photos/seed/hairspare-store-banner-2/800/400',
      ),
    ];
  }

  /// 상품 상세 조회.
  Future<StoreProduct> getProductById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _mockProducts.firstWhere(
      (p) => p.id == id,
      orElse: () => throw NotFoundException('상품을 찾을 수 없습니다.'),
    );
  }
}
