import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_routes.dart';
import '../../models/store_product.dart';
import '../../providers/store_wishlist_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/spare_subpage_app_bar.dart';
import '../../widgets/store/store_product_card.dart';

/// 찜한 스토어 상품 목록 화면.
class StoreWishlistScreen extends StatelessWidget {
  const StoreWishlistScreen({super.key});

  void _openProductDetail(BuildContext context, StoreProduct product) {
    context.push(AppRoutes.spareHomeStoreProductDetail(product.id));
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

          final products = wishlist.products;
          return GridView.builder(
            padding: const EdgeInsets.all(AppTheme.spacing4),
            itemCount: products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppTheme.spacing4,
              crossAxisSpacing: AppTheme.spacing3,
              childAspectRatio: 0.68,
            ),
            itemBuilder: (context, index) {
              final product = products[index];
              return StoreProductCard(
                product: product,
                onTap: () => _openProductDetail(context, product),
                isWishlisted: true,
                onWishlistToggle: () => wishlist.remove(product.id),
              );
            },
          );
        },
      ),
    );
  }
}
