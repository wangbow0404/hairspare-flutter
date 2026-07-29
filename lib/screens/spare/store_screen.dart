import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/di/service_locator.dart';
import '../../core/router/app_routes.dart';
import '../../models/store_product.dart';
import '../../providers/cart_provider.dart';
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
import '../../widgets/store/store_category_row.dart';
import '../../widgets/store/store_category_sheet.dart';
import '../../widgets/store/store_product_card.dart';
import '../../widgets/store/store_promo_banner.dart';

/// HairSpare 미용 도구·용품 스토어 — 커머스 UX 패턴(검색·배너·카테고리·필터·그리드).
class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key, this.sellerId});

  /// 특정 셀러 상품만 보고 있을 때(예: "인기 스토어" 카드 탭) 설정됨.
  final String? sellerId;

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final StoreService _storeService = sl<StoreService>();
  StoreProductCategory? _selectedCategory;
  StoreSortFilter _sortFilter = StoreSortFilter.all;
  List<StoreProduct> _products = [];
  List<StoreProduct> _bestSellers = [];
  List<StorePromoBanner> _banners = [];
  bool _isLoading = true;
  String? _error;
  String? _sellerFilter;

  @override
  void initState() {
    super.initState();
    _sellerFilter = widget.sellerId;
    _loadProducts();
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
  }

  void _openProductDetail(StoreProduct product) {
    context.push(AppRoutes.spareHomeStoreProductDetail(product.id));
  }

  void _openCart() => context.push(AppRoutes.spareHomeStoreCart);

  void _openWishlist() => context.push(AppRoutes.spareHomeStoreWishlist);

  void _openSearch() => context.push(AppRoutes.spareSearch);

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
          _WishlistAction(onPressed: _openWishlist),
          _CartAction(onPressed: _openCart),
          const SizedBox(width: AppTheme.spacing2),
        ],
      ),
      body: _isLoading
          ? const ProductGridSkeleton()
          : _error != null
          ? _ErrorState(message: _error!, onRetry: _loadProducts)
          : RefreshIndicator(
              onRefresh: _loadProducts,
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
                  if (_bestSellers.isNotEmpty) ...[
                    SliverToBoxAdapter(child: _SectionHeader(title: '살롱 베스트')),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 248,
                        child: ListView.separated(
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
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacing4,
        AppTheme.spacing2,
        AppTheme.spacing4,
        AppTheme.spacing3,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w800,
          color: HairSpareColors.textPrimary,
        ),
      ),
    );
  }
}

class _WishlistAction extends StatelessWidget {
  const _WishlistAction({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Consumer<StoreWishlistProvider>(
      builder: (context, wishlist, _) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(
                Icons.favorite_border,
                size: 24,
                color: HairSpareColors.textSecondary,
              ),
              onPressed: onPressed,
              tooltip: '찜한 상품',
            ),
            if (wishlist.count > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1,
                  ),
                  decoration: const BoxDecoration(
                    color: HairSpareColors.statusUrgent,
                    borderRadius: BorderRadius.all(Radius.circular(999)),
                  ),
                  constraints: const BoxConstraints(minWidth: 16),
                  child: Text(
                    '${wishlist.count}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _CartAction extends StatelessWidget {
  const _CartAction({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(
                Icons.shopping_cart_outlined,
                size: 24,
                color: HairSpareColors.textSecondary,
              ),
              onPressed: onPressed,
              tooltip: '장바구니',
            ),
            if (cart.totalCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1,
                  ),
                  decoration: const BoxDecoration(
                    color: HairSpareColors.brandPrimary,
                    borderRadius: BorderRadius.all(Radius.circular(999)),
                  ),
                  constraints: const BoxConstraints(minWidth: 16),
                  child: Text(
                    '${cart.totalCount}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
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
