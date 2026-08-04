import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/di/service_locator.dart';
import '../../core/router/app_routes.dart';
import '../../models/store_seller.dart';
import '../../providers/store_seller_follow_provider.dart';
import '../../services/store_seller_service.dart';
import '../../services/store_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/hairspare_colors.dart';
import '../../utils/error_handler.dart';
import '../../widgets/common/spare_subpage_app_bar.dart';

/// 전체 스토어(셀러) 목록 — 스토어 홈 "인기 스토어" 섹션 더보기·바로가기에서 진입.
class StoreAllSellersScreen extends StatefulWidget {
  const StoreAllSellersScreen({super.key});

  @override
  State<StoreAllSellersScreen> createState() => _StoreAllSellersScreenState();
}

class _StoreAllSellersScreenState extends State<StoreAllSellersScreen> {
  final StoreService _storeService = sl<StoreService>();
  final StoreSellerService _sellerService = sl<StoreSellerService>();
  List<StoreSellerSummary> _summaries = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final products = await _storeService.getProducts();
      final summaries = await _sellerService.getSellerSummaries(products);
      if (!mounted) return;
      setState(() {
        _summaries = summaries;
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

  void _openSellerProducts(StoreSeller seller) {
    context.push(AppRoutes.spareHomeStoreSellerProfile(seller.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: const SpareSubpageAppBar(
        title: '전체 스토어',
        showToolbarActions: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_error!),
                  const SizedBox(height: AppTheme.spacing3),
                  TextButton(onPressed: _load, child: const Text('다시 시도')),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppTheme.spacing4),
              itemCount: _summaries.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppTheme.spacing3),
              itemBuilder: (context, index) {
                final summary = _summaries[index];
                return Consumer<StoreSellerFollowProvider>(
                  builder: (context, follow, _) {
                    final sellerId = summary.seller.id;
                    return _SellerRow(
                      summary: summary,
                      isFollowing: follow.isFollowing(sellerId),
                      followerCount: follow.displayFollowerCount(
                        sellerId,
                        summary.followerCount,
                      ),
                      onTap: () => _openSellerProducts(summary.seller),
                      onFollowToggle: () => follow.toggle(sellerId),
                    );
                  },
                );
              },
            ),
    );
  }
}

class _SellerRow extends StatelessWidget {
  const _SellerRow({
    required this.summary,
    required this.isFollowing,
    required this.followerCount,
    required this.onTap,
    required this.onFollowToggle,
  });

  final StoreSellerSummary summary;
  final bool isFollowing;
  final int followerCount;
  final VoidCallback onTap;
  final VoidCallback onFollowToggle;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: HairSpareColors.surface,
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing4),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: HairSpareColors.brandPrimarySoft,
                child: Text(
                  summary.seller.shopName.substring(0, 1),
                  style: const TextStyle(
                    color: HairSpareColors.brandPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spacing3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      summary.seller.shopName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: HairSpareColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '상품 ${summary.productCount} · 팔로워 $followerCount',
                      style: const TextStyle(
                        fontSize: 12,
                        color: HairSpareColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: onFollowToggle,
                child: Text(isFollowing ? '팔로잉' : '+ 팔로우'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
