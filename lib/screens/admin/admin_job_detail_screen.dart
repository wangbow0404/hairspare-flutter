import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/admin_stitch_theme.dart';
import '../../theme/app_theme.dart';
import '../../services/admin_service.dart';
import '../../utils/error_handler.dart';
import '../../utils/region_helper.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/admin/admin_table_card.dart';
import '../../widgets/admin/admin_action_dialog.dart';

/// 관리자 공고 상세 화면
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
    final regionId = job['region']?['id']?.toString() ??
        job['region']?['name']?.toString() ?? '';
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

  Color _getStatusBadgeColor(String? status) {
    switch (status) {
      case 'published':
        return Colors.green;
      case 'closed':
        return Colors.grey;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AdminStitchTheme.pageMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
                color: AppTheme.textPrimary,
              ),
              const SizedBox(width: AppTheme.spacing2),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Text(
                      '공고 상세',
                      style: AdminStitchTheme.pageTitleForWidth(constraints.maxWidth),
                    );
                  },
                ),
              ),
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
    );
  }

  Widget _buildContent() {
    final job = _job!;
    final statusColor = _getStatusBadgeColor(job['status']);

    return AdminTableCard(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Flexible(
                  child: Text(
                    job['title'] ?? '제목 없음',
                    style: AdminStitchTheme.pageTitleMobile.copyWith(
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing4,
                    vertical: AppTheme.spacing2,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  ),
                  child: Text(
                    _getStatusLabel(job['status']),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
                if (job['isUrgent'] == true) ...[
                  const SizedBox(width: AppTheme.spacing2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing3,
                      vertical: AppTheme.spacing1,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.urgentRed.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    ),
                    child: const Text(
                      '급구',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.urgentRed,
                      ),
                    ),
                  ),
                ],
                if (job['isPremium'] == true) ...[
                  const SizedBox(width: AppTheme.spacing2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing3,
                      vertical: AppTheme.spacing1,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPurple.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    ),
                    child: const Text(
                      '프리미엄',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryPurple,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppTheme.spacing4),
            _buildInfoRow('일시', '${_formatDate(job['date'])} ${job['time'] ?? ''}'),
            _buildInfoRow('미용실', job['shop']?['name'] ?? '-'),
            _buildInfoRow('지역', _regionName(job)),
            _buildInfoRow('금액', _formatCurrency((job['amount'] ?? 0) as int)),
            _buildInfoRow('지원', '${job['_count']?['applications'] ?? 0}건'),
            _buildInfoRow('스케줄', '${job['_count']?['schedules'] ?? 0}건'),
            _buildInfoRow('등록일', _formatDate(job['createdAt'])),
            const SizedBox(height: AppTheme.spacing6),
            const Divider(height: 1),
            const SizedBox(height: AppTheme.spacing4),
            Wrap(
              spacing: AppTheme.spacing2,
              runSpacing: AppTheme.spacing2,
              children: [
                OutlinedButton(onPressed: () => _hideJob(false), child: const Text('숨김')),
                OutlinedButton(onPressed: () => _forceClose(), child: const Text('강제 마감')),
                FilledButton(
                  onPressed: () => _deleteJob(),
                  style: FilledButton.styleFrom(backgroundColor: AppTheme.urgentRed),
                  child: const Text('삭제'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacing2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _hideJob(bool hide) async {
    final reason = await AdminActionDialog.show(context, title: '공고 숨김', confirmLabel: '적용', summary: _job?['title']?.toString(), isDanger: true);
    if (reason == null || !mounted) return;
    await _adminService.hideJob(widget.jobId, reason: reason, hide: hide);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('공고가 숨김 처리되었습니다')));
  }

  Future<void> _forceClose() async {
    final reason = await AdminActionDialog.show(context, title: '공고 강제 마감', confirmLabel: '마감', summary: _job?['title']?.toString(), isDanger: true);
    if (reason == null || !mounted) return;
    await _adminService.forceCloseJob(widget.jobId, reason: reason);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('공고가 마감되었습니다')));
  }

  Future<void> _deleteJob() async {
    final reason = await AdminActionDialog.show(context, title: '공고 삭제', confirmLabel: '삭제', summary: _job?['title']?.toString(), isDanger: true);
    if (reason == null || !mounted) return;
    await _adminService.deleteJob(widget.jobId, reason: reason);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('공고가 삭제되었습니다')));
    context.pop();
  }
}
