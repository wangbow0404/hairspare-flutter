import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../models/spare_profile.dart';
import '../../services/spare_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_handler.dart';
import '../../widgets/common/spare_subpage_app_bar.dart';
import '../../widgets/shop_home/shop_home_spare_card.dart';
import '../../widgets/stitch/stitch_empty_state.dart';

/// 샵 찜 탭 — 찜한 스페어 목록.
class ShopFavoritesScreen extends StatefulWidget {
  const ShopFavoritesScreen({super.key});

  @override
  State<ShopFavoritesScreen> createState() => _ShopFavoritesScreenState();
}

class _ShopFavoritesScreenState extends State<ShopFavoritesScreen> {
  List<SpareProfile> _favoriteSpares = [];
  bool _isLoading = true;
  final SpareService _spareService = SpareService();

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    try {
      // TODO: 찜한 스페어 전용 API로 교체
      final allSpares = await _spareService.getSpares();
      if (mounted) {
        setState(() {
          _favoriteSpares = allSpares.take(3).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '찜 목록을 불러오는 중 오류가 발생했습니다: ${ErrorHandler.getUserFriendlyMessage(appException)}',
            ),
            backgroundColor: AppTheme.urgentRed,
          ),
        );
      }
    }
  }

  Future<void> _handleRemoveFavorite(String spareId) async {
    // TODO: 찜 해제 API 연동
    setState(() => _favoriteSpares.removeWhere((s) => s.id == spareId));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('찜이 삭제되었습니다.')),
      );
    }
  }

  void _handleSpareTap(SpareProfile spare) {
    // TODO: 스페어 상세 화면 연결
    context.push(AppRoutes.shopHomeSpares);
  }

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: SpareSubpageAppBar(
        title: '찜한 스페어',
        showBackButton: canPop,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favoriteSpares.isEmpty
              ? StitchEmptyState(
                  message: '찜한 스페어가 없습니다',
                  iconName: 'heart',
                  actionLabel: '스페어 둘러보기',
                  onAction: () => context.push(AppRoutes.shopHomeSpares),
                )
              : ListView.builder(
                  padding: AppTheme.spacing(AppTheme.spacing4),
                  itemCount: _favoriteSpares.length,
                  itemBuilder: (context, index) {
                    final spare = _favoriteSpares[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppTheme.spacing3),
                      child: Stack(
                        children: [
                          ShopHomeSpareListTile(
                            spare: spare,
                            onTap: () => _handleSpareTap(spare),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: IconButton(
                              onPressed: () => _handleRemoveFavorite(spare.id),
                              icon: const Icon(
                                Icons.favorite_rounded,
                                color: AppTheme.urgentRed,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
