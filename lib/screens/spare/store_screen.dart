import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/di/service_locator.dart';
import '../../core/router/app_routes.dart';
import '../../models/store_product.dart';
import '../../providers/cart_provider.dart';
import '../../services/store_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_handler.dart';
import '../../widgets/common/shimmer_box.dart';
import '../../widgets/common/spare_subpage_app_bar.dart';
import '../../widgets/stitch/stitch_filter_chip.dart';
import '../../widgets/store/store_product_card.dart';

/// 스토어 화면 — 미용 도구·용품 상품 목록 (오늘의집 스타일 그리드).
class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final StoreService _storeService = sl<StoreService>();
  StoreProductCategory? _selectedCategory;
  List<StoreProduct> _products = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final products = await _storeService.getProducts(
        category: _selectedCategory,
      );
      if (!mounted) return;
      setState(() {
        _products = products;
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

  void _openProductDetail(StoreProduct product) {
    context.push(AppRoutes.spareHomeStoreProductDetail(product.id));
  }

  void _openCart() {
    context.push(AppRoutes.spareHomeStoreCart);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: SpareSubpageAppBar(
        title: '스토어',
        showToolbarActions: false,
        trailingActions: [
          Consumer<CartProvider>(
            builder: (context, cart, _) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.shopping_cart_outlined,
                      size: 24,
                      color: AppTheme.textSecondary,
                    ),
                    onPressed: _openCart,
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
                          color: AppTheme.orange500,
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
          ),
          const SizedBox(width: AppTheme.spacing2),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: AppTheme.backgroundWhite,
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacing4,
              vertical: AppTheme.spacing3,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  StitchFilterChip(
                    label: '전체',
                    isSelected: _selectedCategory == null,
                    onTap: () => _onCategorySelected(null),
                  ),
                  for (final category in StoreProductCategory.values) ...[
                    const SizedBox(width: AppTheme.spacing2),
                    StitchFilterChip(
                      label: category.label,
                      isSelected: _selectedCategory == category,
                      onTap: () => _onCategorySelected(category),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const ProductGridSkeleton()
                : _error != null
                ? _ErrorState(message: _error!, onRetry: _loadProducts)
                : _products.isEmpty
                ? const _EmptyState()
                : RefreshIndicator(
                    onRefresh: _loadProducts,
                    child: GridView.builder(
                      padding: const EdgeInsets.all(AppTheme.spacing4),
                      itemCount: _products.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: AppTheme.spacing4,
                            crossAxisSpacing: AppTheme.spacing3,
                            childAspectRatio: 0.68,
                          ),
                      itemBuilder: (context, index) {
                        final product = _products[index];
                        return StoreProductCard(
                          product: product,
                          onTap: () => _openProductDetail(product),
                        );
                      },
                    ),
                  ),
          ),
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
            '해당 카테고리에 상품이 없습니다',
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
