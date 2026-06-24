import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/user.dart';
import '../../theme/app_theme.dart';
import '../../view_models/portfolio_view_model.dart';
import '../../widgets/common/app_network_image.dart';
import '../../widgets/common/app_screen_safe_area.dart';
import '../../widgets/common/spare_subpage_app_bar.dart';
import '../../widgets/portfolio/portfolio_image_source_sheet.dart';
import '../../widgets/stitch/stitch_empty_state.dart';
import '../../widgets/stitch/stitch_sticky_bottom_bar.dart';

/// 스페어·샵 작업 포트폴리오 — 모델 매칭·프로필 조회용.
class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({
    super.key,
    required this.ownerId,
    required this.ownerRole,
  });

  final String ownerId;
  final String ownerRole;

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  late final PortfolioViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = PortfolioViewModel(
      ownerId: widget.ownerId,
      ownerRole: widget.ownerRole,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_viewModel.load());
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PortfolioViewModel>.value(
      value: _viewModel,
      child: const _PortfolioScaffold(),
    );
  }
}

class _PortfolioScaffold extends StatelessWidget {
  const _PortfolioScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: SpareSubpageAppBar(
        title: '작업 포트폴리오',
        showToolbarActions: false,
        onBackPressed: () => context.pop(),
      ),
      body: AppScreenSafeArea(
        child: Consumer<PortfolioViewModel>(
          builder: (context, vm, _) {
            if (vm.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (vm.error != null) {
              return StitchEmptyState(
                message: vm.error!,
                iconName: 'alertcircle',
                actionLabel: '다시 시도',
                onAction: vm.load,
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _PortfolioGuideBanner(
                  ownerRole: vm.ownerRole,
                  imageCount: vm.images.length,
                ),
                Expanded(
                  child: vm.images.isEmpty
                      ? const StitchEmptyState(
                          message: '등록된 작업 사진이 없습니다.\n아래 버튼으로 추가해 주세요.',
                          iconName: 'image',
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.fromLTRB(
                            AppTheme.spacing4,
                            0,
                            AppTheme.spacing4,
                            AppTheme.spacing4,
                          ),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: AppTheme.spacing2,
                            mainAxisSpacing: AppTheme.spacing2,
                          ),
                          itemCount: vm.images.length,
                          itemBuilder: (context, index) {
                            return _PortfolioTile(
                              imageUrl: vm.images[index],
                              onRemove: vm.isSaving
                                  ? null
                                  : () => vm.removeAt(index),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: Consumer<PortfolioViewModel>(
        builder: (context, vm, _) {
          return StitchStickyBottomBar(
            primaryLabel: '사진 추가',
            onPrimary: vm.isSaving
                ? null
                : () => showPortfolioImageSourceSheet(context),
            isLoading: vm.isSaving,
          );
        },
      ),
    );
  }
}

class _PortfolioGuideBanner extends StatelessWidget {
  const _PortfolioGuideBanner({
    required this.ownerRole,
    required this.imageCount,
  });

  final String ownerRole;
  final int imageCount;

  @override
  Widget build(BuildContext context) {
    final roleLabel =
        ownerRole == UserRole.shop.name ? '미용실' : '디자이너';
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacing4,
        0,
        AppTheme.spacing4,
        AppTheme.spacing4,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppTheme.stitchPrimaryContainer.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(
            color: AppTheme.stitchPrimary.withValues(alpha: 0.2),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.collections_outlined,
                color: AppTheme.stitchPrimary,
                size: 22,
              ),
              const SizedBox(width: AppTheme.spacing3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$roleLabel 작업 사진 $imageCount장',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.stitchTextPrimary,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing1),
                    const Text(
                      '모델 매칭·프로필 조회 시 노출됩니다. 실제 작업 결과 사진을 올려주세요.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.45,
                        color: AppTheme.stitchTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PortfolioTile extends StatelessWidget {
  const _PortfolioTile({
    required this.imageUrl,
    this.onRemove,
  });

  final String imageUrl;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      child: Stack(
        fit: StackFit.expand,
        children: [
          AppNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            memCacheWidth: 400,
          ),
          if (onRemove != null)
            Positioned(
              top: 4,
              right: 4,
              child: Material(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                child: InkWell(
                  onTap: onRemove,
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
