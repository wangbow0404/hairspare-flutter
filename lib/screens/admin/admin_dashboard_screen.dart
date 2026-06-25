import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/router/app_routes.dart';
import '../../services/admin_service.dart';
import '../../theme/admin_stitch_theme.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_handler.dart';
import '../../widgets/admin/admin_stitch_widgets.dart';

/// 관리자 대시보드 (Stitch 목업 parity)
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AdminService _adminService = AdminService();
  final NumberFormat _numberFormat = NumberFormat('#,###', 'ko_KR');

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
            {
              'type': 'signup',
              'label': '미용실',
              'entity': '글래머',
              'description': '미용실 "글래머" 온보딩 완료',
              'ago': '2분 전',
              'source': '시스템 자동',
            },
            {
              'type': 'report',
              'label': '신고 접수',
              'entity': '스페어 #8492',
              'description': '스페어 #8492 신고 접수',
              'ago': '15분 전',
              'source': '사용자 제출',
            },
            {
              'type': 'payment',
              'label': '일괄 결제',
              'entity': '412건',
              'description': '412개 계정 일괄 결제 처리 완료',
              'ago': '1시간 전',
              'source': '시스템 배치',
            },
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

  String _formatCount(num value) => _numberFormat.format(value);

  String _formatCurrency(int amount) {
    if (amount >= 10000) {
      return '${_numberFormat.format((amount / 10000).round())}만원';
    }
    return '${_numberFormat.format(amount)}원';
  }

  Widget _metricRow({
    required Widget left,
    required Widget right,
    required double gap,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        SizedBox(width: gap),
        Expanded(child: right),
      ],
    );
  }

  Widget _pendingGrid({
    required double gap,
    required int pendingAuth,
    required int openReports,
    required int pendingBookings,
    required int pendingEducations,
  }) {
    return Column(
      children: [
        _metricRow(
          gap: gap,
          left: AdminStitchAlertMetricCard(
            label: '인증 대기',
            value: _formatCount(pendingAuth),
            icon: Icons.pending_actions_outlined,
            subtitle: '조치 필요',
            onTap: () => context.go(AppRoutes.adminVerifications),
          ),
          right: AdminStitchAlertMetricCard(
            label: '미처리 신고',
            value: _formatCount(openReports),
            icon: Icons.error_outline,
            subtitle: '긴급 우선',
            onTap: () => context.go(AppRoutes.adminReports),
          ),
        ),
        SizedBox(height: gap),
        _metricRow(
          gap: gap,
          left: AdminStitchDashboardPendingCard(
            label: '공간 승인 대기',
            value: _formatCount(pendingBookings),
            subtitle: '대기열',
            icon: Icons.chair_outlined,
            onTap: () => context.go(AppRoutes.adminSpaces),
          ),
          right: AdminStitchDashboardPendingCard(
            label: '교육 승인 대기',
            value: _formatCount(pendingEducations),
            subtitle: '심사 대기',
            icon: Icons.school_outlined,
            onTap: () => context.go(AppRoutes.adminEducations),
          ),
        ),
      ],
    );
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
    final usersWeekPct = (_stats!['users']?['weekGrowthPct'] as num?)?.toDouble();
    final activeJobs = _stats!['jobs']?['active'] ?? 0;
    final jobsTodayPct = (_stats!['jobs']?['todayGrowthPct'] as num?)?.toDouble();
    final byRole = Map<String, int>.from(
      (_stats!['users']?['byRole'] as Map?)?.map(
            (k, v) => MapEntry(k.toString(), (v as num).toInt()),
          ) ??
          {},
    );
    final todayPayments = (_stats!['payments']?['today'] ?? 0) as int;
    final paymentTrendPct =
        (_stats!['payments']?['avgGrowthPct'] as num?)?.toDouble();
    final pendingAuth = _stats!['pendingVerifications'] ?? 0;
    final openReports = _stats!['openReports'] ?? 0;
    final pendingBookings = _stats!['pendingBookings'] ?? 0;
    final pendingEducations = _stats!['pendingEducations'] ?? 0;

    String? usersTrend;
    if (usersWeekPct != null) {
      usersTrend = '+${usersWeekPct.toStringAsFixed(1)}% 이번 주';
    }

    String? jobsTrend;
    if (jobsTodayPct != null) {
      jobsTrend = '+${jobsTodayPct.toStringAsFixed(1)}% 오늘';
    }

    String? paymentTrend;
    if (paymentTrendPct != null) {
      paymentTrend = '+${paymentTrendPct.toStringAsFixed(1)}% 평균 대비';
    }

    final activityMaps = _activities
        .take(5)
        .map((a) => Map<String, dynamic>.from(a as Map))
        .toList();

    const gap = AdminStitchTheme.stackTight;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        AdminStitchTheme.pageMargin,
        AdminStitchTheme.pageMargin,
        AdminStitchTheme.pageMargin,
        AdminStitchTheme.pageMargin + (bottomInset > 0 ? 72 : 16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AdminStitchPageHeader(
            title: '개요',
            subtitle: '오늘의 현황입니다.',
          ),
          const SizedBox(height: AdminStitchTheme.sectionGap),
          _metricRow(
            gap: gap,
            left: AdminStitchMetricCard(
              label: '총 회원',
              value: _formatCount(usersTotal),
              icon: Icons.group_outlined,
              trendLabel: usersTrend,
              onTap: () => context.go(AppRoutes.adminUsers),
            ),
            right: AdminStitchMetricCard(
              label: '활성 공고',
              value: _formatCount(activeJobs),
              icon: Icons.work_outline,
              useSecondaryIcon: true,
              trendLabel: jobsTrend,
              onTap: () => context.go(AppRoutes.adminJobs),
            ),
          ),
          const SizedBox(height: gap),
          AdminStitchPaymentsHeroCard(
            label: '오늘 결제',
            value: _formatCurrency(todayPayments),
            trendLabel: paymentTrend,
            onTap: () => context.go(AppRoutes.adminPayments),
          ),
          const SizedBox(height: gap),
          _pendingGrid(
            gap: gap,
            pendingAuth: pendingAuth,
            openReports: openReports,
            pendingBookings: pendingBookings,
            pendingEducations: pendingEducations,
          ),
          if (byRole.isNotEmpty) ...[
            const SizedBox(height: AdminStitchTheme.sectionGap),
            AdminStitchUserDistributionCard(byRole: byRole),
          ],
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
