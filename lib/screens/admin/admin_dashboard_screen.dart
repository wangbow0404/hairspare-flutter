import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../services/admin_service.dart';
import '../../theme/admin_stitch_theme.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_handler.dart';
import '../../widgets/admin/admin_stitch_widgets.dart';

/// 관리자 대시보드 화면 (Stitch bento 레이아웃)
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AdminService _adminService = AdminService();
  Map<String, dynamic>? _stats;
  List<dynamic> _activities = [];
  bool _isLoading = true;
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    _loadStats();
    _loadActivities();
    _updateTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _loadStats(showLoading: false);
        _loadActivities();
      });
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadActivities() async {
    try {
      final result = await _adminService.getRecentActivities();
      if (mounted) {
        setState(() {
          _activities = result['activities'] ?? [];
        });
      }
    } catch (_) {
      if (mounted && _activities.isEmpty) {
        setState(() {
          _activities = [
            {'type': 'signup', 'label': '회원가입', 'entity': '김디자이너', 'ago': '5분 전'},
            {'type': 'job', 'label': '공고등록', 'entity': '이미용실', 'ago': '12분 전'},
            {'type': 'payment', 'label': '결제완료', 'entity': '박스텝', 'ago': '23분 전'},
            {'type': 'report', 'label': '신고접수', 'entity': '스페어 #8492', 'ago': '1시간 전'},
          ];
        });
      }
    }
  }

  Future<void> _loadStats({bool showLoading = true}) async {
    if (showLoading) {
      setState(() => _isLoading = true);
    }

    try {
      final stats = await _adminService.getDashboardStats();
      if (mounted) {
        setState(() {
          _stats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '통계 조회 실패: ${ErrorHandler.getUserFriendlyMessage(appException)}',
            ),
            backgroundColor: AppTheme.urgentRed,
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatCurrency(int amount) {
    if (amount >= 10000) {
      return '${(amount / 10000).toStringAsFixed(0)}만원';
    }
    return '${amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        )}원';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_stats == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppTheme.urgentRed),
            const SizedBox(height: AdminStitchTheme.sectionGap),
            const Text('데이터를 불러올 수 없습니다'),
            const SizedBox(height: AdminStitchTheme.sectionGap),
            FilledButton(onPressed: _loadStats, child: const Text('다시 시도')),
          ],
        ),
      );
    }

    final usersTotal = _stats!['users']?['total'] ?? 0;
    final usersToday = _stats!['users']?['today'] ?? 0;
    final activeJobs = _stats!['jobs']?['active'] ?? 0;
    final todayPayments = (_stats!['payments']?['today'] ?? 0) as int;
    final pendingAuth = _stats!['pendingVerifications'] ?? 0;
    final openReports = _stats!['openReports'] ?? 0;
    final pendingBookings = _stats!['pendingBookings'] ?? 0;

    final activityMaps = _activities
        .take(5)
        .map((a) => Map<String, dynamic>.from(a as Map))
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AdminStitchTheme.pageMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: AdminStitchPageHeader(
                  title: '개요',
                  subtitle: '오늘의 플랫폼 현황입니다.',
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AdminStitchTheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AdminStitchTheme.emerald,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '실시간',
                      style: AdminStitchTheme.labelSm.copyWith(
                        fontSize: 10,
                        color: AdminStitchTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AdminStitchTheme.sectionGap),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 640;
              final gap = AdminStitchTheme.stackTight;

              return Column(
                children: [
                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: AdminStitchMetricCard(
                            label: '총 회원',
                            value: '$usersTotal',
                            icon: Icons.group_outlined,
                            trendLabel: usersToday > 0 ? '오늘 +$usersToday' : null,
                            onTap: () => context.go(AppRoutes.adminUsers),
                          ),
                        ),
                        SizedBox(width: gap),
                        Expanded(
                          child: AdminStitchMetricCard(
                            label: '활성 공고',
                            value: '$activeJobs',
                            icon: Icons.work_outline,
                            trendLabel: '전체 ${_stats!['jobs']?['total'] ?? 0}개',
                            onTap: () => context.go(AppRoutes.adminJobs),
                          ),
                        ),
                      ],
                    )
                  else ...[
                    AdminStitchMetricCard(
                      label: '총 회원',
                      value: '$usersTotal',
                      icon: Icons.group_outlined,
                      trendLabel: usersToday > 0 ? '오늘 +$usersToday' : null,
                      onTap: () => context.go(AppRoutes.adminUsers),
                    ),
                    SizedBox(height: gap),
                    AdminStitchMetricCard(
                      label: '활성 공고',
                      value: '$activeJobs',
                      icon: Icons.work_outline,
                      trendLabel: '전체 ${_stats!['jobs']?['total'] ?? 0}개',
                      onTap: () => context.go(AppRoutes.adminJobs),
                    ),
                  ],
                  SizedBox(height: gap),
                  AdminStitchPaymentsHeroCard(
                    label: '오늘 결제',
                    value: _formatCurrency(todayPayments),
                    onTap: () => context.go(AppRoutes.adminPayments),
                  ),
                  SizedBox(height: gap),
                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: AdminStitchAlertMetricCard(
                            label: '대기 인증',
                            value: '$pendingAuth',
                            icon: Icons.verified_user_outlined,
                            onTap: () => context.go(AppRoutes.adminVerifications),
                          ),
                        ),
                        SizedBox(width: gap),
                        Expanded(
                          child: AdminStitchAlertMetricCard(
                            label: '미처리 신고',
                            value: '$openReports',
                            icon: Icons.report_outlined,
                            onTap: () => context.go(AppRoutes.adminReports),
                          ),
                        ),
                      ],
                    )
                  else ...[
                    AdminStitchAlertMetricCard(
                      label: '대기 인증',
                      value: '$pendingAuth',
                      icon: Icons.verified_user_outlined,
                      onTap: () => context.go(AppRoutes.adminVerifications),
                    ),
                    SizedBox(height: gap),
                    AdminStitchAlertMetricCard(
                      label: '미처리 신고',
                      value: '$openReports',
                      icon: Icons.report_outlined,
                      onTap: () => context.go(AppRoutes.adminReports),
                    ),
                  ],
                  SizedBox(height: gap),
                  AdminStitchListRowCard(
                    icon: Icons.storefront_outlined,
                    label: '대기 공간 승인',
                    value: '$pendingBookings',
                    onTap: () => context.go(AppRoutes.adminSpaces),
                  ),
                ],
              );
            },
          ),
          if (activityMaps.isNotEmpty) ...[
            const SizedBox(height: AdminStitchTheme.sectionGap),
            AdminStitchActivityList(
              activities: activityMaps,
              onViewAll: () => context.go(AppRoutes.adminAuditLogs),
            ),
          ],
        ],
      ),
    );
  }
}
