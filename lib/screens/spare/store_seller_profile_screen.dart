import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/di/service_locator.dart';
import '../../core/router/app_routes.dart';
import '../../models/store_product.dart';
import '../../models/store_seller.dart';
import '../../providers/store_seller_follow_provider.dart';
import '../../providers/store_wishlist_provider.dart';
import '../../services/store_seller_service.dart';
import '../../services/store_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/hairspare_colors.dart';
import '../../utils/error_handler.dart';
import '../../widgets/common/spare_subpage_app_bar.dart';
import '../../widgets/store/store_product_card.dart';

/// 스토어 셀러 프로필 페이지 — 로고·소개글·통계·팔로우 + 상품/리뷰 탭.
/// "인기 스토어" 카드, "전체 스토어" 목록에서 진입.
class StoreSellerProfileScreen extends StatefulWidget {
  const StoreSellerProfileScreen({super.key, required this.sellerId});

  final String sellerId;

  @override
  State<StoreSellerProfileScreen> createState() =>
      _StoreSellerProfileScreenState();
}

class _StoreSellerProfileScreenState extends State<StoreSellerProfileScreen>
    with SingleTickerProviderStateMixin {
  final StoreSellerService _sellerService = sl<StoreSellerService>();
  final StoreService _storeService = sl<StoreService>();
  late final TabController _tabController;

  StoreSellerSummary? _summary;
  List<StoreProduct> _products = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final allProducts = await _storeService.getProducts();
      final summaries = await _sellerService.getSellerSummaries(allProducts);
      final sellerProducts = await _storeService.getProductsBySeller(
        widget.sellerId,
      );
      if (!mounted) return;
      final matches = summaries.where((s) => s.seller.id == widget.sellerId);
      setState(() {
        _summary = matches.isEmpty ? null : matches.first;
        _products = sellerProducts;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      final appException = ErrorHandler.handleException(error);
      setState(() {
        _error = ErrorHandler.getUserFriendlyMessage(appException);
        _isLoading = false;
      });
    }
  }

  List<StoreProduct> get _filteredProducts {
    if (_searchQuery.isEmpty) return _products;
    final query = _searchQuery.toLowerCase();
    return _products
        .where((p) => p.name.toLowerCase().contains(query))
        .toList();
  }

  void _openProductDetail(StoreProduct product) {
    context.push(AppRoutes.spareHomeStoreProductDetail(product.id));
  }

  @override
  Widget build(BuildContext context) {
    final summary = _summary;
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: SpareSubpageAppBar(
        title: summary?.seller.shopName ?? '스토어',
        showToolbarActions: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_error!),
                  const SizedBox(height: AppTheme.spacing3),
                  TextButton(onPressed: _load, child: const Text('다시 시도')),
                ],
              ),
            )
          : summary == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _ProfileHeader(summary: summary),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing4,
                  ),
                  child: TextField(
                    onChanged: (value) =>
                        setState(() => _searchQuery = value),
                    decoration: InputDecoration(
                      hintText: '${summary.seller.shopName} 상품 검색',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: HairSpareColors.surfaceMuted,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusLg,
                        ),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacing2),
                TabBar(
                  controller: _tabController,
                  labelColor: HairSpareColors.brandPrimary,
                  unselectedLabelColor: HairSpareColors.textSecondary,
                  indicatorColor: HairSpareColors.brandPrimary,
                  tabs: const [Tab(text: '상품'), Tab(text: '리뷰')],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _ProductGrid(
                        products: _filteredProducts,
                        onTapProduct: _openProductDetail,
                      ),
                      _SellerReviewsTab(sellerId: widget.sellerId),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.summary});

  final StoreSellerSummary summary;

  @override
  Widget build(BuildContext context) {
    final seller = summary.seller;
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacing4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: HairSpareColors.brandPrimarySoft,
            child: Text(
              seller.shopName.substring(0, 1),
              style: const TextStyle(
                color: HairSpareColors.brandPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 22,
              ),
            ),
          ),
          const SizedBox(width: AppTheme.spacing3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  seller.shopName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: HairSpareColors.textPrimary,
                  ),
                ),
                if (seller.introText != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    seller.introText!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: HairSpareColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Consumer<StoreSellerFollowProvider>(
                  builder: (context, follow, _) {
                    final isFollowing = follow.isFollowing(seller.id);
                    final followerCount = follow.displayFollowerCount(
                      seller.id,
                      summary.followerCount,
                    );
                    return Row(
                      children: [
                        Expanded(
                          child: Text(
                            '상품 ${summary.productCount} · ★${summary.averageRating.toStringAsFixed(1)} · 팔로워 $followerCount',
                            style: const TextStyle(
                              fontSize: 12,
                              color: HairSpareColors.textSecondary,
                            ),
                          ),
                        ),
                        OutlinedButton(
                          onPressed: () => follow.toggle(seller.id),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: isFollowing
                                  ? HairSpareColors.border
                                  : HairSpareColors.brandPrimary,
                            ),
                            foregroundColor: isFollowing
                                ? HairSpareColors.textSecondary
                                : HairSpareColors.brandPrimary,
                          ),
                          child: Text(isFollowing ? '팔로잉' : '+ 팔로우'),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductGrid extends StatelessWidget {
  const _ProductGrid({required this.products, required this.onTapProduct});

  final List<StoreProduct> products;
  final ValueChanged<StoreProduct> onTapProduct;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const Center(child: Text('검색 결과가 없습니다'));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(AppTheme.spacing4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppTheme.spacing4,
        crossAxisSpacing: AppTheme.spacing3,
        childAspectRatio: 0.54,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Consumer<StoreWishlistProvider>(
          builder: (context, wishlist, _) {
            return StoreProductCard(
              product: product,
              onTap: () => onTapProduct(product),
              isWishlisted: wishlist.isWishlisted(product.id),
              onWishlistToggle: () => wishlist.toggle(product),
            );
          },
        );
      },
    );
  }
}

class _SellerReviewsTab extends StatefulWidget {
  const _SellerReviewsTab({required this.sellerId});

  final String sellerId;

  @override
  State<_SellerReviewsTab> createState() => _SellerReviewsTabState();
}

class _SellerReviewsTabState extends State<_SellerReviewsTab> {
  final StoreSellerService _sellerService = sl<StoreSellerService>();
  List<StoreSellerReviewEntry> _entries = [];
  bool _isLoading = true;

  static final _dateFmt = DateFormat('yyyy.MM.dd');

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final entries = await _sellerService.getSellerReviews(widget.sellerId);
    if (!mounted) return;
    setState(() {
      _entries = entries;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_entries.isEmpty) {
      return const Center(child: Text('아직 등록된 리뷰가 없습니다'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppTheme.spacing4),
      itemCount: _entries.length,
      separatorBuilder: (_, __) =>
          const SizedBox(height: AppTheme.spacing3),
      itemBuilder: (context, index) {
        final entry = _entries[index];
        return Container(
          padding: const EdgeInsets.all(AppTheme.spacing3),
          decoration: BoxDecoration(
            color: HairSpareColors.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(color: HairSpareColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    entry.review.userName,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: HairSpareColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '★' * entry.review.rating,
                    style: const TextStyle(
                      fontSize: 12,
                      color: HairSpareColors.brandPrimary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _dateFmt.format(entry.review.createdAt),
                    style: const TextStyle(
                      fontSize: 11,
                      color: HairSpareColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                entry.productName,
                style: const TextStyle(
                  fontSize: 11,
                  color: HairSpareColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                entry.review.comment,
                style: const TextStyle(
                  fontSize: 13,
                  color: HairSpareColors.textStrong,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
