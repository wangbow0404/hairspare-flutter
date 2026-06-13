import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/di/service_locator.dart';
import '../core/router/app_navigation.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
/// 관리자 레이아웃 위젯 (사이드바 + 헤더)
class AdminLayout extends StatefulWidget {
  final Widget child;
  final String currentRoute;

  const AdminLayout({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  /// Drawer 등에서 MediaQuery top이 0일 때도 실제 노치/상태바 높이를 쓴다.
  static double _statusBarTopInset(BuildContext context) {
    final fromView = MediaQueryData.fromView(View.of(context)).viewPadding.top;
    final fromQuery = MediaQuery.viewPaddingOf(context).top;
    return fromView > fromQuery ? fromView : fromQuery;
  }

  final List<AdminNavItem> _navItems = [
    AdminNavItem(
      route: '/admin',
      label: '대시보드',
      icon: Icons.dashboard,
    ),
    AdminNavItem(
      route: '/admin/users',
      label: '회원 관리',
      icon: Icons.people,
    ),
    AdminNavItem(
      route: '/admin/jobs',
      label: '공고 관리',
      icon: Icons.work,
    ),
    AdminNavItem(
      route: '/admin/payments',
      label: '결제 관리',
      icon: Icons.payment,
    ),
    AdminNavItem(
      route: '/admin/energy',
      label: '에너지 관리',
      icon: Icons.bolt,
    ),
    AdminNavItem(
      route: '/admin/noshow',
      label: '노쇼 관리',
      icon: Icons.warning,
    ),
    AdminNavItem(
      route: '/admin/checkin',
      label: '체크인 관리',
      icon: Icons.calendar_today,
    ),
  ];

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('로그아웃하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await sl<AuthProvider>().logout();
              if (!context.mounted) return;
              AppNavigation.goRoleSelect(context);
            },
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );
  }

  void _navigateToRoute(String route) {
    if (widget.currentRoute == route) return;
    context.go(route);
  }

  void _onNavItemTap(AdminNavItem item, bool isMobile) {
    if (isMobile) {
      Navigator.of(context).pop();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        context.go(item.route);
      });
    } else {
      _navigateToRoute(item.route);
    }
  }

  Widget _buildSidebar(
    BuildContext context,
    bool isMobile, {
    double topPadding = 0,
  }) {
    bool isActive(String route) {
      if (route == '/admin') {
        return widget.currentRoute == route;
      }
      return widget.currentRoute.startsWith(route);
    }

    return Container(
      width: isMobile ? double.infinity : 288,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: isMobile ? 0.98 : 0.95),
        border: isMobile
            ? null
            : const Border(
                right: BorderSide(color: AppTheme.adminPurple100),
              ),
        boxShadow: isMobile ? null : AppTheme.shadowXl,
      ),
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          AppTheme.spacing4,
          topPadding + AppTheme.spacing4,
          AppTheme.spacing4,
          AppTheme.spacing4,
        ),
        children: _navItems.map((item) {
          final active = isActive(item.route);
          return Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.spacing2),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _onNavItemTap(item, isMobile),
                borderRadius: BorderRadius.circular(AppTheme.radius2xl),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing4,
                    vertical: AppTheme.spacing3 + 2,
                  ),
                  decoration: BoxDecoration(
                    gradient: active
                        ? const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              AppTheme.primaryPurple500,
                              AppTheme.primaryPink,
                            ],
                          )
                        : null,
                    borderRadius: BorderRadius.circular(AppTheme.radius2xl),
                    color: active ? null : Colors.transparent,
                    boxShadow: active ? AppTheme.shadowLg : null,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        item.icon,
                        size: 20,
                        color: active
                            ? Colors.white
                            : AppTheme.textSecondary,
                      ),
                      const SizedBox(width: AppTheme.spacing3),
                      Expanded(
                        child: Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: active
                                ? Colors.white
                                : AppTheme.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 768;
    final isNarrow = width < 480;
    final isVeryNarrow = width < 360;

    return Scaffold(
      key: _scaffoldKey,
      drawer: isMobile
          ? Drawer(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              child: Builder(
                builder: (drawerContext) {
                  final topInset = _statusBarTopInset(drawerContext);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: topInset),
                      Expanded(
                        child: _buildSidebar(
                          drawerContext,
                          true,
                          topPadding: 0,
                        ),
                      ),
                    ],
                  );
                },
              ),
            )
          : null,
      body: Container(
        decoration: AppTheme.adminBackgroundGradient,
        child: Column(
          children: [
            // 헤더 — [SpareAppBar]와 동일하게 SafeArea를 내부에 둠
            DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                border: const Border(
                  bottom: BorderSide(color: AppTheme.adminPurple100, width: 1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SafeArea(
                bottom: false,
                child: SizedBox(
                  height: isMobile ? 56 : 80,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isVeryNarrow
                          ? AppTheme.spacing1
                          : (isMobile ? AppTheme.spacing2 : AppTheme.spacing3),
                    ),
                    child: Row(
                    children: [
                      // 햄버거 메뉴 (모바일)
                      if (isMobile)
                        IconButton(
                          icon: Icon(Icons.menu, color: AppTheme.textPrimary, size: isVeryNarrow ? 20 : 24),
                          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                          style: IconButton.styleFrom(
                            minimumSize: isVeryNarrow ? const Size(36, 36) : const Size(48, 48),
                            padding: isVeryNarrow ? const EdgeInsets.all(8) : null,
                          ),
                        ),
                      // 로고 (클릭 시 대시보드로 이동)
                      Expanded(
                        child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _navigateToRoute('/admin'),
                          borderRadius: BorderRadius.circular(AppTheme.radius2xl),
                          splashColor: AppTheme.primaryPurple500.withValues(alpha: 0.2),
                          highlightColor: AppTheme.primaryPurple500.withValues(alpha: 0.1),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: isVeryNarrow ? AppTheme.spacing1 : AppTheme.spacing2,
                              vertical: isVeryNarrow ? 4 : (isMobile ? AppTheme.spacing1 : AppTheme.spacing2),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: isVeryNarrow ? 28 : (isMobile ? 36 : 40),
                                  height: isVeryNarrow ? 28 : (isMobile ? 36 : 40),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [AppTheme.primaryPurple500, AppTheme.primaryPink],
                            ),
                            borderRadius: BorderRadius.circular(AppTheme.radius2xl),
                            boxShadow: AppTheme.shadowLg,
                          ),
                          child: Center(
                            child: Text(
                              'H',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isVeryNarrow ? 14 : (isMobile ? 16 : 18),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        if (!isVeryNarrow) ...[
                          SizedBox(width: isMobile ? AppTheme.spacing1 : AppTheme.spacing2),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'HairSpare',
                                    style: TextStyle(
                                      fontSize: isMobile ? 12 : 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryPurple,
                                    ),
                                    maxLines: 1,
                                  ),
                                  Text(
                                    '관리자',
                                    style: TextStyle(
                                      fontSize: isMobile ? 9 : 11,
                                      color: AppTheme.textSecondary,
                                    ),
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
                    // 오른쪽 영역 (최소 공간만 사용, 오버플로우 방지)
            Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!isMobile && !isNarrow)
                          Flexible(
                            fit: FlexFit.loose,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppTheme.spacing2,
                                vertical: AppTheme.spacing1,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    AppTheme.adminPurple50,
                                    AppTheme.adminPink50,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: AppTheme.primaryGreen,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: AppTheme.spacing1),
                                  const Flexible(
                                    child: Text(
                                      '실시간 업데이트 중',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textGray700,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (isMobile)
                          IconButton(
                            icon: const Icon(Icons.dashboard, size: 20, color: AppTheme.textSecondary),
                            onPressed: () => _navigateToRoute('/admin'),
                            style: IconButton.styleFrom(
                              minimumSize: const Size(36, 36),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        if (!isMobile && !isNarrow) ...[
                          const SizedBox(width: AppTheme.spacing2),
                          Flexible(
                            fit: FlexFit.loose,
                            child: TextButton.icon(
                              onPressed: () => _navigateToRoute('/admin'),
                              icon: const Icon(Icons.dashboard, size: 18, color: AppTheme.textSecondary),
                              label: const Text(
                                '대시보드',
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppTheme.spacing1),
                        ],
                        const SizedBox(width: AppTheme.spacing1),
                        isMobile
                            ? IconButton(
                                icon: const Icon(Icons.logout, size: 20, color: AppTheme.textSecondary),
                                onPressed: _handleLogout,
                                style: IconButton.styleFrom(
                                  minimumSize: const Size(36, 36),
                                  padding: EdgeInsets.zero,
                                ),
                              )
                            : TextButton.icon(
                                onPressed: _handleLogout,
                                icon: const Icon(Icons.logout, size: 16, color: AppTheme.textSecondary),
                                label: const Text(
                                  '로그아웃',
                                  style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 13,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            ),
            ),
            // 본문
            Expanded(
              child: SafeArea(
                top: false,
                left: false,
                right: false,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isMobile) _buildSidebar(context, false),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(
                          isMobile ? AppTheme.spacing3 : AppTheme.spacing4,
                        ),
                        child: widget.child,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminNavItem {
  final String route;
  final String label;
  final IconData icon;

  AdminNavItem({
    required this.route,
    required this.label,
    required this.icon,
  });
}
