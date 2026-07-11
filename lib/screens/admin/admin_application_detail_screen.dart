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

  String _wageTypeLabel(String? wageType) {
    switch (wageType) {
      case 'hourly':
        return '시급';
      case 'daily':
        return '일급';
      default:
        return '';
    }
  }

  String _wageUnitSuffix(String? wageType) {
    switch (wageType) {
      case 'hourly':
        return '/ 시간';
      case 'daily':
        return '/ 일';
      default:
        return '';
    }
  }

  String _scheduleStatusLabel(String? status) {
    switch (status) {
      case 'scheduled':
        return '예정';
      case 'completed':
        return '완료';
      case 'cancelled':
        return '취소됨';
      default:
        return status ?? '-';
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
    final shopEmail = app['shop']?['email']?.toString() ?? '';
    final jobId = app['job']?['id']?.toString();
    final jobTitle = app['job']?['title']?.toString() ?? '-';
    final wageType = app['job']?['wageType']?.toString();
    final amount = app['job']?['amount'];
    final amountStr = amount != null
        ? '${NumberFormat('#,###', 'ko_KR').format(amount)}원'
        : '-';
    final startTime = app['job']?['startTime']?.toString();
    final schedule = app['schedule'] as Map<String, dynamic>?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StatusHero(
          statusLabel: statusLabel,
          statusColor: statusColor,
          createdAtLabel: _formatDate(app['createdAt']?.toString()),
        ),
        const SizedBox(height: AdminStitchTheme.sectionGap),
        const _SectionLabel('매칭 정보'),
        const SizedBox(height: AdminStitchTheme.stackTight),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _NavCard(
                  icon: Icons.person_outline,
                  label: '스페어',
                  title: spareName,
                  subtitle: spareEmail.isNotEmpty ? spareEmail : null,
                  onTap: spareId != null
                      ? () => context.push(AppRoutes.adminUserDetail(spareId))
                      : null,
                ),
              ),
              const SizedBox(width: AdminStitchTheme.stackTight),
              Expanded(
                child: _NavCard(
                  icon: Icons.store_outlined,
                  label: '미용실',
                  title: shopName,
                  subtitle: shopEmail.isNotEmpty ? shopEmail : null,
                  onTap: shopId != null
                      ? () => context.push(AppRoutes.adminUserDetail(shopId))
                      : null,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AdminStitchTheme.sectionGap),
        const _SectionLabel('공고 정보'),
        const SizedBox(height: AdminStitchTheme.stackTight),
        _JobCard(
          title: jobTitle,
          wageTypeLabel: _wageTypeLabel(wageType),
          amountStr: amountStr,
          unitSuffix: _wageUnitSuffix(wageType),
          scheduleLabel: _formatDate(startTime),
          onTap: jobId != null
              ? () => context.push(AppRoutes.adminJobDetail(jobId))
              : null,
        ),
        if (schedule != null) ...[
          const SizedBox(height: AdminStitchTheme.sectionGap),
          const _SectionLabel('근무 스케줄'),
          const SizedBox(height: AdminStitchTheme.stackTight),
          _ScheduleCard(
            dateTime:
                '${schedule['date'] ?? ''} ${schedule['startTime'] ?? ''}'
                '${schedule['endTime'] != null ? '~${schedule['endTime']}' : ''}',
            statusLabel: _scheduleStatusLabel(schedule['status']?.toString()),
            checkedIn: schedule['checkInTime'] != null,
          ),
        ],
        if (status == 'pending') ...[
          const SizedBox(height: AdminStitchTheme.sectionGap),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _cancelApplication,
              icon: const Icon(Icons.cancel_outlined, size: 20),
              label: const Text('강제 취소'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AdminStitchTheme.statusError,
                side: BorderSide(
                  color: AdminStitchTheme.statusError.withValues(alpha: 0.4),
                  width: 2,
                ),
                minimumSize: const Size.fromHeight(
                  AdminStitchTheme.buttonHeight,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AdminStitchTheme.radiusXl,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// 상태를 크게 강조하는 히어로 카드 — 상태색으로 옅게 틴트된 배경 +
/// 점(dot) 배지 + 지원 일시.
class _StatusHero extends StatelessWidget {
  const _StatusHero({
    required this.statusLabel,
    required this.statusColor,
    required this.createdAtLabel,
  });

  final String statusLabel;
  final Color statusColor;
  final String createdAtLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AdminStitchTheme.radius2xl),
        border: Border.all(color: statusColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  statusLabel,
                  style: AdminStitchTheme.labelSm.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AdminStitchTheme.stackTight),
          Text(
            '지원 일시 $createdAtLabel',
            style: AdminStitchTheme.bodyMd.copyWith(
              color: AdminStitchTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(text, style: AdminStitchTheme.sectionHeader),
    );
  }
}

/// 공고 태그 + 제목 + 금액 강조 박스. 탭하면 공고 상세로 이동.
class _JobCard extends StatelessWidget {
  const _JobCard({
    required this.title,
    required this.wageTypeLabel,
    required this.amountStr,
    required this.unitSuffix,
    required this.scheduleLabel,
    this.onTap,
  });

  final String title;
  final String wageTypeLabel;
  final String amountStr;
  final String unitSuffix;
  final String scheduleLabel;
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
          width: double.infinity,
          padding: const EdgeInsets.all(AdminStitchTheme.componentPadding),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AdminStitchTheme.radius2xl),
            border: Border.all(color: AdminStitchTheme.borderDefault),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AdminStitchTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AdminStitchTheme.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      '공고',
                      style: AdminStitchTheme.labelSm.copyWith(
                        color: AdminStitchTheme.primary,
                      ),
                    ),
                  ),
                  if (wageTypeLabel.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AdminStitchTheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        wageTypeLabel,
                        style: AdminStitchTheme.labelSm.copyWith(
                          color: AdminStitchTheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (onTap != null)
                    const Icon(
                      Icons.chevron_right,
                      color: AdminStitchTheme.textSecondary,
                    ),
                ],
              ),
              const SizedBox(height: AdminStitchTheme.stackTight),
              Text(
                title,
                style: AdminStitchTheme.headlineMd.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 4),
              Text(
                scheduleLabel,
                style: AdminStitchTheme.bodyMd.copyWith(
                  color: AdminStitchTheme.textSecondary,
                ),
              ),
              const SizedBox(height: AdminStitchTheme.stackTight),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AdminStitchTheme.bgSubtle,
                  borderRadius: BorderRadius.circular(
                    AdminStitchTheme.radiusXl,
                  ),
                  border: Border.all(color: AdminStitchTheme.borderDefault),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      amountStr,
                      style: AdminStitchTheme.headlineMd.copyWith(
                        color: AdminStitchTheme.primary,
                        fontSize: 22,
                      ),
                    ),
                    if (unitSuffix.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Text(
                        unitSuffix,
                        style: AdminStitchTheme.bodyMd.copyWith(
                          color: AdminStitchTheme.textSecondary,
                        ),
                      ),
                    ],
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

/// 확정된 근무 스케줄 요약 카드(승인된 지원일 때만 노출).
class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({
    required this.dateTime,
    required this.statusLabel,
    required this.checkedIn,
  });

  final String dateTime;
  final String statusLabel;
  final bool checkedIn;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AdminStitchTheme.componentPadding),
      decoration: BoxDecoration(
        color: AdminStitchTheme.surfaceCard,
        borderRadius: BorderRadius.circular(AdminStitchTheme.radius2xl),
        border: Border.all(color: AdminStitchTheme.borderDefault),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: checkedIn
                  ? AdminStitchTheme.emerald.withValues(alpha: 0.12)
                  : AdminStitchTheme.primaryFixed,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              checkedIn ? Icons.check_circle_outline : Icons.schedule,
              size: 20,
              color: checkedIn
                  ? AdminStitchTheme.emerald
                  : AdminStitchTheme.primary,
            ),
          ),
          const SizedBox(width: AdminStitchTheme.stackTight),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateTime,
                  style: AdminStitchTheme.bodyMd.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  checkedIn ? '체크인 완료' : '체크인 전',
                  style: AdminStitchTheme.bodyMd.copyWith(
                    color: AdminStitchTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AdminStitchTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              statusLabel,
              style: AdminStitchTheme.labelSm.copyWith(
                color: AdminStitchTheme.primary,
              ),
            ),
          ),
        ],
      ),
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
