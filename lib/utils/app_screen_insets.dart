import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// 상태바·노치·홈 인디케이터 inset 계산 및 커스텀 상단바 레이아웃.
abstract final class AppScreenInsets {
  AppScreenInsets._();

  /// 툴바 콘텐츠 영역 높이 (status bar 제외).
  static const double toolbarHeight = 44.0;

  static double statusBarTop(BuildContext context) =>
      MediaQuery.paddingOf(context).top;

  static double homeIndicatorBottom(BuildContext context) =>
      MediaQuery.paddingOf(context).bottom;

  /// status bar + [toolbarHeight].
  static double topBarHeight(BuildContext context) =>
      statusBarTop(context) + toolbarHeight;

  static EdgeInsets topBarPadding(
    BuildContext context, {
    double horizontal = AppTheme.spacing4,
  }) =>
      EdgeInsets.only(
        top: statusBarTop(context),
        left: horizontal,
        right: horizontal,
      );

  /// 홈·탭 루트 등 Sliver 상단바 — status bar 아래 44px Row 배치.
  static Widget topBarShell({
    required BuildContext context,
    required Widget child,
    Color backgroundColor = AppTheme.backgroundWhite,
    bool showBottomBorder = true,
  }) {
    return Container(
      height: topBarHeight(context),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: showBottomBorder
            ? const Border(
                bottom: BorderSide(color: AppTheme.borderGray, width: 1),
              )
            : null,
      ),
      padding: topBarPadding(context),
      child: SizedBox(height: toolbarHeight, child: child),
    );
  }

  /// 스크롤해도 status bar 영역과 겹치지 않도록 상단바를 고정.
  static Widget pinnedTopBarSliver({
    required BuildContext context,
    required Widget child,
    Color backgroundColor = AppTheme.backgroundWhite,
    bool showBottomBorder = true,
  }) {
    final height = topBarHeight(context);
    return SliverPersistentHeader(
      pinned: true,
      delegate: _PinnedTopBarSliverDelegate(
        height: height,
        child: topBarShell(
          context: context,
          child: child,
          backgroundColor: backgroundColor,
          showBottomBorder: showBottomBorder,
        ),
      ),
    );
  }
}

class _PinnedTopBarSliverDelegate extends SliverPersistentHeaderDelegate {
  _PinnedTopBarSliverDelegate({
    required this.height,
    required this.child,
  });

  final double height;
  final Widget child;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _PinnedTopBarSliverDelegate oldDelegate) {
    return height != oldDelegate.height || child != oldDelegate.child;
  }
}
