import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../services/admin_service.dart';
import '../../theme/admin_stitch_theme.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_handler.dart';
import '../../widgets/admin/admin_action_dialog.dart';

/// 관리자 지원 상세 화면 — 스페어/미용실/공고를 각각 눌러서 해당
/// 상세 화면으로 이동할 수 있다.
class AdminApplicationDetailScreen extends StatefulWidget {
  final String applicationId;
  final Map<String, dynamic>? initialData;

  const AdminApplicationDetailScreen({
    super.key,
    required this.applicationId,
    this.initialData,
  });

  @override
  State<AdminApplicationDetailScreen> createState() =>
      _AdminApplicationDetailScreenState();
}

class _AdminApplicationDetailScreenState
    extends State<AdminApplicationDetailScreen> {
  final AdminService _adminService = AdminService();
  Map<String, dynamic>? _app;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _app = widget.initialData;
      _isLoading = false;
    }
    _loadApplication();
  }

  Future<void> _loadApplication() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await _adminService.getApplicationDetail(
        widget.applicationId,
      );
      if (mounted) {
        setState(() {
          _app = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = ErrorHandler.getUserFriendlyMessage(
            ErrorHandler.handleException(e),
          );
          _isLoading = false;
          if (_app == null && widget.initialData != null) {
            _app = widget.initialData;
          }
        });
      }
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '-';
    try {
      return DateFormat(
        'yyyy년 M월 d일 HH:mm',
        'ko_KR',
      ).format(DateTime.parse(dateString).toLocal());
    } catch (_) {
      return dateString;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return AdminStitchTheme.emerald;
      case 'pending':
        return AppTheme.orange600;
      case 'rejected':
        return AdminStitchTheme.statusError;
      case 'cancelled_contact_violation':
        return AdminStitchTheme.textSecondary;
      default:
        return AdminStitchTheme.textSecondary;
    }
  }

  Future<void> _cancelApplication() async {
    final app = _app;
    if (app == null) return;
    final spareName = app['spare']?['name']?.toString() ?? '-';
    final jobTitle = app['job']?['title']?.toString() ?? '-';
    final reason = await AdminActionDialog.show(
      context,
      title: '지원 강제 취소',
      confirmLabel: '취소 처리',
      summary: '$spareName · $jobTitle',
      isDanger: true,
    );
    if (reason == null || !mounted) return;
    try {
      await _adminService.cancelApplication(
        widget.applicationId,
        reason: reason,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('지원이 강제 취소 처리되었습니다')));
      _loadApplication();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '강제 취소 실패: ${ErrorHandler.getUserFriendlyMessage(ErrorHandler.handleException(e))}',
          ),
          backgroundColor: AppTheme.urgentRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AdminStitchTheme.bgSubtle,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AdminStitchTheme.pageMargin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.pop(),
                  color: AdminStitchTheme.onSurface,
                ),
                const SizedBox(width: AdminStitchTheme.stackTight),
                const Text('지원 상세', style: AdminStitchTheme.headlineMd),
              ],
            ),
            const SizedBox(height: AdminStitchTheme.sectionGap),
            if (_isLoading && _app == null)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppTheme.spacing8),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_error != null && _app == null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacing8),
                  child: Column(
                    children: [
                      Text(
                        _error!,
                        style: const TextStyle(color: AppTheme.urgentRed),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppTheme.spacing4),
                      TextButton(
                        onPressed: _loadApplication,
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                ),
              )
            else if (_app != null)
              _buildContent()
            else
              const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final app = _app!;
    final status = app['status']?.toString() ?? '';
    final statusLabel = app['statusLabel']?.toString() ?? status;
    final statusColor = _statusColor(status);
    final spareId = app['spare']?['id']?.toString();
    final spareName = app['spare']?['name']?.toString() ?? '-';
    final spareEmail = app['spare']?['email']?.toString() ?? '';
    final shopId = app['shop']?['id']?.toString();
    final shopName = app['shop']?['name']?.toString() ?? '-';
    final jobId = app['job']?['id']?.toString();
    final jobTitle = app['job']?['title']?.toString() ?? '-';
    final amount = app['job']?['amount'];
    final amountStr = amount != null
        ? '${NumberFormat('#,###', 'ko_KR').format(amount)}원'
        : '-';
    final startTime = app['job']?['startTime']?.toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AdminStitchTheme.componentPadding),
          decoration: AdminStitchTheme.cardDecoration,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '지원 일시 ${_formatDate(app['createdAt']?.toString())}',
                  style: AdminStitchTheme.bodyMd.copyWith(
                    color: AdminStitchTheme.textSecondary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(
                    AdminStitchTheme.radius2xl,
                  ),
                ),
                child: Text(
                  statusLabel,
                  style: AdminStitchTheme.labelSm.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AdminStitchTheme.sectionGap),
        _NavCard(
          icon: Icons.person_outline,
          label: '스페어',
          title: spareName,
          subtitle: spareEmail.isNotEmpty ? spareEmail : null,
          onTap: spareId != null
              ? () => context.push(AppRoutes.adminUserDetail(spareId))
              : null,
        ),
        const SizedBox(height: AdminStitchTheme.stackTight),
        _NavCard(
          icon: Icons.store_outlined,
          label: '미용실',
          title: shopName,
          onTap: shopId != null
              ? () => context.push(AppRoutes.adminUserDetail(shopId))
              : null,
        ),
        const SizedBox(height: AdminStitchTheme.stackTight),
        _NavCard(
          icon: Icons.work_outline,
          label: '공고',
          title: jobTitle,
          subtitle: '$amountStr · ${_formatDate(startTime)}',
          onTap: jobId != null
              ? () => context.push(AppRoutes.adminJobDetail(jobId))
              : null,
        ),
        if (status == 'pending') ...[
          const SizedBox(height: AdminStitchTheme.sectionGap),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _cancelApplication,
              style: OutlinedButton.styleFrom(
                foregroundColor: AdminStitchTheme.statusError,
                side: const BorderSide(color: AdminStitchTheme.statusError),
                minimumSize: const Size.fromHeight(
                  AdminStitchTheme.buttonHeight,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AdminStitchTheme.radiusXl,
                  ),
                ),
              ),
              child: const Text('강제 취소'),
            ),
          ),
        ],
      ],
    );
  }
}

/// 다른 상세 화면으로 이동하는 탭 가능한 카드. onTap이 없으면(대상 id 없음)
/// 화살표 없이 비활성 상태로 보인다.
class _NavCard extends StatelessWidget {
  const _NavCard({
    required this.icon,
    required this.label,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AdminStitchTheme.surfaceCard,
      borderRadius: BorderRadius.circular(AdminStitchTheme.radius2xl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AdminStitchTheme.radius2xl),
        child: Container(
          padding: const EdgeInsets.all(AdminStitchTheme.componentPadding),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AdminStitchTheme.radius2xl),
            border: Border.all(color: AdminStitchTheme.borderDefault),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AdminStitchTheme.primaryFixed,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 20, color: AdminStitchTheme.primary),
              ),
              const SizedBox(width: AdminStitchTheme.stackTight),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AdminStitchTheme.bodyMd.copyWith(
                        color: AdminStitchTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AdminStitchTheme.bodyMd.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AdminStitchTheme.bodyMd.copyWith(
                          color: AdminStitchTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (onTap != null)
                const Icon(
                  Icons.chevron_right,
                  color: AdminStitchTheme.textSecondary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
