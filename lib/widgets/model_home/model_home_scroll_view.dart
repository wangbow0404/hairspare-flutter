import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../mocks/mock_model_home_data.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/customer_service_section.dart';
import '../../widgets/spare_home/spare_home_app_bar.dart';
import 'model_home_interest_section.dart';
import 'model_home_profile_card.dart';
import 'model_home_quick_menu.dart';
import 'model_home_status_strip.dart';
import 'model_home_upcoming_schedule_section.dart';

/// 모델 전용 홈 스크롤 본문 (Stitch Model Home).
class ModelHomeScrollView extends StatelessWidget {
  const ModelHomeScrollView({super.key, required this.scrollController});

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final profile = MockModelHomeData.profileForUser(user);
    final interests = MockModelHomeData.interests;
    final schedules = MockModelHomeData.upcomingSchedules;

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
              child: SpareHomeAppBarRow(scrollController: scrollController),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppTheme.spacing4),
              ModelHomeProfileCard(profile: profile),
              const SizedBox(height: AppTheme.spacing4),
              ModelHomeStatusStrip(
                isIdentityVerified: profile.isIdentityVerified,
                todayInterestCount: profile.todayInterestCount,
              ),
              const SizedBox(height: AppTheme.spacing6),
              ModelHomeInterestSection(interests: interests),
              const SizedBox(height: AppTheme.spacing6),
              ModelHomeUpcomingScheduleSection(schedules: schedules),
              const SizedBox(height: AppTheme.spacing6),
              const ModelHomeQuickMenu(),
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
