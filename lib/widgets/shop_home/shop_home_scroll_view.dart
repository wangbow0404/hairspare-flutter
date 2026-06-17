import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/app_theme.dart';
import '../../theme/home_text_styles.dart';
import '../../widgets/stitch/stitch_hero_banner.dart';
import '../../widgets/category_grid.dart';
import '../../widgets/customer_service_section.dart';
import '../../screens/shop/applicants_screen.dart';
import '../../screens/shop/challenge_screen.dart';
import '../../screens/shop/education_screen.dart';
import '../../screens/shop/jobs_list_screen.dart';
import '../../screens/shop/my_spaces_screen.dart';
import '../../screens/shop/points_screen.dart';
import '../../screens/shop/schedule_screen.dart';
import '../../screens/shop/spares_list_screen.dart';
import '../../view_models/shop_home_view_model.dart';
import 'shop_home_app_bar.dart';
import 'shop_home_spare_sections.dart';

/// 샵 홈 본문 스크롤(배너·카테고리·대시보드·리스트). 데이터는 [ShopHomeViewModel].
class ShopHomeScrollView extends StatelessWidget {
  const ShopHomeScrollView({super.key, required this.scrollController});

  final ScrollController scrollController;

  void _openSparesList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ShopSparesListScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ShopHomeViewModel>();
    final bottomInset = MediaQuery.of(context).padding.bottom;

    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    Future<void> openJobsList() async {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ShopJobsListScreen()),
      );
      if (context.mounted) {
        await context.read<ShopHomeViewModel>().loadInitial();
      }
    }

    Future<void> openApplicants() async {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ShopApplicantsScreen()),
      );
      if (context.mounted) {
        await context.read<ShopHomeViewModel>().loadInitial();
      }
    }

    void openSchedule() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ShopScheduleScreen()),
      );
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
                categories: [
                  CategoryItem(
                    emoji: '',
                    icon: Icons.groups_2_outlined,
                    label: '인력별',
                    color: AppTheme.primaryPurple,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ShopSparesListScreen(),
                        ),
                      );
                    },
                  ),
                  CategoryItem(
                    emoji: '',
                    icon: Icons.event_note_outlined,
                    label: '스케줄표',
                    color: AppTheme.primaryBlue,
                    onTap: openSchedule,
                  ),
                  CategoryItem(
                    emoji: '',
                    icon: Icons.storefront_outlined,
                    label: '스토어',
                    color: AppTheme.primaryGreen,
                    onTap: () {
                      showDialog<void>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('준비 중'),
                          content: const Text('스토어 기능은 준비 중입니다.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('확인'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  CategoryItem(
                    emoji: '',
                    icon: Icons.add_card_outlined,
                    label: '+포인트',
                    color: AppTheme.orange500,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ShopPointsScreen(),
                        ),
                      );
                    },
                  ),
                  CategoryItem(
                    emoji: '',
                    icon: Icons.meeting_room_outlined,
                    label: '공간대여',
                    color: AppTheme.primaryPink,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ShopMySpacesScreen(),
                        ),
                      );
                    },
                  ),
                  CategoryItem(
                    emoji: '',
                    icon: Icons.school_outlined,
                    label: '교육',
                    color: AppTheme.primaryPurple,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ShopEducationScreen(),
                        ),
                      );
                    },
                  ),
                  CategoryItem(
                    emoji: '',
                    icon: Icons.workspace_premium_outlined,
                    label: '챌린지',
                    color: AppTheme.primaryBlueDark,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ShopChallengeScreen(),
                        ),
                      );
                    },
                  ),
                  CategoryItem(
                    emoji: '',
                    icon: Icons.lightbulb_outline,
                    label: '커넥트',
                    color: AppTheme.yellow600,
                    onTap: () {
                      showDialog<void>(
                        context: context,
                        barrierDismissible: true,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppTheme.radius2xl,
                            ),
                          ),
                          title: const Text('준비 중'),
                          content: const Text('커넥트 기능은 준비 중입니다.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('확인'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
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
                    label: '활성 공고',
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
                    value: '${vm.todayScheduleCount}',
                    label: '오늘 일정',
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
              onSpareTap: (_) => _openSparesList(context),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: ShopHomeNewSparesSection(
            spares: vm.newSpares,
            onSeeMore: () => _openSparesList(context),
            onSpareTap: (_) => _openSparesList(context),
          ),
        ),
        if (vm.regularSpares.isNotEmpty)
          SliverToBoxAdapter(
            child: ShopHomeRegularSparesSection(
              spares: vm.regularSpares,
              onSeeMore: () => _openSparesList(context),
              onSpareTap: (_) => _openSparesList(context),
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
