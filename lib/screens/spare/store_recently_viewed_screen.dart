import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/di/service_locator.dart';
import '../../core/router/app_routes.dart';
import '../../models/store_product.dart';
import '../../providers/recently_viewed_store_provider.dart';
import '../../providers/store_wishlist_provider.dart';
import '../../services/store_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/spare_subpage_app_bar.dart';
import '../../widgets/store/store_product_card.dart';

/// 최근 본 상품 — 스토어 홈 바로가기 숏컷에서 진입.
class StoreRecentlyViewedScreen extends StatefulWidget {
  const StoreRecentlyViewedScreen({super.key});

  @override
  State<StoreRecentlyViewedScreen> createState() =>
      _StoreRecentlyViewedScreenState();
}

class _StoreRecentlyViewedScreenState
    extends State<StoreRecentlyViewedScreen> {
  final StoreService _storeService = sl<StoreService>();
  List<StoreProduct> _products = [];
  bool _isLoading = true;
  List<String> _lastLoadedIds = const [];

  @override
  void initState() {
    super.initState();
    _load(sl<RecentlyViewedStoreProvider>().productIds);
  }

  Future<void> _load(List<String> ids) async {
    _lastLoadedIds = ids;
    final products = <StoreProduct>[];
    for (final id in ids) {
      try {
        products.add(await _storeService.getProductById(id));
      } catch (_) {
        // 삭제된 상품은 건너뜀.
      }
    }
    if (!mounted) return;
    setState(() {
      _products = products;
      _isLoading = false;
    });
  }

  void _openProductDetail(StoreProduct product) {
    context.push(AppRoutes.spareHomeStoreProductDetail(product.id));
  }

  @override
  Widget build(BuildContext context) {
    final recentlyViewed = context.watch<RecentlyViewedStoreProvider>();
    final ids = recentlyViewed.productIds;
    if (!listEquals(ids, _lastLoadedIds)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _load(ids);
      });
    }
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: const SpareSubpageAppBar(
        title: '최근 본 상품',
        showToolbarActions: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _products.isEmpty
          ? const Center(child: Text('최근 본 상품이 없습니다'))
          : GridView.builder(
              padding: const EdgeInsets.all(AppTheme.spacing4),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: AppTheme.spacing4,
                crossAxisSpacing: AppTheme.spacing3,
                childAspectRatio: 0.54,
              ),
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                return Consumer<StoreWishlistProvider>(
                  builder: (context, wishlist, _) {
                    return StoreProductCard(
                      product: product,
                      onTap: () => _openProductDetail(product),
                      isWishlisted: wishlist.isWishlisted(product.id),
                      onWishlistToggle: () => wishlist.toggle(product),
                    );
                  },
                );
              },
            ),
    );
  }
}
