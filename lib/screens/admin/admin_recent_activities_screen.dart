import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../services/admin_service.dart';
import '../../theme/admin_stitch_theme.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_handler.dart';
import '../../widgets/admin/admin_stitch_widgets.dart';

/// 대시보드 「최근 활동」 전체 목록
class AdminRecentActivitiesScreen extends StatefulWidget {
  const AdminRecentActivitiesScreen({super.key});

  @override
  State<AdminRecentActivitiesScreen> createState() =>
      _AdminRecentActivitiesScreenState();
}

class _AdminRecentActivitiesScreenState
    extends State<AdminRecentActivitiesScreen> {
  final AdminService _adminService = AdminService();

  List<Map<String, dynamic>> _activities = [];
  bool _isLoading = true;
  bool _hasLoadError = false;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    setState(() {
      _isLoading = true;
      _hasLoadError = false;
    });

    try {
      final result = await _adminService.getRecentActivities(limit: 50);
      if (!mounted) return;
      final raw = result['activities'] as List<dynamic>? ?? [];
      setState(() {
        _activities = raw
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '최근 활동 조회 실패: ${ErrorHandler.getUserFriendlyMessage(appException)}',
          ),
          backgroundColor: AppTheme.urgentRed,
        ),
      );
      setState(() {
        _isLoading = false;
        _hasLoadError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminStitchTheme.bgSubtle,
      appBar: AppBar(
        backgroundColor: AdminStitchTheme.bgSubtle,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.admin),
        ),
        title: Text('최근 활동', style: AdminStitchTheme.sectionHeader),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasLoadError
              ? Center(
                  child: ElevatedButton.icon(
                    onPressed: _loadActivities,
                    icon: const Icon(Icons.refresh),
                    label: const Text('다시 시도'),
                  ),
                )
              : _activities.isEmpty
                  ? Center(
                      child: Text(
                        '최근 활동이 없습니다',
                        style: AdminStitchTheme.bodyMd.copyWith(
                          color: AdminStitchTheme.textSecondary,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(AppTheme.spacing4),
                      itemCount: _activities.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        return AdminStitchCard(
                          child: AdminStitchActivityItem(
                            activity: _activities[index],
                          ),
                        );
                      },
                    ),
    );
  }
}
