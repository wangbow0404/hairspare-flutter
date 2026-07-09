import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../../services/admin_service.dart';
import '../../theme/admin_stitch_theme.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_handler.dart';
import '../../utils/region_helper.dart';
import '../../widgets/admin/admin_action_dialog.dart';
import '../../widgets/common/app_network_image.dart';

/// 관리자 공고 상세 화면 — 사진·설명·지원자/스케줄 실제 목록 포함.
class AdminJobDetailScreen extends StatefulWidget {
  final String jobId;
  final Map<String, dynamic>? initialData;

  const AdminJobDetailScreen({
    super.key,
    required this.jobId,
    this.initialData,
  });

  @override
  State<AdminJobDetailScreen> createState() => _AdminJobDetailScreenState();
}

class _AdminJobDetailScreenState extends State<AdminJobDetailScreen> {
  final AdminService _adminService = AdminService();
  Map<String, dynamic>? _job;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _job = widget.initialData;
      _isLoading = false;
    }
    _loadJob();
  }

  Future<void> _loadJob() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _adminService.getJobDetail(widget.jobId);
      if (mounted) {
        setState(() {
          _job = data as Map<String, dynamic>?;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        final appException = ErrorHandler.handleException(e);
        setState(() {
          _error = ErrorHandler.getUserFriendlyMessage(appException);
          _isLoading = false;
          if (_job == null && widget.initialData != null) {
            _job = widget.initialData;
          }
        });
      }
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('yyyy년 M월 d일 HH:mm', 'ko_KR').format(date);
    } catch (e) {
      return dateString;
    }
  }

  String _formatCurrency(int amount) {
    return NumberFormat.currency(locale: 'ko_KR', symbol: '₩').format(amount);
  }

  String _regionName(Map<String, dynamic> job) {
    final regionId =
        job['region']?['id']?.toString() ??
        job['region']?['name']?.toString() ??
        '';
    return regionId.isEmpty ? '-' : RegionHelper.getRegionName(regionId);
  }

  String _getStatusLabel(String? status) {
    switch (status) {
      case 'published':
        return '게시중';
      case 'closed':
        return '마감';
      case 'completed':
        return '완료';
      case 'hidden':
        return '숨김';
      default:
        return status ?? '-';
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

  String _roleLabel(String? role) {
    switch (role) {
      case 'designer':
        return '디자이너';
      case 'step':
        return '보조';
      default:
        return '';
    }
  }

  String _applicationStatusLabel(String? status) {
    switch (status) {
      case 'pending':
        return '대기중';
      case 'approved':
        return '승인됨';
      case 'rejected':
        return '거절됨';
      default:
        return status ?? '-';
    }
  }

  Color _applicationStatusColor(String? status) {
    switch (status) {
      case 'approved':
        return AdminStitchTheme.emerald;
      case 'rejected':
        return AdminStitchTheme.statusError;
      default:
        return AdminStitchTheme.onSurfaceVariant;
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

  Color _scheduleStatusColor(String? status) {
    switch (status) {
      case 'completed':
        return AdminStitchTheme.emerald;
      case 'cancelled':
        return AdminStitchTheme.statusError;
      default:
        return AdminStitchTheme.primary;
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
                const Text('공고 상세', style: AdminStitchTheme.headlineMd),
              ],
            ),
            const SizedBox(height: AdminStitchTheme.sectionGap),
            if (_isLoading && _job == null)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppTheme.spacing8),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_error != null && _job == null)
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
                        onPressed: _loadJob,
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                ),
              )
            else if (_job != null)
              _buildContent()
            else
              const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final job = _job!;
    final imageUrls = (job['imageUrls'] as List?) ?? [];
    final applicants = (job['applicants'] as List?) ?? [];
    final schedules = (job['schedules'] as List?) ?? [];
    final description = job['description']?.toString() ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HeroSection(
          imageUrl: imageUrls.isNotEmpty ? imageUrls.first.toString() : null,
          statusLabel: _getStatusLabel(job['status']),
          isUrgent: job['isUrgent'] == true,
          isOpeningSoon: job['isOpeningSoon'] == true,
        ),
        const SizedBox(height: AdminStitchTheme.sectionGap),
        _MainInfoCard(
          title: job['title'] ?? '제목 없음',
          rows: [
            ('일시', '${_formatDate(job['date'])} ${job['time'] ?? ''}'),
            ('미용실', job['shop']?['name']?.toString() ?? '-'),
            ('지역', _regionName(job)),
            (
              '모집',
              '${job['requiredCount'] ?? 1}명'
                  '${_roleLabel(job['role']).isNotEmpty ? ' · ${_roleLabel(job['role'])}' : ''}',
            ),
          ],
          amountLabel:
              '${_formatCurrency((job['amount'] ?? 0) as int)}'
              '${_wageTypeLabel(job['wageType']).isNotEmpty ? ' (${_wageTypeLabel(job['wageType'])})' : ''}',
        ),
        if (description.isNotEmpty) ...[
          const SizedBox(height: AdminStitchTheme.sectionGap),
          const _SectionLabel('공고 설명'),
          const SizedBox(height: AdminStitchTheme.stackTight),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AdminStitchTheme.componentPadding),
            decoration: AdminStitchTheme.cardDecoration,
            child: Text(
              description,
              style: AdminStitchTheme.bodyMd.copyWith(
                color: AdminStitchTheme.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
        const SizedBox(height: AdminStitchTheme.sectionGap),
        _SectionLabel('지원자 (${applicants.length})'),
        const SizedBox(height: AdminStitchTheme.stackTight),
        if (applicants.isEmpty)
          const _EmptyListCard(
            icon: Icons.person_search_outlined,
            message: '아직 지원자가 없습니다',
          )
        else
          Column(
            children: [
              for (var i = 0; i < applicants.length; i++) ...[
                if (i > 0) const SizedBox(height: AdminStitchTheme.stackTight),
                _ApplicantTile(
                  name: applicants[i]['spareName']?.toString() ?? '스페어',
                  createdAt: _formatDate(
                    applicants[i]['createdAt']?.toString(),
                  ),
                  statusLabel: _applicationStatusLabel(
                    applicants[i]['status']?.toString(),
                  ),
                  statusColor: _applicationStatusColor(
                    applicants[i]['status']?.toString(),
                  ),
                ),
              ],
            ],
          ),
        const SizedBox(height: AdminStitchTheme.sectionGap),
        _SectionLabel('근무 스케줄 (${schedules.length})'),
        const SizedBox(height: AdminStitchTheme.stackTight),
        if (schedules.isEmpty)
          const _EmptyListCard(
            icon: Icons.event_busy_outlined,
            message: '확정된 스케줄이 없습니다',
          )
        else
          Column(
            children: [
              for (var i = 0; i < schedules.length; i++) ...[
                if (i > 0) const SizedBox(height: AdminStitchTheme.stackTight),
                _ScheduleTile(
                  name: schedules[i]['spareName']?.toString() ?? '스페어',
                  dateTime:
                      '${schedules[i]['date'] ?? ''} ${schedules[i]['startTime'] ?? ''}'
                      '${schedules[i]['endTime'] != null ? '~${schedules[i]['endTime']}' : ''}',
                  statusLabel: _scheduleStatusLabel(
                    schedules[i]['status']?.toString(),
                  ),
                  statusColor: _scheduleStatusColor(
                    schedules[i]['status']?.toString(),
                  ),
                  checkedIn: schedules[i]['checkInTime'] != null,
                ),
              ],
            ],
          ),
        const SizedBox(height: AdminStitchTheme.sectionGap),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _hideJob(job['status'] != 'hidden'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(
                    AdminStitchTheme.buttonHeight,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AdminStitchTheme.radiusXl,
                    ),
                  ),
                ),
                child: Text(job['status'] == 'hidden' ? '숨김 해제' : '숨김'),
              ),
            ),
            const SizedBox(width: AdminStitchTheme.stackTight),
            Expanded(
              child: OutlinedButton(
                onPressed: _forceClose,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AdminStitchTheme.primary,
                  side: const BorderSide(color: AdminStitchTheme.primary),
                  minimumSize: const Size.fromHeight(
                    AdminStitchTheme.buttonHeight,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AdminStitchTheme.radiusXl,
                    ),
                  ),
                ),
                child: const Text('강제 마감'),
              ),
            ),
            const SizedBox(width: AdminStitchTheme.stackTight),
            Expanded(
              child: FilledButton(
                onPressed: _deleteJob,
                style: FilledButton.styleFrom(
                  backgroundColor: AdminStitchTheme.statusError,
                  minimumSize: const Size.fromHeight(
                    AdminStitchTheme.buttonHeight,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AdminStitchTheme.radiusXl,
                    ),
                  ),
                ),
                child: const Text('삭제'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _hideJob(bool hide) async {
    final reason = await AdminActionDialog.show(
      context,
      title: '공고 숨김',
      confirmLabel: '적용',
      summary: _job?['title']?.toString(),
      isDanger: true,
    );
    if (reason == null || !mounted) return;
    await _adminService.hideJob(widget.jobId, reason: reason, hide: hide);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('공고가 숨김 처리되었습니다')));
    _loadJob();
  }

  Future<void> _forceClose() async {
    final reason = await AdminActionDialog.show(
      context,
      title: '공고 강제 마감',
      confirmLabel: '마감',
      summary: _job?['title']?.toString(),
      isDanger: true,
    );
    if (reason == null || !mounted) return;
    await _adminService.forceCloseJob(widget.jobId, reason: reason);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('공고가 마감되었습니다')));
    _loadJob();
  }

  Future<void> _deleteJob() async {
    final reason = await AdminActionDialog.show(
      context,
      title: '공고 삭제',
      confirmLabel: '삭제',
      summary: _job?['title']?.toString(),
      isDanger: true,
    );
    if (reason == null || !mounted) return;
    await _adminService.deleteJob(widget.jobId, reason: reason);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('공고가 삭제되었습니다')));
    context.pop();
  }
}

/// 사진 히어로 + 상태/급구/하이패스 배지.
class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.imageUrl,
    required this.statusLabel,
    required this.isUrgent,
    required this.isOpeningSoon,
  });

  final String? imageUrl;
  final String statusLabel;
  final bool isUrgent;
  final bool isOpeningSoon;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AdminStitchTheme.radiusXl),
      child: SizedBox(
        height: 224,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(
              color: AdminStitchTheme.surfaceDim,
              child: AppNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                fallbackIcon: Icons.image_outlined,
              ),
            ),
            Positioned(
              top: AdminStitchTheme.stackTight + 8,
              left: AdminStitchTheme.stackTight + 8,
              child: Row(
                children: [
                  _Badge(
                    label: statusLabel,
                    background: Colors.white.withValues(alpha: 0.9),
                    foreground: AdminStitchTheme.primary,
                    border: AdminStitchTheme.primaryFixed,
                  ),
                  if (isUrgent) ...[
                    const SizedBox(width: AdminStitchTheme.stackTight),
                    const _Badge(
                      label: '급구',
                      background: AdminStitchTheme.statusError,
                      foreground: Colors.white,
                    ),
                  ],
                  if (isOpeningSoon) ...[
                    const SizedBox(width: AdminStitchTheme.stackTight),
                    const _Badge(
                      label: '하이패스',
                      background: Color(0xFFD4AF37),
                      foreground: Colors.white,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.background,
    required this.foreground,
    this.border,
  });

  final String label;
  final Color background;
  final Color foreground;
  final Color? border;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AdminStitchTheme.radius2xl),
        border: border != null ? Border.all(color: border!) : null,
        boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 4)],
      ),
      child: Text(
        label,
        style: AdminStitchTheme.labelSm.copyWith(color: foreground),
      ),
    );
  }
}

/// 제목 + 일시·미용실·지역·모집 + 금액 강조 카드.
class _MainInfoCard extends StatelessWidget {
  const _MainInfoCard({
    required this.title,
    required this.rows,
    required this.amountLabel,
  });

  final String title;
  final List<(String, String)> rows;
  final String amountLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AdminStitchTheme.componentPadding),
      decoration: AdminStitchTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AdminStitchTheme.headlineMd),
          const SizedBox(height: AdminStitchTheme.sectionGap),
          for (final row in rows) _InfoRow(label: row.$1, value: row.$2),
          _InfoRow(
            label: '금액',
            value: amountLabel,
            valueStyle: AdminStitchTheme.bodyLg.copyWith(
              color: AdminStitchTheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.valueStyle});

  final String label;
  final String value;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AdminStitchTheme.stackTight),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 64,
            child: Text(
              label,
              style: AdminStitchTheme.bodyMd.copyWith(
                color: AdminStitchTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style:
                  valueStyle ??
                  AdminStitchTheme.bodyMd.copyWith(
                    color: AdminStitchTheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
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

class _EmptyListCard extends StatelessWidget {
  const _EmptyListCard({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacing8),
      decoration: BoxDecoration(
        color: AdminStitchTheme.surface,
        borderRadius: BorderRadius.circular(AdminStitchTheme.radiusXl),
        border: Border.all(color: AdminStitchTheme.borderDefault, width: 1.5),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: AdminStitchTheme.surfaceVariant),
          const SizedBox(height: AdminStitchTheme.stackTight),
          Text(
            message,
            style: AdminStitchTheme.bodyMd.copyWith(
              color: AdminStitchTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ApplicantTile extends StatelessWidget {
  const _ApplicantTile({
    required this.name,
    required this.createdAt,
    required this.statusLabel,
    required this.statusColor,
  });

  final String name;
  final String createdAt;
  final String statusLabel;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AdminStitchTheme.componentPadding),
      decoration: AdminStitchTheme.cardDecoration,
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AdminStitchTheme.primaryFixed,
            child: Text(
              name.isNotEmpty ? name.characters.first : '?',
              style: const TextStyle(
                color: AdminStitchTheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: AdminStitchTheme.componentPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AdminStitchTheme.bodyLg.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AdminStitchTheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  createdAt,
                  style: AdminStitchTheme.labelSm.copyWith(
                    color: AdminStitchTheme.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          _Badge(
            label: statusLabel,
            background: statusColor.withValues(alpha: 0.12),
            foreground: statusColor,
          ),
        ],
      ),
    );
  }
}

class _ScheduleTile extends StatelessWidget {
  const _ScheduleTile({
    required this.name,
    required this.dateTime,
    required this.statusLabel,
    required this.statusColor,
    required this.checkedIn,
  });

  final String name;
  final String dateTime;
  final String statusLabel;
  final Color statusColor;
  final bool checkedIn;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AdminStitchTheme.componentPadding),
      decoration: AdminStitchTheme.cardDecoration,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AdminStitchTheme.surfaceContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              checkedIn ? Icons.check_circle_outline : Icons.schedule,
              size: 20,
              color: AdminStitchTheme.primary,
            ),
          ),
          const SizedBox(width: AdminStitchTheme.componentPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AdminStitchTheme.bodyLg.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AdminStitchTheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dateTime,
                  style: AdminStitchTheme.labelSm.copyWith(
                    color: AdminStitchTheme.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          _Badge(
            label: statusLabel,
            background: statusColor.withValues(alpha: 0.12),
            foreground: statusColor,
          ),
        ],
      ),
    );
  }
}
