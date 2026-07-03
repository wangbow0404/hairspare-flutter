import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../theme/home_text_styles.dart';
import '../../widgets/stitch/stitch_hero_banner.dart';
import '../../widgets/category_grid.dart';
import '../../widgets/customer_service_section.dart';
import '../../view_models/shop_home_view_model.dart';
import 'shop_home_app_bar.dart';
import 'shop_home_quick_menu.dart';
import 'shop_home_spare_sections.dart';
import 'shop_home_tips_banner.dart';

/// 샵 홈 본문 스크롤(배너·카테고리·대시보드·리스트). 데이터는 [ShopHomeViewModel].
class ShopHomeScrollView extends StatelessWidget {
  const ShopHomeScrollView({super.key, required this.scrollController});

  final ScrollController scrollController;

  void _openSparesList(BuildContext context) {
    context.push(AppRoutes.shopHomeSpares);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ShopHomeViewModel>();
    final bottomInset = MediaQuery.of(context).padding.bottom;

    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    Future<void> openJobsList() async {
      await context.push(AppRoutes.shopProfileJobs);
      if (context.mounted) {
        await context.read<ShopHomeViewModel>().loadInitial();
      }
    }

    Future<void> openApplicants() async {
      await context.push(AppRoutes.shopProfileApplicants);
      if (context.mounted) {
        await context.read<ShopHomeViewModel>().loadInitial();
      }
    }

    void openSchedule() {
      context.push(AppRoutes.shopHomeSchedule);
    }

    Widget dashboardCard({
      required String value,
      required String label,
      required Gradient gradient,
      required VoidCallback onTap,
    }) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacing3),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            boxShadow: AppTheme.shadowSm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: HomeTextStyles.dashboardValueOnGradient),
              const SizedBox(height: AppTheme.spacing1),
              Text(label, style: HomeTextStyles.dashboardLabelOnGradient),
            ],
          ),
        ),
      );
    }

    return CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            height: 44 + MediaQuery.paddingOf(context).top,
            decoration: const BoxDecoration(
              color: AppTheme.backgroundWhite,
              border: Border(
                bottom: BorderSide(color: AppTheme.borderGray, width: 1),
              ),
            ),
            padding: EdgeInsets.only(
              top: MediaQuery.paddingOf(context).top,
              left: AppTheme.spacing4,
              right: AppTheme.spacing4,
            ),
            child: SizedBox(
              height: 44,
              child: ShopHomeAppBarRow(scrollController: scrollController),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StitchHeroBanner(
                height: 240,
                variant: StitchHeroVariant.shop,
                onCtaTap: (index) {
                  switch (index) {
                    case 0:
                      openJobsList();
                      break;
                    case 1:
                      _openSparesList(context);
                      break;
                    case 2:
                      openSchedule();
                      break;
                  }
                },
              ),
              const SizedBox(height: AppTheme.spacing4),
              CategoryGrid(
                padding: const EdgeInsets.fromLTRB(
                  AppTheme.spacing4,
                  0,
                  AppTheme.spacing4,
                  AppTheme.spacing6,
                ),
                categories: ShopHomeQuickMenu.buildCategories(context),
              ),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            decoration: const BoxDecoration(
              color: AppTheme.backgroundWhite,
              border: Border(
                bottom: BorderSide(color: AppTheme.borderGray, width: 1),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(
              AppTheme.spacing4,
              AppTheme.spacing2,
              AppTheme.spacing4,
              AppTheme.spacing4,
            ),
            child: Row(
              children: [
                Expanded(
                  child: dashboardCard(
                    value: '${vm.activeJobCount}',
                    label: '내 공고',
                    gradient: const LinearGradient(
                      colors: [Color(0xFF9333EA), Color(0xFFEC4899)],
                    ),
                    onTap: openJobsList,
                  ),
                ),
                const SizedBox(width: AppTheme.spacing3),
                Expanded(
                  child: dashboardCard(
                    value: '${vm.pendingApplicantsCount}',
                    label: '대기 지원자',
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFF06B6D4)],
                    ),
                    onTap: openApplicants,
                  ),
                ),
                const SizedBox(width: AppTheme.spacing3),
                Expanded(
                  child: dashboardCard(
                    value: '${vm.todayModelMatchingCount}',
                    label: '오늘 모델매칭',
                    gradient: const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF059669)],
                    ),
                    onTap: openSchedule,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: ColoredBox(
            color: AppTheme.backgroundGray,
            child: ShopHomePopularSparesSection(
              spares: vm.popularSpares,
              onSeeMore: () => _openSparesList(context),
              onSpareTap: (spare) => context.push(
                AppRoutes.shopHomeSpareDetail(spare.id),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: ColoredBox(
            color: AppTheme.backgroundGray,
            child: ShopHomeTipsBanner(
              onTap: () => context.push(AppRoutes.shopHomeMatchingTips),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: ShopHomeNewSparesSection(
            spares: vm.newSpares,
            onSeeMore: () => _openSparesList(context),
            onSpareTap: (spare) => context.push(
              AppRoutes.shopHomeSpareDetail(spare.id),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: ShopHomeNearbySparesSection(
            spares: vm.nearbySpares,
            regionLabel: vm.shopRegionLabel,
            onSeeMore: () => _openSparesList(context),
            onSpareTap: (spare) => context.push(
              AppRoutes.shopHomeSpareDetail(spare.id),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: ShopHomeRegularSparesSection(
            spares: vm.regularSpares,
            onSeeMore: () => _openSparesList(context),
            onSpareTap: (spare) => context.push(
              AppRoutes.shopHomeSpareDetail(spare.id),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: ColoredBox(
            color: AppTheme.backgroundGray,
            child: Column(
              children: [
                const CustomerServiceSection(),
                SizedBox(height: bottomInset + 24),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
