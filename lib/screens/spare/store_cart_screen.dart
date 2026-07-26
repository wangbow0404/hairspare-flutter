import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/spare_app_bar.dart';

/// 스토어 장바구니 화면 — 결제 연동 전이라 주문하기는 안내만 표시.
class StoreCartScreen extends StatelessWidget {
  const StoreCartScreen({super.key});

  static final _priceFmt = NumberFormat('#,###');

  void _showCheckoutComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('결제 기능은 준비 중입니다.'),
        backgroundColor: AppTheme.orange500,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: const SpareAppBar(showSearch: false, showBackButton: true),
      body: Consumer<CartProvider>(
        builder: (context, cart, _) {
          if (cart.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.shopping_cart_outlined,
                    size: 64,
                    color: AppTheme.textTertiary,
                  ),
                  const SizedBox(height: AppTheme.spacing4),
                  Text(
                    '장바구니가 비어있어요',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: AppTheme.spacing(AppTheme.spacing4),
                  itemCount: cart.items.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppTheme.spacing3),
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return _CartItemCard(
                      item: item,
                      onQuantityChanged: (q) =>
                          cart.updateQuantity(item.product.id, q),
                      onRemove: () => cart.removeProduct(item.product.id),
                    );
                  },
                ),
              ),
              Container(
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
                            '총 결제 금액',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          Text(
                            '${_priceFmt.format(cart.totalPrice)}원',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacing3),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _showCheckoutComingSoon(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.orange500,
                            foregroundColor: Colors.white,
                            padding: AppTheme.spacing(AppTheme.spacing4),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppTheme.borderRadius(
                                AppTheme.radiusLg,
                              ),
                            ),
                          ),
                          child: Text(
                            '${cart.totalCount}개 주문하기',
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
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  final CartItem item;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;

  static final _priceFmt = NumberFormat('#,###');

  @override
  Widget build(BuildContext context) {
    final product = item.product;
    return Container(
      padding: AppTheme.spacing(AppTheme.spacing3),
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.borderGray),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: AppTheme.borderRadius(AppTheme.radiusMd),
            child: Image.network(
              product.thumbnailUrl,
              width: 72,
              height: 72,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 72,
                height: 72,
                color: AppTheme.backgroundGray,
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  color: AppTheme.textTertiary,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppTheme.spacing3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.brand,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _MiniStepper(
                      quantity: item.quantity,
                      onChanged: onQuantityChanged,
                    ),
                    Text(
                      '${_priceFmt.format(item.subtotal)}원',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.close,
              size: 18,
              color: AppTheme.textTertiary,
            ),
            onPressed: onRemove,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

class _MiniStepper extends StatelessWidget {
  const _MiniStepper({required this.quantity, required this.onChanged});

  final int quantity;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.borderGray),
        borderRadius: AppTheme.borderRadius(AppTheme.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove, size: 14),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            visualDensity: VisualDensity.compact,
            onPressed: () => onChanged(quantity - 1),
          ),
          Text(
            '$quantity',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 14),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            visualDensity: VisualDensity.compact,
            onPressed: () => onChanged(quantity + 1),
          ),
        ],
      ),
    );
  }
}
