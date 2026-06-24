import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/di/service_locator.dart';
import '../core/router/app_navigation.dart';
import '../providers/auth_provider.dart';
import '../core/router/app_routes.dart';
import '../services/admin_service.dart';
import '../theme/admin_stitch_theme.dart';
import '../theme/app_theme.dart';
import 'common/hairspare_brand_assets.dart';
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
  final AdminService _adminService = AdminService();
  Map<String, int> _badgeCounts = {};
  final Set<String> _expandedGroups = {
    '회원·인증',
    '거래·매칭',
    '경제·포인트',
    '신뢰·안전',
    '운영설정',
    '감사',
  };

  static const _dashboardItem = AdminNavItem(
    route: AppRoutes.admin,
    label: '대시보드',
    icon: Icons.dashboard,
  );

  static const _navGroups = <AdminNavGroup>[
    AdminNavGroup(
      title: '회원·인증',
      items: [
        AdminNavItem(
          route: AppRoutes.adminUsers,
          label: '회원 관리',
          icon: Icons.people,
        ),
        AdminNavItem(
          route: AppRoutes.adminVerifications,
          label: '인증 심사',
          icon: Icons.verified_user,
          badgeKey: 'pendingVerifications',
        ),
      ],
    ),
    AdminNavGroup(
      title: '거래·매칭',
      items: [
        AdminNavItem(route: AppRoutes.adminJobs, label: '공고 관리', icon: Icons.work),
        AdminNavItem(route: AppRoutes.adminCheckin, label: '스케줄·체크인', icon: Icons.calendar_today),
        AdminNavItem(route: AppRoutes.adminMatches, label: '모델 매칭', icon: Icons.favorite),
        AdminNavItem(route: AppRoutes.adminSpaces, label: '공간 대여', icon: Icons.meeting_room, badgeKey: 'pendingBookings'),
        AdminNavItem(route: AppRoutes.adminEducations, label: '교육 관리', icon: Icons.school, badgeKey: 'pendingEducations'),
      ],
    ),
    AdminNavGroup(
      title: '경제·포인트',
      items: [
        AdminNavItem(route: AppRoutes.adminPayments, label: '결제 관리', icon: Icons.payment),
        AdminNavItem(route: AppRoutes.adminEnergy, label: '에너지 관리', icon: Icons.bolt),
        AdminNavItem(route: AppRoutes.adminPoints, label: '포인트·미션', icon: Icons.stars),
        AdminNavItem(route: AppRoutes.adminSubscriptions, label: '구독 관리', icon: Icons.subscriptions),
      ],
    ),
    AdminNavGroup(
      title: '신뢰·안전',
      items: [
        AdminNavItem(route: AppRoutes.adminReports, label: '신고/제재 케이스', icon: Icons.report, badgeKey: 'openReports'),
        AdminNavItem(route: AppRoutes.adminSanctions, label: '제재 실행·이력', icon: Icons.gavel),
        AdminNavItem(route: AppRoutes.adminContent, label: '콘텐츠 모더레이션', icon: Icons.video_library, badgeKey: 'flaggedContent'),
        AdminNavItem(route: AppRoutes.adminNoshow, label: '노쇼 관리', icon: Icons.warning),
      ],
    ),
    AdminNavGroup(
      title: '운영설정',
      items: [
        AdminNavItem(route: AppRoutes.adminSettings, label: '비즈니스 설정', icon: Icons.tune),
        AdminNavItem(route: AppRoutes.adminNotifications, label: '알림 발송', icon: Icons.campaign),
        AdminNavItem(route: AppRoutes.adminReference, label: '레퍼런스 데이터', icon: Icons.dataset),
      ],
    ),
    AdminNavGroup(
      title: '감사',
      items: [
        AdminNavItem(
          route: AppRoutes.adminAuditLogs,
          label: '감사 로그',
          icon: Icons.history,
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadBadgeCounts();
  }

  Future<void> _loadBadgeCounts() async {
    try {
      final stats = await _adminService.getDashboardStats();
      if (!mounted) return;
      setState(() {
        _badgeCounts = {
          'pendingVerifications': stats['pendingVerifications'] as int? ?? 0,
          'openReports': stats['openReports'] as int? ?? 0,
          'pendingBookings': stats['pendingBookings'] as int? ?? 0,
          'pendingEducations': stats['pendingEducations'] as int? ?? 0,
          'flaggedContent': 2,
        };
      });
    } catch (_) {}
  }

  /// Drawer 등에서 MediaQuery top이 0일 때도 실제 노치/상태바 높이를 쓴다.
  static double _statusBarTopInset(BuildContext context) {
    final fromView = MediaQueryData.fromView(View.of(context)).viewPadding.top;
    final fromQuery = MediaQuery.viewPaddingOf(context).top;
    return fromView > fromQuery ? fromView : fromQuery;
  }

  void _toggleGroup(String title) {
    setState(() {
      if (_expandedGroups.contains(title)) {
        _expandedGroups.remove(title);
      } else {
        _expandedGroups.add(title);
      }
    });
  }

  int? _badgeFor(AdminNavItem item) {
    if (item.badgeKey == null) return null;
    final count = _badgeCounts[item.badgeKey!] ?? 0;
    return count > 0 ? count : null;
  }

  Widget _buildNavItem(AdminNavItem item, bool isMobile, bool Function(String) isActive) {
    final active = isActive(item.route);
    final badge = _badgeFor(item);
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
                  color: active ? Colors.white : AppTheme.textSecondary,
                ),
                const SizedBox(width: AppTheme.spacing3),
                Expanded(
                  child: Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: active ? Colors.white : AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing2,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: active ? Colors.white : AppTheme.urgentRed,
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    ),
                    child: Text(
                      '$badge',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: active ? AppTheme.urgentRed : Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
        children: [
          _buildNavItem(_dashboardItem, isMobile, isActive),
          const SizedBox(height: AppTheme.spacing2),
          ..._navGroups.map((group) {
            final expanded = _expandedGroups.contains(group.title);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InkWell(
                  onTap: () => _toggleGroup(group.title),
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing2,
                      vertical: AppTheme.spacing2,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            group.title,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textTertiary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        Icon(
                          expanded ? Icons.expand_less : Icons.expand_more,
                          size: 16,
                          color: AppTheme.textTertiary,
                        ),
                      ],
                    ),
                  ),
                ),
                if (expanded)
                  ...group.items.map(
                    (item) => _buildNavItem(item, isMobile, isActive),
                  ),
                const SizedBox(height: AppTheme.spacing1),
              ],
            );
          }),
        ],
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
        color: AdminStitchTheme.bgSubtle,
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
                        if (isMobile)
                          IconButton(
                            icon: Icon(Icons.menu, color: AppTheme.textPrimary, size: isVeryNarrow ? 20 : 24),
                            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                            style: IconButton.styleFrom(
                              minimumSize: isVeryNarrow ? const Size(36, 36) : const Size(48, 48),
                              padding: isVeryNarrow ? const EdgeInsets.all(8) : null,
                            ),
                          ),
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
                                  children: [
                                    HairSpareBrandSymbol(
                                      size: isVeryNarrow ? 28 : (isMobile ? 36 : 40),
                                    ),
                                    if (!isVeryNarrow) ...[
                                      SizedBox(width: isMobile ? AppTheme.spacing1 : AppTheme.spacing2),
                                      Expanded(
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: Alignment.centerLeft,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              HairSpareBrandLogo(
                                                height: isMobile ? 18 : 22,
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
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!isMobile && !isNarrow)
                              Container(
                                constraints: const BoxConstraints(maxWidth: 180),
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
                                    const Text(
                                      '실시간 업데이트 중',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textGray700,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ],
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
                              TextButton.icon(
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
                      child: widget.child,
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
  final String? badgeKey;

  const AdminNavItem({
    required this.route,
    required this.label,
    required this.icon,
    this.badgeKey,
  });
}

class AdminNavGroup {
  final String title;
  final List<AdminNavItem> items;

  const AdminNavGroup({
    required this.title,
    required this.items,
  });
}
