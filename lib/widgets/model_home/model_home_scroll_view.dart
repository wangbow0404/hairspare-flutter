import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/model_home_data.dart';
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
              final profile = ModelHomeProfileSummary(
                name: user?.name ?? user?.username ?? '모델',
                photoUrl: user?.profileImage,
                regionLabel: '',
                hairLength: '',
                intro: '',
                completionPercent: 0.0,
                isIdentityVerified: false,
                todayInterestCount: pendingCount,
                matchingVisible: true,
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
        const SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ModelHomeUpcomingScheduleSection(schedules: []),
              SizedBox(height: AppTheme.spacing6),
              CustomerServiceSection(),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(height: MediaQuery.paddingOf(context).bottom + 24),
        ),
      ],
    );
  }
}
