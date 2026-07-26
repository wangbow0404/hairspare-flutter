import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/di/service_locator.dart';
import '../../core/router/app_routes.dart';
import '../../models/store_product.dart';
import '../../providers/cart_provider.dart';
import '../../services/store_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_handler.dart';
import '../../widgets/common/shimmer_box.dart';
import '../../widgets/spare_app_bar.dart';

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
  bool _isLoading = true;
  String? _error;
  int _quantity = 1;

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
      if (!mounted) return;
      setState(() {
        _product = product;
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

  void _addToCart() {
    final product = _product;
    if (product == null) return;
    context.read<CartProvider>().addProduct(product, quantity: _quantity);
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
      appBar: const SpareAppBar(showSearch: false, showBackButton: true),
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
                      errorBuilder: (_, __, ___) => Container(
                        color: AppTheme.backgroundGray,
                        child: const Icon(
                          Icons.shopping_bag_outlined,
                          size: 64,
                          color: AppTheme.textTertiary,
                        ),
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
                                  color: AppTheme.orange600,
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
                                    color: AppTheme.orange500,
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
            onQuantityChanged: (q) => setState(() => _quantity = q),
            onAddToCart: _addToCart,
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
        color: AppTheme.orange50,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppTheme.orange600,
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.product,
    required this.quantity,
    required this.onQuantityChanged,
    required this.onAddToCart,
  });

  final StoreProduct product;
  final int quantity;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppTheme.spacing(AppTheme.spacing4),
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        boxShadow: AppTheme.shadowMd,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            _QuantityStepper(quantity: quantity, onChanged: onQuantityChanged),
            const SizedBox(width: AppTheme.spacing3),
            Expanded(
              child: ElevatedButton(
                onPressed: product.isSoldOut ? null : onAddToCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.orange500,
                  disabledBackgroundColor: AppTheme.borderGray300,
                  foregroundColor: Colors.white,
                  padding: AppTheme.spacing(AppTheme.spacing4),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                  ),
                ),
                child: Text(
                  product.isSoldOut ? '품절' : '장바구니 담기',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
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
