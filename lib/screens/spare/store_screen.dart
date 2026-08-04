import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/di/service_locator.dart';
import '../../core/router/app_routes.dart';
import '../../models/store_product.dart';
import '../../models/store_seller.dart';
import '../../providers/cart_provider.dart';
import '../../providers/store_seller_follow_provider.dart';
import '../../providers/store_wishlist_provider.dart';
import '../../services/store_seller_service.dart';
import '../../services/store_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/hairspare_colors.dart';
import '../../utils/error_handler.dart';
import '../../utils/store_shell_actions.dart';
import '../../widgets/common/shimmer_box.dart';
import '../../widgets/common/spare_subpage_app_bar.dart';
import '../../widgets/design_system/hs_filter_chip.dart';
import '../../widgets/design_system/hs_search_bar.dart';
import '../../widgets/store/store_app_bar_actions.dart';
import '../../widgets/store/store_category_row.dart';
import '../../widgets/store/store_category_sheet.dart';
import '../../widgets/store/store_feature_shortcuts.dart';
import '../../widgets/store/store_product_card.dart';
import '../../widgets/store/store_promo_banner.dart';
import '../../widgets/store/store_seller_card.dart';

/// HairSpare 미용 도구·용품 스토어 — 커머스 UX 패턴(검색·배너·카테고리·필터·그리드).
class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key, this.sellerId});

  /// "살롱 베스트" 가로 레일 — 두 레일이 같은 상품을 노출하지 않는지 테스트에서 식별용.
  static const Key bestSellerRailKey = Key('store-best-sellers-rail');

  /// "지금 뜨는 스토어의 상품" 가로 레일.
  static const Key featuredSellerRailKey = Key(
    'store-featured-seller-products-rail',
  );

  /// 특정 셀러 상품만 보고 있을 때(예: "인기 스토어" 카드 탭) 설정됨.
  final String? sellerId;

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final StoreService _storeService = sl<StoreService>();
  final StoreSellerService _sellerService = sl<StoreSellerService>();
  StoreProductCategory? _selectedCategory;
  StoreSortFilter _sortFilter = StoreSortFilter.all;
  List<StoreProduct> _products = [];
  List<StoreProduct> _bestSellers = [];
  List<StorePromoBanner> _banners = [];
  List<StoreSellerSummary> _sellerSummaries = [];
  List<StoreProduct> _featuredSellerProducts = [];
  bool _isLoading = true;
  String? _error;
  String? _sellerFilter;

  @override
  void initState() {
    super.initState();
    _sellerFilter = widget.sellerId;
    _loadProducts();
    if (_sellerFilter == null) _loadHomeSections();
    StoreShellActions.openCategorySheet.addListener(_onCategorySheetRequested);
  }

  @override
  void dispose() {
    StoreShellActions.openCategorySheet.removeListener(
      _onCategorySheetRequested,
    );
    super.dispose();
  }

  void _onCategorySheetRequested() {
    if (!mounted) return;
    _openCategorySheet();
  }

  Future<void> _openCategorySheet() async {
    final picked = await StoreCategorySheet.show(
      context,
      selected: _selectedCategory,
    );
    if (!mounted || picked == _selectedCategory) return;
    _onCategorySelected(picked);
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _storeService.getProducts(
          category: _selectedCategory,
          sort: _sortFilter,
        ),
        _storeService.getPromoBanners(),
        // 살롱 베스트 레일은 정렬 칩(전체/특가/신상 등)과 무관하게 항상
        // 카테고리 기준 베스트셀러만 보여준다 (레일이 정렬에 따라 사라지는
        // 문제 방지).
        _storeService.getProducts(category: _selectedCategory),
      ]);
      if (!mounted) return;
      var products = results[0] as List<StoreProduct>;
      if (_sellerFilter != null) {
        products = products
            .where((p) => p.sellerId == _sellerFilter)
            .toList();
      }

      setState(() {
        _products = products;
        _banners = results[1] as List<StorePromoBanner>;
        _bestSellers = _sellerFilter != null
            ? []
            : (results[2] as List<StoreProduct>)
                  .where((p) => p.isBestSeller)
                  .take(6)
                  .toList();
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

  /// "인기 스토어"·"지금 뜨는 스토어의 상품" 섹션 로드.
  ///
  /// 이 두 섹션은 카테고리·정렬 칩과 무관하므로 [_loadProducts]와 분리해
  /// 최초 진입(그리고 셀러 필터 해제·당겨서 새로고침) 때만 불러온다.
  /// 칩을 누를 때마다 다시 부르면 불필요한 재조회 + 가로 스크롤 위치 초기화가
  /// 발생한다.
  Future<void> _loadHomeSections() async {
    try {
      final allProducts = await _storeService.getProducts();
      final sellerSummaries = await _sellerService.getSellerSummaries(
        allProducts,
      );
      final topSellerIds = sellerSummaries
          .take(6)
          .map((s) => s.seller.id)
          .toList();
      final featuredSellerProducts = await _storeService
          .getFeaturedSellerProducts(topSellerIds);
      if (!mounted) return;
      setState(() {
        _sellerSummaries = sellerSummaries;
        _featuredSellerProducts = featuredSellerProducts;
      });
    } catch (_) {
      // 부가 섹션이므로 실패해도 상품 목록 화면 전체를 에러로 덮지 않고
      // 해당 섹션만 숨긴다.
      if (!mounted) return;
      setState(() {
        _sellerSummaries = [];
        _featuredSellerProducts = [];
      });
    }
  }

  Future<void> _refresh() async {
    await Future.wait([
      _loadProducts(),
      if (_sellerFilter == null) _loadHomeSections(),
    ]);
  }

  void _onCategorySelected(StoreProductCategory? category) {
    if (_selectedCategory == category) return;
    setState(() => _selectedCategory = category);
    _loadProducts();
  }

  void _onSortSelected(StoreSortFilter sort) {
    if (_sortFilter == sort) return;
    setState(() => _sortFilter = sort);
    _loadProducts();
  }

  void _clearSellerFilter() {
    setState(() => _sellerFilter = null);
    _loadProducts();
    // 셀러 필터로 바로 진입한 경우엔 홈 섹션을 아직 못 불러왔으므로 이때 채운다.
    if (_sellerSummaries.isEmpty) _loadHomeSections();
  }

  void _openProductDetail(StoreProduct product) {
    context.push(AppRoutes.spareHomeStoreProductDetail(product.id));
  }

  void _openCart() => context.push(AppRoutes.spareHomeStoreCart);

  void _openWishlist() => context.push(AppRoutes.spareHomeStoreWishlist);

  void _openSearch() => context.push(AppRoutes.spareSearch);

  void _openAllSellers() => context.push(AppRoutes.spareHomeStoreAllSellers);

  void _openCouponBox() => context.push(AppRoutes.spareHomeStoreCouponBox);

  void _openOrders() => context.push(AppRoutes.spareHomeStoreMy);

  void _openRecentlyViewed() =>
      context.push(AppRoutes.spareHomeStoreRecentlyViewed);

  void _openSellerFromCard(StoreSeller seller) {
    context.push(AppRoutes.spareHomeStoreSellerProfile(seller.id));
  }

  String? get _sellerFilterName {
    final sellerId = _sellerFilter;
    if (sellerId == null) return null;
    return sl<StoreSellerService>().getSellerByIdSync(sellerId)?.shopName;
  }

  String get _gridSectionTitle {
    switch (_sortFilter) {
      case StoreSortFilter.all:
        return '전체 상품';
      case StoreSortFilter.recommended:
        return '프로 추천';
      case StoreSortFilter.bestSeller:
        return 'MD픽';
      case StoreSortFilter.onSale:
        return '특가 상품';
      case StoreSortFilter.newest:
        return '신상품';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: SpareSubpageAppBar(
        title: '스토어',
        showToolbarActions: false,
        trailingActions: [
          StoreWishlistAction(onPressed: _openWishlist),
          StoreCartAction(onPressed: _openCart),
          const SizedBox(width: AppTheme.spacing2),
        ],
      ),
      body: _isLoading
          ? const ProductGridSkeleton()
          : _error != null
          ? _ErrorState(message: _error!, onRetry: _loadProducts)
          : RefreshIndicator(
              onRefresh: _refresh,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: ColoredBox(
                      color: HairSpareColors.surface,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppTheme.spacing4,
                          AppTheme.spacing3,
                          AppTheme.spacing4,
                          AppTheme.spacing3,
                        ),
                        child: HsSearchBar(
                          hintText: '가위, 드라이기, 샴푸 검색',
                          onTap: _openSearch,
                        ),
                      ),
                    ),
                  ),
                  if (_sellerFilter != null)
                    SliverToBoxAdapter(
                      child: Container(
                        width: double.infinity,
                        color: HairSpareColors.brandPrimarySoft,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacing4,
                          vertical: AppTheme.spacing2,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${_sellerFilterName ?? '선택한'} 스토어 상품만 보는 중',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: HairSpareColors.brandPrimary,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: _clearSellerFilter,
                              child: const Text('전체보기'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  SliverToBoxAdapter(
                    child: ColoredBox(
                      color: HairSpareColors.surface,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          StorePromoBannerCarousel(banners: _banners),
                          const SizedBox(height: AppTheme.spacing3),
                          StoreCategoryRow(
                            selected: _selectedCategory,
                            onSelected: _onCategorySelected,
                          ),
                          const SizedBox(height: AppTheme.spacing2),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.spacing4,
                            ),
                            child: Row(
                              children: [
                                for (final sort in StoreSortFilter.values) ...[
                                  if (sort != StoreSortFilter.values.first)
                                    const SizedBox(width: AppTheme.spacing2),
                                  HsFilterChip(
                                    label: sort.label,
                                    isSelected: _sortFilter == sort,
                                    onTap: () => _onSortSelected(sort),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacing4),
                        ],
                      ),
                    ),
                  ),
                  if (_sellerFilter == null && _sellerSummaries.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: _SectionHeader(
                        title: '인기 스토어',
                        trailing: TextButton(
                          onPressed: _openAllSellers,
                          child: const Text('더보기 ›'),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 168,
                        child: Consumer<StoreSellerFollowProvider>(
                          builder: (context, follow, _) {
                            return ListView.separated(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppTheme.spacing4,
                              ),
                              itemCount: _sellerSummaries.take(6).length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: AppTheme.spacing3),
                              itemBuilder: (context, index) {
                                final summary = _sellerSummaries[index];
                                final sellerId = summary.seller.id;
                                return StoreSellerCard(
                                  summary: summary,
                                  isFollowing: follow.isFollowing(sellerId),
                                  followerCount: follow.displayFollowerCount(
                                    sellerId,
                                    summary.followerCount,
                                  ),
                                  onTap: () =>
                                      _openSellerFromCard(summary.seller),
                                  onFollowToggle: () => follow.toggle(
                                    sellerId,
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: AppTheme.spacing2),
                    ),
                  ],
                  if (_sellerFilter == null) ...[
                    SliverToBoxAdapter(child: _SectionHeader(title: '바로가기')),
                    SliverToBoxAdapter(
                      child: Consumer<CartProvider>(
                        builder: (context, cart, _) {
                          return Consumer<StoreWishlistProvider>(
                            builder: (context, wishlist, _) {
                              return StoreFeatureShortcuts(
                                cartCount: cart.totalCount,
                                wishlistCount: wishlist.count,
                                onCart: _openCart,
                                onWishlist: _openWishlist,
                                onOrders: _openOrders,
                                onAllSellers: _openAllSellers,
                                onCouponBox: _openCouponBox,
                                onRecentlyViewed: _openRecentlyViewed,
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: AppTheme.spacing2),
                    ),
                  ],
                  if (_bestSellers.isNotEmpty) ...[
                    SliverToBoxAdapter(child: _SectionHeader(title: '살롱 베스트')),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 266,
                        child: ListView.separated(
                          key: StoreScreen.bestSellerRailKey,
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacing4,
                          ),
                          itemCount: _bestSellers.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: AppTheme.spacing3),
                          itemBuilder: (context, index) {
                            final product = _bestSellers[index];
                            return SizedBox(
                              width: 156,
                              child: Consumer<StoreWishlistProvider>(
                                builder: (context, wishlist, _) {
                                  return StoreProductCard(
                                    product: product,
                                    onTap: () => _openProductDetail(product),
                                    isWishlisted: wishlist.isWishlisted(
                                      product.id,
                                    ),
                                    onWishlistToggle: () =>
                                        wishlist.toggle(product),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                  if (_sellerFilter == null &&
                      _featuredSellerProducts.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: _SectionHeader(title: '지금 뜨는 스토어의 상품'),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 266,
                        child: ListView.separated(
                          key: StoreScreen.featuredSellerRailKey,
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacing4,
                          ),
                          itemCount: _featuredSellerProducts.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: AppTheme.spacing3),
                          itemBuilder: (context, index) {
                            final product = _featuredSellerProducts[index];
                            return SizedBox(
                              width: 156,
                              child: Consumer<StoreWishlistProvider>(
                                builder: (context, wishlist, _) {
                                  return StoreProductCard(
                                    product: product,
                                    onTap: () => _openProductDetail(product),
                                    isWishlisted: wishlist.isWishlisted(
                                      product.id,
                                    ),
                                    onWishlistToggle: () =>
                                        wishlist.toggle(product),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                  SliverToBoxAdapter(
                    child: _SectionHeader(
                      title: _sellerFilter != null
                          ? '${_sellerFilterName ?? ''} 상품'
                          : _gridSectionTitle,
                    ),
                  ),
                  if (_products.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: _EmptyState(),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        AppTheme.spacing4,
                        0,
                        AppTheme.spacing4,
                        AppTheme.spacing6,
                      ),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: AppTheme.spacing4,
                              crossAxisSpacing: AppTheme.spacing3,
                              childAspectRatio: 0.54,
                            ),
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final product = _products[index];
                          return Consumer<StoreWishlistProvider>(
                            builder: (context, wishlist, _) {
                              return StoreProductCard(
                                product: product,
                                onTap: () => _openProductDetail(product),
                                isWishlisted: wishlist.isWishlisted(product.id),
                                onWishlistToggle: () =>
                                    wishlist.toggle(product),
                              );
                            },
                          );
                        }, childCount: _products.length),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacing4,
        AppTheme.spacing2,
        AppTheme.spacing2,
        AppTheme.spacing3,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: HairSpareColors.textPrimary,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.shopping_bag_outlined,
            size: 64,
            color: AppTheme.textTertiary,
          ),
          const SizedBox(height: AppTheme.spacing4),
          Text(
            '해당 조건에 맞는 상품이 없습니다',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: AppTheme.textTertiary,
          ),
          const SizedBox(height: AppTheme.spacing3),
          Text(
            message,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: AppTheme.spacing3),
          TextButton(onPressed: onRetry, child: const Text('다시 시도')),
        ],
      ),
    );
  }
}
