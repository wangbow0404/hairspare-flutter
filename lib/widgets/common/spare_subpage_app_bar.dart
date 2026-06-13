import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/chat_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_bar_navigation.dart';
import '../../utils/icon_mapper.dart';
import '../notification_bell.dart';
import 'shared_app_bar.dart';

/// 스페어 서브화면용 상단바 — 뒤로가기, 좌측 타이틀, 검색·채팅(뱃지)·알림(뱃지), 하단 그라데이션.
class SpareSubpageAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SpareSubpageAppBar({
    super.key,
    required this.title,
    this.gradientStyle = SpareSubpageAppBarGradientStyle.bluePurple,
    this.showBackButton = true,
    this.onBackPressed,
    this.onSearchPressed,
  });

  final String title;
  final SpareSubpageAppBarGradientStyle gradientStyle;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final VoidCallback? onSearchPressed;

  static const double _gradientHeight = 4;

  LinearGradient get _gradient {
    switch (gradientStyle) {
      case SpareSubpageAppBarGradientStyle.bluePurple:
        return const LinearGradient(
          colors: [AppTheme.primaryBlue, AppTheme.primaryPurple],
        );
      case SpareSubpageAppBarGradientStyle.purplePink:
        return const LinearGradient(
          colors: [AppTheme.primaryPurple, AppTheme.primaryPink],
        );
    }
  }

  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight + _gradientHeight);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppBar(
          elevation: 0,
          scrolledUnderElevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          backgroundColor: AppTheme.backgroundWhite,
          foregroundColor: AppTheme.textPrimary,
          automaticallyImplyLeading: false,
          leading: showBackButton
              ? IconButton(
                  icon: IconMapper.icon(
                        'chevronleft',
                        size: 24,
                        color: AppTheme.textSecondary,
                      ) ??
                      const Icon(
                        Icons.arrow_back_ios,
                        size: 20,
                        color: AppTheme.textSecondary,
                      ),
                  onPressed:
                      onBackPressed ?? () => Navigator.maybePop(context),
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                )
              : null,
          title: Text(title, style: SharedAppBar.titleTextStyle(context)),
          centerTitle: false,
          titleSpacing:
              showBackButton ? 0 : NavigationToolbar.kMiddleSpacing,
          actions: [
            IconButton(
              icon: IconMapper.icon(
                    'search',
                    size: 24,
                    color: AppTheme.textSecondary,
                  ) ??
                  const Icon(
                    Icons.search,
                    size: 24,
                    color: AppTheme.textSecondary,
                  ),
              onPressed: () {
                if (onSearchPressed != null) {
                  onSearchPressed!();
                } else {
                  AppBarNavigation.pushSearch(context);
                }
              },
              tooltip: '검색',
            ),
            Consumer<ChatProvider>(
              builder: (context, chatProvider, _) {
                final unreadCount = chatProvider.totalUnreadCount;
                return Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: IconMapper.icon(
                            'messagecircle',
                            size: 24,
                            color: AppTheme.textSecondary,
                          ) ??
                          const Icon(
                            Icons.chat_bubble_outline,
                            size: 24,
                            color: AppTheme.textSecondary,
                          ),
                      onPressed: () => AppBarNavigation.pushMessages(context),
                      tooltip: '메시지',
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        right: 10,
                        top: 10,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppTheme.urgentRed,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            const Padding(
              padding: EdgeInsets.only(right: AppTheme.spacing2),
              child: NotificationBell(role: 'spare'),
            ),
          ],
        ),
        Container(
          height: _gradientHeight,
          width: double.infinity,
          decoration: BoxDecoration(gradient: _gradient),
        ),
      ],
    );
  }
}

/// 하단 그라데이션 스타일 (스케줄·공고: 파랑→보라, 포인트 등: 보라→핑크).
enum SpareSubpageAppBarGradientStyle {
  bluePurple,
  purplePink,
}
