import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../utils/icon_mapper.dart';
import 'hub_app_bar_actions.dart';

/// 서브 페이지 공통 상단바 — 흰 배경, 하단 보더, 그림자 없음, 통일된 타이틀·뒤로가기.
class SharedAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SharedAppBar({
    super.key,
    this.title = '',
    this.titleWidget,
    this.actions,
    this.showBackButton = true,
    this.onBackPressed,
    this.automaticallyImplyLeading = false,
    this.bottom,
    this.showHubActions = false,
  });

  /// [titleWidget]이 null일 때만 사용됩니다.
  final String title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final bool automaticallyImplyLeading;

  /// [AppBar.bottom] — 예: [TabBar].
  final PreferredSizeWidget? bottom;

  /// true면 검색·채팅·알림 아이콘을 [actions] 오른쪽(화면 끝)에 붙입니다.
  final bool showHubActions;

  /// 타이틀 텍스트 스타일 (SliverAppBar 등에서 재사용).
  static TextStyle titleTextStyle(BuildContext context) {
    return Theme.of(context).textTheme.titleLarge!.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary,
        );
  }

  @override
  Size get preferredSize {
    final h = bottom?.preferredSize.height ?? 0.0;
    return Size.fromHeight(kToolbarHeight + h);
  }

  List<Widget>? _mergedActions(BuildContext context) {
    final hub = showHubActions ? buildHubAppBarActions(context) : <Widget>[];
    final extra = actions ?? <Widget>[];
    if (hub.isEmpty && extra.isEmpty) return null;
    return [...extra, ...hub];
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      backgroundColor: AppTheme.backgroundWhite,
      foregroundColor: AppTheme.textPrimary,
      shape: const Border(
        bottom: BorderSide(color: AppTheme.borderGray, width: 1),
      ),
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: showBackButton
          ? IconButton(
              icon: IconMapper.icon('chevronleft', size: 24, color: AppTheme.textSecondary) ??
                  const Icon(Icons.arrow_back_ios, size: 20, color: AppTheme.textSecondary),
              onPressed: onBackPressed ?? () => Navigator.maybePop(context),
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            )
          : null,
      title: titleWidget ??
          Text(
            title,
            style: titleTextStyle(context),
          ),
      centerTitle: false,
      titleSpacing: showBackButton ? 0 : NavigationToolbar.kMiddleSpacing,
      actions: _mergedActions(context),
      bottom: bottom,
    );
  }
}
