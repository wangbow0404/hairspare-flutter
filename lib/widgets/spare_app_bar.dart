import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_bar_navigation.dart';
import '../utils/icon_mapper.dart';
import '../utils/navigation_helper.dart';
import '../providers/chat_provider.dart';
import '../widgets/notification_bell.dart';

/// 스케줄/출근체크 페이지와 동일한 고정 상단 네비게이션바
/// [showBackButton] true면 좌측에 뒤로가기, false면 로고 (홈 이동)
/// 뒤로가기: 상세페이지용 / 로고: 목록·메인 페이지용
class SpareAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// 검색 기능 표시 여부 (기본 true)
  final bool showSearch;
  /// 상세페이지 등에서 좌측에 뒤로가기 버튼 표시 (기본 false)
  final bool showBackButton;
  /// [showBackButton]일 때 로고 대신 표시할 제목
  final String? title;
  /// 제목 아래 보조 문구 (공고명 등)
  final String? subtitle;
  /// 검색·메시지·알림 아이콘 (채팅방 등에서는 false)
  final bool showTrailingIcons;
  /// 우측에 표시할 커스텀 액션 위젯 (예: 공유 버튼)
  final List<Widget>? actions;

  const SpareAppBar({
    super.key,
    this.showSearch = true,
    this.showBackButton = false,
    this.title,
    this.subtitle,
    this.showTrailingIcons = true,
    this.actions,
  });

  /// [kToolbarHeight]만 쓰면 세로 패딩·로고 텍스트 높이를 합친 실제 높이를 넘어
  /// Scaffold가 앱바를 잘라 로고 하단이 클리핑된다.
  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.backgroundWhite,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.borderGray,
            width: 1,
          ),
        ),
      ),
      padding: AppTheme.spacingSymmetric(
        horizontal: AppTheme.spacing4,
        vertical: AppTheme.spacing2,
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (showBackButton) ...[
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.of(context).maybePop(),
                  borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                  child: Container(
                    padding: const EdgeInsets.all(AppTheme.spacing2),
                    child: IconMapper.icon(
                          'chevronleft',
                          size: 24,
                          color: AppTheme.textSecondary,
                        ) ??
                        const Icon(
                          Icons.arrow_back_ios,
                          size: 20,
                          color: AppTheme.textSecondary,
                        ),
                  ),
                ),
              ),
              if (title != null)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: AppTheme.spacing1),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                  ),
                        ),
                        if (subtitle != null && subtitle!.isNotEmpty)
                          Text(
                            subtitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                    ),
                          ),
                      ],
                    ),
                  ),
                )
              else
                const Spacer(),
            ] else
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: AppTheme.borderRadius(AppTheme.radiusMd),
                  onTap: () {
                    NavigationHelper.navigateToHomeFromLogo(context);
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing1,
                      vertical: AppTheme.spacing2,
                    ),
                    child: _SpareLogoText(),
                  ),
                ),
              ),
            if (!showBackButton) const Spacer(),
            if (actions != null && actions!.isNotEmpty) ...[
              ...actions!,
              const SizedBox(width: AppTheme.spacing2),
            ],
            if (showTrailingIcons && showSearch) ...[
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => AppBarNavigation.pushSearch(context),
                  borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                  child: Container(
                    padding: const EdgeInsets.all(AppTheme.spacing2),
                    child: IconMapper.icon('search', size: 24, color: AppTheme.textSecondary) ??
                        const Icon(Icons.search, size: 24, color: AppTheme.textSecondary),
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spacing3),
            ],
            if (showTrailingIcons)
              Consumer<ChatProvider>(
              builder: (context, chatProvider, _) {
                final unreadCount = chatProvider.totalUnreadCount;
                return Stack(
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => AppBarNavigation.pushMessages(context),
                        borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                        child: Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          child: IconMapper.icon('messagecircle', size: 24, color: AppTheme.textSecondary) ??
                              const Icon(Icons.message_outlined, size: 24, color: AppTheme.textSecondary),
                        ),
                      ),
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IgnorePointer(
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: AppTheme.urgentRed,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            if (showTrailingIcons) ...[
              const SizedBox(width: AppTheme.spacing3),
              const SizedBox(
                width: 40,
                height: 40,
                child: Center(
                  child: NotificationBell(role: 'spare'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SpareLogoText extends StatelessWidget {
  const _SpareLogoText();

  @override
  Widget build(BuildContext context) {
    return Text(
      'HairSpare',
      strutStyle: const StrutStyle(
        fontSize: 20,
        height: 1.15,
        forceStrutHeight: true,
      ),
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: 20,
            height: 1.15,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryBlue,
          ),
    );
  }
}
