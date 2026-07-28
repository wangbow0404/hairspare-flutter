import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/di/service_locator.dart';
import '../../providers/cart_provider.dart';
import '../../services/store_seller_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/hairspare_colors.dart';
import '../../widgets/admin/admin_action_dialog.dart';
import '../../widgets/common/spare_subpage_app_bar.dart';
import '../../widgets/design_system/hs_placeholder_image.dart';
import '../../widgets/design_system/hs_primary_button.dart';

/// 스토어 장바구니 화면 — 결제 연동 전이라 주문하기는 안내만 표시.
class StoreCartScreen extends StatelessWidget {
  const StoreCartScreen({super.key});

  static final _priceFmt = NumberFormat('#,###');

  void _showCheckoutComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('결제 기능은 준비 중입니다.'),
        backgroundColor: HairSpareColors.brandPrimary,
      ),
    );
  }

  Future<void> _removeSelected(BuildContext context, CartProvider cart) async {
    final confirmed = await AdminActionDialog.confirm(
      context,
      title: '선택 상품 삭제',
      message: '선택한 ${cart.selectedItems.length}개 상품을 장바구니에서 삭제할까요?',
      confirmLabel: '삭제',
      isDanger: true,
    );
    if (confirmed == true) cart.removeSelected();
  }

  @override
  Widget build(BuildContext context) {
    final sellerService = sl<StoreSellerService>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: const SpareSubpageAppBar(
        title: '장바구니',
        showToolbarActions: false,
      ),
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

          final grouped = cart.itemsBySeller;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing4,
                  vertical: AppTheme.spacing3,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => cart.setAllSelected(!cart.allSelected),
                      child: Row(
                        children: [
                          Icon(
                            cart.allSelected
                                ? Icons.check_circle
                                : Icons.check_circle_outline,
                            size: 20,
                            color: cart.allSelected
                                ? HairSpareColors.brandPrimary
                                : AppTheme.textTertiary,
                          ),
                          const SizedBox(width: AppTheme.spacing2),
                          const Text(
                            '전체선택',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: cart.selectedItems.isEmpty
                          ? null
                          : () => _removeSelected(context, cart),
                      child: const Text('선택삭제'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppTheme.spacing4,
                    0,
                    AppTheme.spacing4,
                    AppTheme.spacing4,
                  ),
                  children: [
                    for (final entry in grouped.entries) ...[
                      _SellerHeader(
                        sellerName:
                            sellerService
                                .getSellerByIdSync(entry.key)
                                ?.shopName ??
                            '판매자 정보 없음',
                      ),
                      const SizedBox(height: AppTheme.spacing2),
                      for (final item in entry.value) ...[
                        _CartItemCard(
                          item: item,
                          onToggleSelected: () =>
                              cart.toggleSelected(item.lineKey),
                          onQuantityChanged: (q) =>
                              cart.updateQuantity(item.lineKey, q),
                          onRemove: () => cart.removeProduct(item.lineKey),
                        ),
                        const SizedBox(height: AppTheme.spacing3),
                      ],
                      const SizedBox(height: AppTheme.spacing2),
                    ],
                  ],
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
                            '선택 상품 금액',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          Text(
                            '${_priceFmt.format(cart.selectedTotalPrice)}원',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacing3),
                      HsPrimaryButton(
                        label: cart.selectedItems.isEmpty
                            ? '상품을 선택해주세요'
                            : '${cart.selectedCount}개 주문하기',
                        onPressed: cart.selectedItems.isEmpty
                            ? null
                            : () => _showCheckoutComingSoon(context),
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

class _SellerHeader extends StatelessWidget {
  const _SellerHeader({required this.sellerName});

  final String sellerName;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.storefront_outlined,
          size: 16,
          color: AppTheme.textSecondary,
        ),
        const SizedBox(width: AppTheme.spacing1),
        Text(
          sellerName,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({
    required this.item,
    required this.onToggleSelected,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  final CartItem item;
  final VoidCallback onToggleSelected;
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
        border: Border.all(
          color: item.isSelected
              ? HairSpareColors.brandPrimary.withValues(alpha: 0.4)
              : AppTheme.borderGray,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onToggleSelected,
            child: Icon(
              item.isSelected ? Icons.check_circle : Icons.check_circle_outline,
              size: 20,
              color: item.isSelected
                  ? HairSpareColors.brandPrimary
                  : AppTheme.textTertiary,
            ),
          ),
          const SizedBox(width: AppTheme.spacing2),
          ClipRRect(
            borderRadius: AppTheme.borderRadius(AppTheme.radiusMd),
            child: Image.network(
              product.thumbnailUrl,
              width: 72,
              height: 72,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const HsPlaceholderImage(
                width: 72,
                height: 72,
                icon: Icons.shopping_bag_outlined,
                borderRadius: BorderRadius.zero,
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
                if (item.selectedOptions.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    '옵션: ${item.optionSummary}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
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
