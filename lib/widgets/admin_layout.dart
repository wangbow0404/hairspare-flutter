import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/admin_users_screen.dart';
import '../screens/admin/admin_jobs_screen.dart';
import '../screens/admin/admin_payments_screen.dart';
import '../screens/admin/admin_energy_screen.dart';
import '../screens/admin/admin_noshow_screen.dart';
import '../screens/admin/admin_checkin_screen.dart';
import '../screens/common/role_select_screen.dart';

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
  
  final List<AdminNavItem> _navItems = [
    AdminNavItem(
      route: '/admin',
      label: '대시보드',
      icon: Icons.dashboard,
      screen: const AdminDashboardScreen(),
    ),
    AdminNavItem(
      route: '/admin/users',
      label: '회원 관리',
      icon: Icons.people,
      screen: const AdminUsersScreen(),
    ),
    AdminNavItem(
      route: '/admin/jobs',
      label: '공고 관리',
      icon: Icons.work,
      screen: const AdminJobsScreen(),
    ),
    AdminNavItem(
      route: '/admin/payments',
      label: '결제 관리',
      icon: Icons.payment,
      screen: const AdminPaymentsScreen(),
    ),
    AdminNavItem(
      route: '/admin/energy',
      label: '에너지 관리',
      icon: Icons.bolt,
      screen: const AdminEnergyScreen(),
    ),
    AdminNavItem(
      route: '/admin/noshow',
      label: '노쇼 관리',
      icon: Icons.warning,
      screen: const AdminNoshowScreen(),
    ),
    AdminNavItem(
      route: '/admin/checkin',
      label: '체크인 관리',
      icon: Icons.calendar_today,
      screen: const AdminCheckinScreen(),
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
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const RoleSelectScreen()),
                (route) => false,
              );
            },
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );
  }

  void _navigateToRoute(String route) {
    if (widget.currentRoute == route) return;
    final item = _navItems.firstWhere((item) => item.route == route);
    final navigator = Navigator.of(context);
    if (navigator.mounted) {
      navigator.pushReplacement(
        MaterialPageRoute(builder: (context) => item.screen),
      );
    }
  }

  void _onNavItemTap(AdminNavItem item, bool isMobile) {
    final navigator = Navigator.of(context);
    if (isMobile) {
      navigator.pop(); // Drawer 닫기
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (navigator.mounted) {
          navigator.pushReplacement(
            MaterialPageRoute(builder: (context) => item.screen),
          );
        }
      });
    } else {
      _navigateToRoute(item.route);
    }
  }

  Widget _buildSidebar(bool isMobile) {
    final isActive = (String route) {
      if (route == '/admin') {
        return widget.currentRoute == route;
      }
      return widget.currentRoute.startsWith(route);
    };

    return Container(
      width: isMobile ? 280 : 288,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        border: Border(
          right: BorderSide(color: AppTheme.adminPurple100),
        ),
        boxShadow: AppTheme.shadowXl,
      ),
      child: ListView(
        padding: EdgeInsets.all(AppTheme.spacing4),
        children: _navItems.map((item) {
          final active = isActive(item.route);
          return Padding(
            padding: EdgeInsets.only(bottom: AppTheme.spacing2),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _onNavItemTap(item, isMobile),
                borderRadius: BorderRadius.circular(AppTheme.radius2xl),
                child: Container(
                  padding: EdgeInsets.symmetric(
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
                      SizedBox(width: AppTheme.spacing3),
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
      drawer: isMobile ? Drawer(child: _buildSidebar(true)) : null,
      body: Container(
        decoration: AppTheme.adminBackgroundGradient,
        child: SafeArea(
          top: true,
          bottom: false,
          child: Column(
            children: [
              // 헤더
              Container(
                height: isMobile ? 56 : 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  border: Border(
                    bottom: BorderSide(color: AppTheme.adminPurple100, width: 1),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isVeryNarrow ? AppTheme.spacing1 : (isMobile ? AppTheme.spacing2 : AppTheme.spacing3),
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
                          splashColor: AppTheme.primaryPurple500.withOpacity(0.2),
                          highlightColor: AppTheme.primaryPurple500.withOpacity(0.1),
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
                              padding: EdgeInsets.symmetric(
                                horizontal: AppTheme.spacing2,
                                vertical: AppTheme.spacing1,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
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
                                  SizedBox(width: AppTheme.spacing1),
                                  Flexible(
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
                          SizedBox(width: AppTheme.spacing2),
                          Flexible(
                            fit: FlexFit.loose,
                            child: TextButton.icon(
                              onPressed: () => _navigateToRoute('/admin'),
                              icon: const Icon(Icons.dashboard, size: 18, color: AppTheme.textSecondary),
                              label: Text(
                                '대시보드',
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          SizedBox(width: AppTheme.spacing1),
                        ],
                        SizedBox(width: AppTheme.spacing1),
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
                                label: Text(
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
              // 본문
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isMobile) _buildSidebar(false),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(isMobile ? AppTheme.spacing3 : AppTheme.spacing4),
                        child: widget.child,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AdminNavItem {
  final String route;
  final String label;
  final IconData icon;
  final Widget screen;

  AdminNavItem({
    required this.route,
    required this.label,
    required this.icon,
    required this.screen,
  });
}
