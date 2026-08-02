import '../core/di/service_locator.dart';
import '../models/store_seller.dart';
import '../models/store_product.dart';
import 'store_service.dart';

/// 스토어 판매자 서비스 — 아직 실 백엔드 연동 전이라 mock 데이터만 제공.
class StoreSellerService {
  static final List<StoreSeller> _sellers = [
    StoreSeller(
      id: 'seller-hairspare-official',
      shopName: 'HairSpare 공식스토어',
      ownerName: 'HairSpare',
      status: StoreSellerStatus.approved,
      appliedAt: DateTime(2026, 1, 5),
      approvedAt: DateTime(2026, 1, 6),
      introText: 'HairSpare가 직접 검수한 프로 시술 도구만 모았습니다.',
    ),
    StoreSeller(
      id: 'seller-junscissors',
      shopName: '준가위 공구몰',
      ownerName: '김준호',
      businessNumber: '123-45-67890',
      status: StoreSellerStatus.approved,
      appliedAt: DateTime(2026, 3, 2),
      approvedAt: DateTime(2026, 3, 4),
      introText: '20년 경력 헤어디자이너가 고른 가위 전문 셀렉샵입니다.',
    ),
    StoreSeller(
      id: 'seller-herzen',
      shopName: '헤르젠 뷰티서플라이',
      ownerName: '박은주',
      businessNumber: '234-56-78901',
      status: StoreSellerStatus.approved,
      appliedAt: DateTime(2026, 4, 10),
      approvedAt: DateTime(2026, 4, 12),
      introText: '살롱 전용 뷰티 서플라이 — 대용량·업소용 특가로 만나보세요.',
    ),
    StoreSeller(
      id: 'seller-curlstar',
      shopName: '컬리스타 헤어툴',
      ownerName: '이도현',
      businessNumber: '345-67-89012',
      status: StoreSellerStatus.approved,
      appliedAt: DateTime(2026, 5, 8),
      approvedAt: DateTime(2026, 5, 10),
      introText: '펌·컬 전문 도구 브랜드, 컬리스타의 공식 스토어입니다.',
    ),
    StoreSeller(
      id: 'seller-keracis',
      shopName: '케라시스 프로 스토어',
      ownerName: '정수민',
      businessNumber: '456-78-90123',
      status: StoreSellerStatus.approved,
      appliedAt: DateTime(2026, 5, 20),
      approvedAt: DateTime(2026, 5, 22),
      introText: '손상모 케어 전문 케라시스 프로 라인을 소개합니다.',
    ),
    StoreSeller(
      id: 'seller-colorlab',
      shopName: '컬러랩 케미컬',
      ownerName: '한지민',
      businessNumber: '567-89-01234',
      status: StoreSellerStatus.approved,
      appliedAt: DateTime(2026, 6, 1),
      approvedAt: DateTime(2026, 6, 3),
      introText: '저자극 컬러·케미컬 전문 연구소, 컬러랩입니다.',
    ),
    StoreSeller(
      id: 'seller-bomne',
      shopName: '봄이네뷰티',
      ownerName: '최봄',
      businessNumber: '678-90-12345',
      status: StoreSellerStatus.pending,
      appliedAt: DateTime(2026, 7, 20),
      introText: '합리적인 가격의 헤어 소모품을 준비 중입니다.',
    ),
  ];

  /// 셀러별 팔로워수 (mock) — 실 백엔드가 붙으면 셀러 집계 API 응답으로 대체된다.
  /// 목록에 없는 셀러(신규 승인 등)는 0명으로 본다.
  static const Map<String, int> _mockFollowerCounts = {
    'seller-hairspare-official': 482,
    'seller-junscissors': 216,
    'seller-herzen': 138,
    'seller-curlstar': 97,
    'seller-keracis': 64,
    'seller-colorlab': 41,
  };

  Future<List<StoreSeller>> getSellers({StoreSellerStatus? status}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    if (status == null) return List<StoreSeller>.from(_sellers);
    return _sellers.where((s) => s.status == status).toList();
  }

  Future<StoreSeller?> getSellerById(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return getSellerByIdSync(id);
  }

  /// [getSellerById]의 동기 버전 — 장바구니 판매자별 그룹핑처럼 화면에서
  /// 이미 메모리에 있는 mock 목록을 즉시 조회해야 할 때 사용.
  StoreSeller? getSellerByIdSync(String id) {
    for (final seller in _sellers) {
      if (seller.id == id) return seller;
    }
    return null;
  }

  /// 스토어 판매자 신청 (mock) — 실제로는 대기 상태로 등록되어 관리자 승인을 기다림.
  Future<StoreSeller> applyAsSeller({
    required String shopName,
    required String ownerName,
    String? businessNumber,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final seller = StoreSeller(
      id: 'seller-${DateTime.now().millisecondsSinceEpoch}',
      shopName: shopName,
      ownerName: ownerName,
      businessNumber: businessNumber,
      status: StoreSellerStatus.pending,
      appliedAt: DateTime.now(),
    );
    _sellers.add(seller);
    return seller;
  }

  /// 관리자 승인 (mock).
  Future<void> approveSeller(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _sellers.indexWhere((s) => s.id == id);
    if (index == -1) return;
    final s = _sellers[index];
    _sellers[index] = StoreSeller(
      id: s.id,
      shopName: s.shopName,
      ownerName: s.ownerName,
      businessNumber: s.businessNumber,
      status: StoreSellerStatus.approved,
      appliedAt: s.appliedAt,
      approvedAt: DateTime.now(),
      logoUrl: s.logoUrl,
      introText: s.introText,
    );
  }

  /// 관리자 반려 (mock).
  Future<void> rejectSeller(String id, {String? reason}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _sellers.indexWhere((s) => s.id == id);
    if (index == -1) return;
    final s = _sellers[index];
    _sellers[index] = StoreSeller(
      id: s.id,
      shopName: s.shopName,
      ownerName: s.ownerName,
      businessNumber: s.businessNumber,
      status: StoreSellerStatus.rejected,
      appliedAt: s.appliedAt,
      rejectReason: reason,
      logoUrl: s.logoUrl,
      introText: s.introText,
    );
  }

  /// 승인된 셀러의 상품수·평균 별점·팔로워수를 집계 — 평균 별점 내림차순, 동률이면 상품수 내림차순.
  Future<List<StoreSellerSummary>> getSellerSummaries(
    List<StoreProduct> allProducts,
  ) async {
    final approved = await getSellers(status: StoreSellerStatus.approved);
    final summaries = approved.map((seller) {
      final products = allProducts
          .where((p) => p.sellerId == seller.id)
          .toList();
      final totalReviews = products.fold<int>(
        0,
        (sum, p) => sum + p.reviewCount,
      );
      final ratingSum = products.fold<double>(
        0,
        (sum, p) => sum + p.averageRating * p.reviewCount,
      );
      final averageRating = totalReviews == 0 ? 0.0 : ratingSum / totalReviews;
      return StoreSellerSummary(
        seller: seller,
        productCount: products.length,
        averageRating: averageRating,
        followerCount: _mockFollowerCounts[seller.id] ?? 0,
      );
    }).toList();

    summaries.sort((a, b) {
      final byRating = b.averageRating.compareTo(a.averageRating);
      if (byRating != 0) return byRating;
      return b.productCount.compareTo(a.productCount);
    });
    return summaries;
  }

  /// [sellerId]의 모든 상품에 달린 리뷰를 최신순으로 모아 반환 — 스토어 프로필
  /// 페이지 "리뷰" 탭용.
  Future<List<StoreSellerReviewEntry>> getSellerReviews(
    String sellerId,
  ) async {
    final products = await sl<StoreService>().getProductsBySeller(sellerId);
    final entries = <StoreSellerReviewEntry>[
      for (final product in products)
        for (final review in product.reviews)
          StoreSellerReviewEntry(
            productId: product.id,
            productName: product.name,
            review: review,
          ),
    ];
    entries.sort((a, b) => b.review.createdAt.compareTo(a.review.createdAt));
    return entries;
  }
}
