import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../mocks/mock_model_home_data.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../view_models/matching_view_model.dart';
import '../../widgets/customer_service_section.dart';
import '../../utils/app_screen_insets.dart';
import 'model_home_app_bar.dart';
import 'model_home_interest_section.dart';
import 'model_home_profile_card.dart';
import 'model_home_status_strip.dart';
import 'model_home_upcoming_schedule_section.dart';

/// 모델 전용 홈 스크롤 본문 (Stitch Model Home).
class ModelHomeScrollView extends StatelessWidget {
  const ModelHomeScrollView({super.key, required this.scrollController});

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final schedules = MockModelHomeData.upcomingSchedules;

    return CustomScrollView(
      controller: scrollController,
      cacheExtent: 240,
      slivers: [
        AppScreenInsets.pinnedTopBarSliver(
          context: context,
          child: ModelHomeAppBarRow(scrollController: scrollController),
        ),
        SliverToBoxAdapter(
          child: Selector<MatchingViewModel, int>(
            selector: (_, vm) => vm.pendingCount,
            builder: (context, pendingCount, _) {
              final profile = MockModelHomeData.profileForUser(
                user,
                todayInterestCount: pendingCount,
              );
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppTheme.spacing4),
                  ModelHomeProfileCard(profile: profile),
                  const SizedBox(height: AppTheme.spacing4),
                  ModelHomeStatusStrip(
                    isIdentityVerified: profile.isIdentityVerified,
                    todayInterestCount: profile.todayInterestCount,
                  ),
                ],
              );
            },
          ),
        ),
        ...ModelHomeInterestSection.buildSlivers(context),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ModelHomeUpcomingScheduleSection(schedules: schedules),
              const SizedBox(height: AppTheme.spacing6),
              const CustomerServiceSection(),
              SizedBox(height: MediaQuery.paddingOf(context).bottom + 24),
            ],
          ),
        ),
      ],
    );
  }
}
