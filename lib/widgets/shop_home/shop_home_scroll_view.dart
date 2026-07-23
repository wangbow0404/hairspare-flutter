import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../theme/hairspare_colors.dart';
import '../../widgets/category_grid.dart';
import '../../widgets/customer_service_section.dart';
import '../../widgets/design_system/hs_filter_chip.dart';
import '../../view_models/shop_home_view_model.dart';
import 'shop_home_app_bar.dart';
import 'shop_home_quick_menu.dart';
import 'shop_home_spare_sections.dart';
import 'shop_home_tips_banner.dart';

/// a안 샵 홈 본문 — pending 배너, KPI 단색, 필터칩, 스페어 그리드.
class ShopHomeScrollView extends StatefulWidget {
  const ShopHomeScrollView({super.key, required this.scrollController});

  final ScrollController scrollController;

  @override
  State<ShopHomeScrollView> createState() => _ShopHomeScrollViewState();
}

class _ShopHomeScrollViewState extends State<ShopHomeScrollView> {
  String _filter = 'all';

  static const _filters = <String, String>{
    'all': '전체',
    'rating': '평점순',
    'experience': '경력순',
    'nearby': '근처',
  };

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

    void openSparesList() {
      context.push(AppRoutes.shopHomeSpares);
    }

    Widget kpiCard({
      required String value,
      required String label,
      required VoidCallback onTap,
    }) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacing3),
          decoration: BoxDecoration(
            color: HairSpareColors.surfaceMuted,
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            border: Border.all(color: HairSpareColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: HairSpareColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppTheme.spacing1),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: HairSpareColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return CustomScrollView(
      controller: widget.scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            decoration: const BoxDecoration(
              color: HairSpareColors.surface,
              border: Border(
                bottom: BorderSide(color: HairSpareColors.border),
              ),
            ),
            padding: EdgeInsets.fromLTRB(
              AppTheme.spacing4,
              MediaQuery.paddingOf(context).top + AppTheme.spacing2,
              AppTheme.spacing4,
              AppTheme.spacing3,
            ),
            child: ShopHomeAppBarRow(scrollController: widget.scrollController),
          ),
        ),
        if (vm.pendingApplicantsCount > 0)
          SliverToBoxAdapter(
            child: Material(
              color: HairSpareColors.brandPrimarySoft,
              child: InkWell(
                onTap: openApplicants,
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacing4),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.person_add_alt_1_outlined,
                        color: HairSpareColors.brandPrimary,
                      ),
                      const SizedBox(width: AppTheme.spacing3),
                      Expanded(
                        child: Text(
                          '대기 중인 지원자 ${vm.pendingApplicantsCount}명',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: HairSpareColors.textPrimary,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: HairSpareColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.spacing4,
              AppTheme.spacing4,
              AppTheme.spacing4,
              AppTheme.spacing2,
            ),
            child: Row(
              children: [
                Expanded(
                  child: kpiCard(
                    value: '${vm.activeJobCount}',
                    label: '내 공고',
                    onTap: openJobsList,
                  ),
                ),
                const SizedBox(width: AppTheme.spacing3),
                Expanded(
                  child: kpiCard(
                    value: '${vm.pendingApplicantsCount}',
                    label: '대기 지원자',
                    onTap: openApplicants,
                  ),
                ),
                const SizedBox(width: AppTheme.spacing3),
                Expanded(
                  child: kpiCard(
                    value: '${vm.todayModelMatchingCount}',
                    label: '오늘 모델매칭',
                    onTap: openSchedule,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: CategoryGrid(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.spacing4,
              0,
              AppTheme.spacing4,
              AppTheme.spacing4,
            ),
            wrapInCard: false,
            crossAxisCount: 4,
            categories: ShopHomeQuickMenu.buildCategories(context),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing4),
              itemCount: _filters.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: AppTheme.spacing2),
              itemBuilder: (context, index) {
                final key = _filters.keys.elementAt(index);
                return HsFilterChip(
                  label: _filters[key]!,
                  isSelected: _filter == key,
                  onTap: () => setState(() => _filter = key),
                );
              },
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: ColoredBox(
            color: AppTheme.backgroundGray,
            child: ShopHomePopularSparesSection(
              spares: vm.popularSpares,
              onSeeMore: openSparesList,
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
            onSeeMore: openSparesList,
            onSpareTap: (spare) => context.push(
              AppRoutes.shopHomeSpareDetail(spare.id),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: ShopHomeNearbySparesSection(
            spares: vm.nearbySpares,
            regionLabel: vm.shopRegionLabel,
            onSeeMore: openSparesList,
            onSpareTap: (spare) => context.push(
              AppRoutes.shopHomeSpareDetail(spare.id),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: ShopHomeRegularSparesSection(
            spares: vm.regularSpares,
            onSeeMore: openSparesList,
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
