import '../models/store_seller.dart';

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
    ),
    StoreSeller(
      id: 'seller-junscissors',
      shopName: '준가위 공구몰',
      ownerName: '김준호',
      businessNumber: '123-45-67890',
      status: StoreSellerStatus.approved,
      appliedAt: DateTime(2026, 3, 2),
      approvedAt: DateTime(2026, 3, 4),
    ),
    StoreSeller(
      id: 'seller-herzen',
      shopName: '헤르젠 뷰티서플라이',
      ownerName: '박은주',
      businessNumber: '234-56-78901',
      status: StoreSellerStatus.approved,
      appliedAt: DateTime(2026, 4, 10),
      approvedAt: DateTime(2026, 4, 12),
    ),
    StoreSeller(
      id: 'seller-curlstar',
      shopName: '컬리스타 헤어툴',
      ownerName: '이도현',
      businessNumber: '345-67-89012',
      status: StoreSellerStatus.approved,
      appliedAt: DateTime(2026, 5, 8),
      approvedAt: DateTime(2026, 5, 10),
    ),
    StoreSeller(
      id: 'seller-keracis',
      shopName: '케라시스 프로 스토어',
      ownerName: '정수민',
      businessNumber: '456-78-90123',
      status: StoreSellerStatus.approved,
      appliedAt: DateTime(2026, 5, 20),
      approvedAt: DateTime(2026, 5, 22),
    ),
    StoreSeller(
      id: 'seller-colorlab',
      shopName: '컬러랩 케미컬',
      ownerName: '한지민',
      businessNumber: '567-89-01234',
      status: StoreSellerStatus.approved,
      appliedAt: DateTime(2026, 6, 1),
      approvedAt: DateTime(2026, 6, 3),
    ),
    StoreSeller(
      id: 'seller-bomne',
      shopName: '봄이네뷰티',
      ownerName: '최봄',
      businessNumber: '678-90-12345',
      status: StoreSellerStatus.pending,
      appliedAt: DateTime(2026, 7, 20),
    ),
  ];

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
    );
  }
}
