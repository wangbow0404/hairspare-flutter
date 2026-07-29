import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_routes.dart';
import '../../models/store_product.dart';
import '../../providers/store_wishlist_provider.dart';
import '../../theme/app_theme.dart';
import '../../theme/hairspare_colors.dart';
import '../../widgets/common/spare_subpage_app_bar.dart';
import '../../widgets/design_system/hs_filter_chip.dart';
import '../../widgets/store/store_product_card.dart';

enum _WishlistFilter { all, onSale }

/// 찜한 스토어 상품 목록 화면 — 폴더 구분 + 할인중 필터 + 가격 하락 안내.
class StoreWishlistScreen extends StatefulWidget {
  const StoreWishlistScreen({super.key});

  @override
  State<StoreWishlistScreen> createState() => _StoreWishlistScreenState();
}

class _StoreWishlistScreenState extends State<StoreWishlistScreen> {
  _WishlistFilter _filter = _WishlistFilter.all;
  String? _selectedFolder; // null = 전체함

  void _openProductDetail(StoreProduct product) {
    context.push(AppRoutes.spareHomeStoreProductDetail(product.id));
  }

  Future<void> _createFolder(StoreWishlistProvider wishlist) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('폴더 만들기'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: '폴더 이름 (예: 선물용)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            child: const Text('만들기'),
          ),
        ],
      ),
    );
    if (name == null || name.trim().isEmpty) return;
    wishlist.createFolder(name.trim());
    setState(() => _selectedFolder = name.trim());
  }

  Future<void> _assignFolder(
    StoreWishlistProvider wishlist,
    StoreProduct product,
  ) async {
    final picked = await showModalBottomSheet<String?>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(AppTheme.spacing4),
              child: Text(
                '폴더에 담기',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
            ListTile(
              title: const Text('기본함'),
              trailing: wishlist.folderOf(product.id) == null
                  ? const Icon(Icons.check, color: HairSpareColors.brandPrimary)
                  : null,
              onTap: () => Navigator.of(ctx).pop(''),
            ),
            for (final folder in wishlist.folders)
              ListTile(
                title: Text(folder),
                trailing: wishlist.folderOf(product.id) == folder
                    ? const Icon(
                        Icons.check,
                        color: HairSpareColors.brandPrimary,
                      )
                    : null,
                onTap: () => Navigator.of(ctx).pop(folder),
              ),
          ],
        ),
      ),
    );
    if (picked == null) return;
    wishlist.assignFolder(product.id, picked.isEmpty ? null : picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: const SpareSubpageAppBar(
        title: '찜한 상품',
        showToolbarActions: false,
      ),
      body: Consumer<StoreWishlistProvider>(
        builder: (context, wishlist, _) {
          if (wishlist.products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: AppTheme.textTertiary,
                  ),
                  const SizedBox(height: AppTheme.spacing4),
                  Text(
                    '찜한 상품이 없어요',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          var products = wishlist.products;
          if (_filter == _WishlistFilter.onSale) {
            products = products
                .where((p) => p.hasDiscount || wishlist.priceDropAmount(p) > 0)
                .toList();
          }
          if (_selectedFolder != null) {
            products = products
                .where((p) => wishlist.folderOf(p.id) == _selectedFolder)
                .toList();
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppTheme.spacing4,
                  AppTheme.spacing3,
                  AppTheme.spacing4,
                  0,
                ),
                child: Row(
                  children: [
                    HsFilterChip(
                      label: '전체',
                      isSelected: _filter == _WishlistFilter.all,
                      onTap: () =>
                          setState(() => _filter = _WishlistFilter.all),
                    ),
                    const SizedBox(width: AppTheme.spacing2),
                    HsFilterChip(
                      label: '할인중',
                      isSelected: _filter == _WishlistFilter.onSale,
                      onTap: () =>
                          setState(() => _filter = _WishlistFilter.onSale),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacing3),
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing4,
                  ),
                  children: [
                    HsFilterChip(
                      label: '전체함',
                      isSelected: _selectedFolder == null,
                      onTap: () => setState(() => _selectedFolder = null),
                    ),
                    for (final folder in wishlist.folders) ...[
                      const SizedBox(width: AppTheme.spacing2),
                      HsFilterChip(
                        label: folder,
                        isSelected: _selectedFolder == folder,
                        onTap: () => setState(() => _selectedFolder = folder),
                      ),
                    ],
                    const SizedBox(width: AppTheme.spacing2),
                    ActionChip(
                      label: const Icon(Icons.add, size: 16),
                      onPressed: () => _createFolder(wishlist),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacing2),
              Expanded(
                child: products.isEmpty
                    ? Center(
                        child: Text(
                          '해당 조건의 찜한 상품이 없어요',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppTheme.textSecondary),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(AppTheme.spacing4),
                        itemCount: products.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: AppTheme.spacing4,
                              crossAxisSpacing: AppTheme.spacing3,
                              childAspectRatio: 0.6,
                            ),
                        itemBuilder: (context, index) {
                          final product = products[index];
                          final priceDrop = wishlist.priceDropAmount(product);
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: StoreProductCard(
                                  product: product,
                                  onTap: () => _openProductDetail(product),
                                  isWishlisted: true,
                                  onWishlistToggle: () =>
                                      wishlist.remove(product.id),
                                ),
                              ),
                              Row(
                                children: [
                                  if (priceDrop > 0)
                                    Expanded(
                                      child: Text(
                                        '스크랩 때보다 ${NumberFormat('#,###').format(priceDrop)}원 저렴해졌어요',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: HairSpareColors.brandPrimary,
                                        ),
                                      ),
                                    )
                                  else
                                    const Spacer(),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.folder_outlined,
                                      size: 16,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(
                                      minWidth: 28,
                                      minHeight: 28,
                                    ),
                                    visualDensity: VisualDensity.compact,
                                    color: AppTheme.textSecondary,
                                    onPressed: () =>
                                        _assignFolder(wishlist, product),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
