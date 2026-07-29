import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/di/service_locator.dart';
import '../../core/router/app_routes.dart';
import '../../core/router/route_extras.dart';
import '../../models/store_product.dart';
import '../../providers/cart_provider.dart';
import '../../providers/store_wishlist_provider.dart';
import '../../services/store_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/hairspare_colors.dart';
import '../../utils/error_handler.dart';
import '../../utils/shell_navigation.dart';
import '../../widgets/common/shimmer_box.dart';
import '../../widgets/design_system/hs_placeholder_image.dart';
import '../../widgets/design_system/hs_primary_button.dart';
import '../../widgets/spare_app_bar.dart';
import '../../widgets/store/store_product_card.dart';
import 'education_screen.dart' show EducationReview;

/// 스토어 상품 상세 화면.
class StoreProductDetailScreen extends StatefulWidget {
  const StoreProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  State<StoreProductDetailScreen> createState() =>
      _StoreProductDetailScreenState();
}

class _StoreProductDetailScreenState extends State<StoreProductDetailScreen> {
  final StoreService _storeService = sl<StoreService>();
  StoreProduct? _product;
  List<StoreProduct> _sellerProducts = [];
  bool _isLoading = true;
  String? _error;
  int _quantity = 1;
  final Map<String, StoreProductOptionValue> _selectedOptions = {};

  static final _priceFmt = NumberFormat('#,###');

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final product = await _storeService.getProductById(widget.productId);
      final sellerProducts = await _storeService.getProductsBySeller(
        product.sellerId,
        excludeId: product.id,
      );
      if (!mounted) return;
      setState(() {
        _product = product;
        _sellerProducts = sellerProducts;
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

  bool get _allOptionsSelected {
    final product = _product;
    if (product == null) return false;
    return product.optionGroups.every(
      (g) => _selectedOptions.containsKey(g.name),
    );
  }

  void _selectOption(String groupName, StoreProductOptionValue value) {
    setState(() => _selectedOptions[groupName] = value);
  }

  bool _validateOptions() {
    if (_allOptionsSelected) return true;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('옵션을 선택해주세요.'),
        backgroundColor: AppTheme.urgentRed,
      ),
    );
    return false;
  }

  void _addToCart() {
    final product = _product;
    if (product == null || !_validateOptions()) return;
    context.read<CartProvider>().addProduct(
      product,
      quantity: _quantity,
      selectedOptions: Map.of(_selectedOptions),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('장바구니에 담았습니다.'),
        backgroundColor: AppTheme.primaryGreen,
        action: SnackBarAction(
          label: '장바구니 보기',
          textColor: Colors.white,
          onPressed: () => context.push(AppRoutes.spareHomeStoreCart),
        ),
      ),
    );
  }

  void _buyNow() {
    final product = _product;
    if (product == null || !_validateOptions()) return;
    context.read<CartProvider>().addProduct(
      product,
      quantity: _quantity,
      selectedOptions: Map.of(_selectedOptions),
    );
    context.push(AppRoutes.spareHomeStoreCart);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.backgroundGray,
        body: JobDetailSkeleton(),
      );
    }

    if (_error != null || _product == null) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundGray,
        appBar: const SpareAppBar(showSearch: false, showBackButton: true),
        body: Center(
          child: Text(
            _error ?? '상품 정보를 불러올 수 없습니다.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
          ),
        ),
      );
    }

    final product = _product!;

    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: SpareAppBar(
        showSearch: false,
        showBackButton: true,
        actions: [
          Consumer<StoreWishlistProvider>(
            builder: (context, wishlist, _) {
              final isWishlisted = wishlist.isWishlisted(product.id);
              return IconButton(
                icon: Icon(
                  isWishlisted ? Icons.favorite : Icons.favorite_border,
                  size: 22,
                  color: isWishlisted
                      ? AppTheme.urgentRed
                      : AppTheme.textPrimary,
                ),
                onPressed: () => wishlist.toggle(product),
                tooltip: '찜하기',
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AspectRatio(
                    aspectRatio: 1,
                    child: Image.network(
                      product.thumbnailUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const HsPlaceholderImage(
                        icon: Icons.shopping_bag_outlined,
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                  ),
                  Padding(
                    padding: AppTheme.spacing(AppTheme.spacing4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.brand,
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textSecondary,
                              ),
                        ),
                        const SizedBox(height: AppTheme.spacing1),
                        Text(
                          product.name,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                        ),
                        if (product.reviewCount > 0) ...[
                          const SizedBox(height: AppTheme.spacing2),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                size: 16,
                                color: AppTheme.yellow500,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${product.averageRating.toStringAsFixed(1)} (리뷰 ${product.reviewCount}개)',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: AppTheme.spacing3),
                        if (product.hasDiscount) ...[
                          Text(
                            '${_priceFmt.format(product.originalPrice)}원',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.textTertiary,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(height: 2),
                        ],
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (product.hasDiscount) ...[
                              Text(
                                '${product.discountPercent}%',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: HairSpareColors.brandPrimary,
                                ),
                              ),
                              const SizedBox(width: AppTheme.spacing2),
                            ],
                            Text(
                              '${_priceFmt.format(product.price)}원',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        if (product.tags.isNotEmpty) ...[
                          const SizedBox(height: AppTheme.spacing3),
                          Wrap(
                            spacing: AppTheme.spacing2,
                            runSpacing: AppTheme.spacing2,
                            children: product.tags
                                .map((tag) => _TagChip(label: tag))
                                .toList(),
                          ),
                        ],
                        if (product.hasOptions) ...[
                          const SizedBox(height: AppTheme.spacing4),
                          _OptionSelector(
                            product: product,
                            selectedOptions: _selectedOptions,
                            onSelect: _selectOption,
                          ),
                        ],
                        const SizedBox(height: AppTheme.spacing4),
                        Container(
                          width: double.infinity,
                          padding: AppTheme.spacing(AppTheme.spacing4),
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundWhite,
                            borderRadius: AppTheme.borderRadius(
                              AppTheme.radiusXl,
                            ),
                            border: Border.all(color: AppTheme.borderGray),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.description_outlined,
                                    size: 18,
                                    color: HairSpareColors.brandPrimary,
                                  ),
                                  const SizedBox(width: AppTheme.spacing2),
                                  const Text(
                                    '상품 설명',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppTheme.spacing3),
                              Text(
                                product.description,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      fontSize: 13,
                                      color: AppTheme.textSecondary,
                                      height: 1.6,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        if (_sellerProducts.isNotEmpty) ...[
                          const SizedBox(height: AppTheme.spacing4),
                          _SellerProductsSection(
                            products: _sellerProducts,
                            onTap: (p) => context.push(
                              AppRoutes.spareHomeStoreProductDetail(p.id),
                            ),
                          ),
                        ],
                        if (product.reviews.isNotEmpty) ...[
                          const SizedBox(height: AppTheme.spacing4),
                          _StoreProductReviewsSection(product: product),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _BottomBar(
            product: product,
            quantity: _quantity,
            selectedOptions: _selectedOptions,
            onQuantityChanged: (q) => setState(() => _quantity = q),
            onAddToCart: _addToCart,
            onBuyNow: _buyNow,
          ),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: HairSpareColors.brandPrimarySoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: HairSpareColors.brandPrimary,
        ),
      ),
    );
  }
}

/// 같은 판매자의 다른 상품 추천 — 서로 다른 상품 2종 이상 함께 담으면
/// [CartProvider.bundleDiscountRate]만큼 자동 할인된다는 안내 포함.
class _SellerProductsSection extends StatelessWidget {
  const _SellerProductsSection({required this.products, required this.onTap});

  final List<StoreProduct> products;
  final void Function(StoreProduct product) onTap;

  @override
  Widget build(BuildContext context) {
    final bundlePercent = (CartProvider.bundleDiscountRate * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.storefront_outlined,
              size: 18,
              color: HairSpareColors.brandPrimary,
            ),
            const SizedBox(width: AppTheme.spacing2),
            const Text(
              '이 판매자의 다른 상품',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '함께 담으면 판매자 상품 합계에서 자동으로 $bundlePercent% 할인돼요',
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: AppTheme.spacing3),
        SizedBox(
          height: 228,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: AppTheme.spacing3),
            itemBuilder: (context, index) {
              final product = products[index];
              return SizedBox(
                width: 130,
                child: StoreProductCard(
                  product: product,
                  onTap: () => onTap(product),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _OptionSelector extends StatelessWidget {
  const _OptionSelector({
    required this.product,
    required this.selectedOptions,
    required this.onSelect,
  });

  final StoreProduct product;
  final Map<String, StoreProductOptionValue> selectedOptions;
  final void Function(String groupName, StoreProductOptionValue value) onSelect;

  static final _priceFmt = NumberFormat('#,###');

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final group in product.optionGroups) ...[
          Text(
            group.name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacing2),
          Wrap(
            spacing: AppTheme.spacing2,
            runSpacing: AppTheme.spacing2,
            children: group.values.map((value) {
              final isSelected = selectedOptions[group.name] == value;
              final isSoldOut = (value.stock ?? 1) <= 0;
              final label = value.priceDelta > 0
                  ? '${value.label} (+${_priceFmt.format(value.priceDelta)}원)'
                  : value.label;
              return ChoiceChip(
                label: Text(label),
                selected: isSelected,
                onSelected: isSoldOut
                    ? null
                    : (_) => onSelect(group.name, value),
                labelStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSoldOut
                      ? AppTheme.textTertiary
                      : (isSelected ? Colors.white : AppTheme.textPrimary),
                ),
                selectedColor: HairSpareColors.brandPrimary,
                backgroundColor: AppTheme.backgroundGray,
                side: BorderSide.none,
                showCheckmark: false,
              );
            }).toList(),
          ),
          const SizedBox(height: AppTheme.spacing3),
        ],
      ],
    );
  }
}

class _StoreProductReviewsSection extends StatefulWidget {
  const _StoreProductReviewsSection({required this.product});

  final StoreProduct product;

  @override
  State<_StoreProductReviewsSection> createState() =>
      _StoreProductReviewsSectionState();
}

class _StoreProductReviewsSectionState
    extends State<_StoreProductReviewsSection> {
  static const int _initialCount = 2;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final reviews = widget.product.reviews;
    final displayed = _expanded
        ? reviews
        : reviews.take(_initialCount).toList();
    final hasMore = reviews.length > _initialCount;

    return Container(
      width: double.infinity,
      padding: AppTheme.spacing(AppTheme.spacing4),
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: AppTheme.borderRadius(AppTheme.radiusXl),
        border: Border.all(color: AppTheme.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star, size: 18, color: AppTheme.yellow500),
              const SizedBox(width: AppTheme.spacing2),
              const Text(
                '리뷰',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(width: AppTheme.spacing2),
              TextButton(
                onPressed: () {
                  ShellNavigation.pushReviews(
                    context,
                    ReviewsListRouteArgs(
                      title: '${widget.product.name} 리뷰',
                      averageRating: widget.product.averageRating,
                      reviews: reviews
                          .map(
                            (r) => EducationReview(
                              userName: r.userName,
                              rating: r.rating,
                              comment: r.comment,
                              createdAt: r.createdAt,
                            ),
                          )
                          .toList(),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  '+더보기',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: HairSpareColors.brandPrimary,
                  ),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  const Icon(Icons.star, size: 18, color: AppTheme.yellow500),
                  const SizedBox(width: AppTheme.spacing1),
                  Text(
                    '${widget.product.averageRating.toStringAsFixed(1)} (${reviews.length}개)',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing4),
          ...displayed.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.spacing4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ...List.generate(
                        5,
                        (i) => Icon(
                          i < r.rating ? Icons.star : Icons.star_border,
                          size: 16,
                          color: AppTheme.yellow500,
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacing2),
                      Text(
                        r.userName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        DateFormat('M/d', 'ko_KR').format(r.createdAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacing2),
                  Text(
                    r.comment,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (hasMore)
            Center(
              child: TextButton(
                onPressed: () => setState(() => _expanded = !_expanded),
                child: Text(
                  _expanded ? '접기' : '열기',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: HairSpareColors.brandPrimary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.product,
    required this.quantity,
    required this.selectedOptions,
    required this.onQuantityChanged,
    required this.onAddToCart,
    required this.onBuyNow,
  });

  final StoreProduct product;
  final int quantity;
  final Map<String, StoreProductOptionValue> selectedOptions;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onAddToCart;
  final VoidCallback onBuyNow;

  static final _priceFmt = NumberFormat('#,###');

  @override
  Widget build(BuildContext context) {
    final unitPrice =
        product.price +
        selectedOptions.values.fold<int>(0, (sum, v) => sum + v.priceDelta);
    final totalPrice = unitPrice * quantity;

    return Container(
      padding: AppTheme.spacing(AppTheme.spacing4),
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        boxShadow: AppTheme.shadowMd,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '총 금액',
                  style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                ),
                Text(
                  '${_priceFmt.format(totalPrice)}원',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacing2),
            _QuantityStepper(quantity: quantity, onChanged: onQuantityChanged),
            const SizedBox(height: AppTheme.spacing3),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: product.isSoldOut ? null : onAddToCart,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: HairSpareColors.brandPrimary,
                      side: const BorderSide(
                        color: HairSpareColors.brandPrimary,
                      ),
                      padding: AppTheme.spacing(AppTheme.spacing4),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppTheme.borderRadius(AppTheme.radiusXl),
                      ),
                    ),
                    child: const Text(
                      '장바구니',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacing3),
                Expanded(
                  flex: 2,
                  child: HsPrimaryButton(
                    label: product.isSoldOut ? '품절' : '구매하기',
                    onPressed: product.isSoldOut ? null : onBuyNow,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({required this.quantity, required this.onChanged});

  final int quantity;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.borderGray),
        borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove, size: 18),
            color: quantity > 1 ? AppTheme.textPrimary : AppTheme.textTertiary,
            onPressed: quantity > 1 ? () => onChanged(quantity - 1) : null,
          ),
          Text(
            '$quantity',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 18),
            color: AppTheme.textPrimary,
            onPressed: () => onChanged(quantity + 1),
          ),
        ],
      ),
    );
  }
}
