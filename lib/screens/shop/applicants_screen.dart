import 'package:flutter/material.dart';

import '../../core/di/service_locator.dart';
import '../../core/services/global_messenger_service.dart';
import '../../models/application.dart';
import '../../models/job.dart';
import '../../utils/shop_applicant_counts.dart';
import '../../services/application_service.dart';
import '../../services/job_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/application_status_utils.dart';
import '../../utils/error_handler.dart';
import '../../utils/deferred_route_body.dart';
import '../../utils/shell_navigation.dart';
import '../../widgets/common/shared_app_bar.dart';
import '../../widgets/shop_applicants/shop_applicant_card.dart';
import '../../widgets/shop_applicants/shop_applicants_filter_chip.dart';

/// 샵 지원자 관리 — 내 공고 목록과 동일한 필터·카드 톤.
class ShopApplicantsScreen extends StatefulWidget {
  const ShopApplicantsScreen({super.key, this.initialJobId});

  final String? initialJobId;

  @override
  State<ShopApplicantsScreen> createState() => _ShopApplicantsScreenState();
}

class _ShopApplicantsScreenState extends State<ShopApplicantsScreen>
    with DeferredRouteBodyMixin {
  final ApplicationService _applicationService = sl<ApplicationService>();
  final JobService _jobService = sl<JobService>();
  final GlobalMessengerService _messenger = sl<GlobalMessengerService>();

  List<Application> _applications = [];
  List<Job> _jobs = [];
  bool _isLoading = true;
  String _statusFilter = 'all';
  String? _selectedJobId;

  @override
  void initState() {
    super.initState();
    _selectedJobId = widget.initialJobId;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        _applicationService.getShopApplications(),
        _jobService.getMyJobs(),
      ]);

      if (!mounted) return;
      final jobs = results[1] as List<Job>;
      final jobIds = jobs.map((j) => j.id).toSet();
      setState(() {
        _jobs = jobs;
        _applications = (results[0] as List<Application>)
            .where((a) => jobIds.contains(a.job.id))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      final ex = ErrorHandler.handleException(e);
      _messenger.showError(ErrorHandler.getUserFriendlyMessage(ex));
    }
  }

  List<Application> get _filteredApplications {
    var filtered = List<Application>.from(_applications);

    if (_selectedJobId != null) {
      filtered =
          filtered.where((app) => app.job.id == _selectedJobId).toList();
    }

    if (_statusFilter != 'all') {
      filtered = filtered
          .where(
            (app) =>
                ApplicationStatusUtils.normalize(app.status) == _statusFilter,
          )
          .toList();
    }

    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return filtered;
  }

  Job? _jobForApplication(Application application) {
    for (final job in _jobs) {
      if (job.id == application.job.id) return job;
    }
    return application.job;
  }

  Future<void> _handleApprove(String applicationId) async {
    final application = _applications.firstWhere((a) => a.id == applicationId);
    final job = _jobForApplication(application)!;

    if (!ShopApplicantCounts.canApproveApplication(job, _applications)) {
      if (job.status == 'closed') {
        _messenger.showMessage('이미 마감된 공고입니다');
      } else {
        _messenger.showMessage(
          '모집 인원(${job.requiredCount}명)이 모두 찼습니다',
        );
      }
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('지원 승인'),
        content: const Text('이 지원자를 승인하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('승인'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      final result = await _applicationService.approveApplication(applicationId);
      if (!mounted) return;
      if (result.jobAutoClosed) {
        _messenger.showSuccess(
          '지원자가 승인되었습니다.\n스케줄에 반영되었으며, 모집 인원 충족으로 공고가 마감되었습니다.',
          duration: const Duration(seconds: 4),
        );
      } else {
        _messenger.showSuccess(
          '지원자가 승인되었습니다.\n스케줄 탭에서 근무 일정을 확인할 수 있습니다.',
          duration: const Duration(seconds: 4),
        );
      }
      await _loadData();
    } catch (e) {
      if (!mounted) return;
      final ex = ErrorHandler.handleException(e);
      _messenger.showError(ErrorHandler.getUserFriendlyMessage(ex));
    }
  }

  Future<void> _handleReject(String applicationId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('지원 거절'),
        content: const Text('이 지원을 거절하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.urgentRed),
            child: const Text('거절'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await _applicationService.rejectApplication(applicationId);
      if (!mounted) return;
      _messenger.showSuccess('지원이 거절되었습니다');
      await _loadData();
    } catch (e) {
      if (!mounted) return;
      final ex = ErrorHandler.handleException(e);
      _messenger.showError(ErrorHandler.getUserFriendlyMessage(ex));
    }
  }

  void _openSpareProfile(String spareId, {String? jobId}) {
    ShellNavigation.pushShopSpareDetail(context, spareId, jobId: jobId);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredApplications;
    final pendingCount = ShopApplicantCounts.pending(filtered);
    final approvedCount = ShopApplicantCounts.approved(filtered);

    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: const SharedAppBar(title: '지원자 관리'),
      body: deferredBody(
        loading: const Center(child: CircularProgressIndicator()),
        builder: (context) => _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
              children: [
                _ApplicantsSummaryBar(
                  total: filtered.length,
                  pending: pendingCount,
                  approved: approvedCount,
                ),
                _ApplicantsFilterPanel(
                  jobs: _jobs,
                  selectedJobId: _selectedJobId,
                  statusFilter: _statusFilter,
                  onJobSelected: (id) => setState(() => _selectedJobId = id),
                  onStatusSelected: (value) =>
                      setState(() => _statusFilter = value),
                ),
                Expanded(
                  child: filtered.isEmpty
                      ? const _ApplicantsEmptyState()
                      : RefreshIndicator(
                          onRefresh: _loadData,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(AppTheme.spacing4),
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final application = filtered[index];
                              final status = ApplicationStatusUtils.normalize(
                                application.status,
                              );
                              final isPending = status == 'pending';
                              final job = _jobForApplication(application)!;
                              final canApprove = isPending &&
                                  ShopApplicantCounts.canApproveApplication(
                                    job,
                                    _applications,
                                  );
                              return ShopApplicantCard(
                                application: application,
                                onTapProfile: () => _openSpareProfile(
                                  application.spare.id,
                                  jobId: application.job.id,
                                ),
                                onApprove: canApprove
                                    ? () => _handleApprove(application.id)
                                    : null,
                                onReject: isPending
                                    ? () => _handleReject(application.id)
                                    : null,
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
      ),
    );
  }
}

class _ApplicantsSummaryBar extends StatelessWidget {
  const _ApplicantsSummaryBar({
    required this.total,
    required this.pending,
    required this.approved,
  });

  final int total;
  final int pending;
  final int approved;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing4,
        vertical: AppTheme.spacing3,
      ),
      color: AppTheme.backgroundWhite,
      child: Row(
        children: [
          Text(
            '총 $total명',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
          ),
          const SizedBox(width: AppTheme.spacing3),
          _SummaryDot(label: '대기 $pending', color: Colors.amber.shade700),
          const SizedBox(width: AppTheme.spacing2),
          _SummaryDot(label: '승인 $approved', color: Colors.green.shade700),
        ],
      ),
    );
  }
}

class _SummaryDot extends StatelessWidget {
  const _SummaryDot({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppTheme.spacing1),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
      ],
    );
  }
}

class _ApplicantsFilterPanel extends StatelessWidget {
  const _ApplicantsFilterPanel({
    required this.jobs,
    required this.selectedJobId,
    required this.statusFilter,
    required this.onJobSelected,
    required this.onStatusSelected,
  });

  final List<Job> jobs;
  final String? selectedJobId;
  final String statusFilter;
  final ValueChanged<String?> onJobSelected;
  final ValueChanged<String> onStatusSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacing4,
        AppTheme.spacing2,
        AppTheme.spacing4,
        AppTheme.spacing3,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.backgroundWhite,
        border: Border(bottom: BorderSide(color: AppTheme.borderGray)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ShopApplicantsFilterChip(
                  label: '전체',
                  isSelected: statusFilter == 'all',
                  onTap: () => onStatusSelected('all'),
                ),
                const SizedBox(width: AppTheme.spacing2),
                ShopApplicantsFilterChip(
                  label: '대기중',
                  isSelected: statusFilter == 'pending',
                  onTap: () => onStatusSelected('pending'),
                ),
                const SizedBox(width: AppTheme.spacing2),
                ShopApplicantsFilterChip(
                  label: '승인됨',
                  isSelected: statusFilter == 'approved',
                  onTap: () => onStatusSelected('approved'),
                ),
                const SizedBox(width: AppTheme.spacing2),
                ShopApplicantsFilterChip(
                  label: '거절됨',
                  isSelected: statusFilter == 'rejected',
                  onTap: () => onStatusSelected('rejected'),
                ),
              ],
            ),
          ),
          if (jobs.isNotEmpty) ...[
            const SizedBox(height: AppTheme.spacing3),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ShopApplicantsFilterChip(
                    label: '공고 전체',
                    isSelected: selectedJobId == null,
                    onTap: () => onJobSelected(null),
                  ),
                  const SizedBox(width: AppTheme.spacing2),
                  for (final job in jobs)
                    Padding(
                      padding: const EdgeInsets.only(right: AppTheme.spacing2),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 160),
                        child: ShopApplicantsFilterChip(
                          label: job.title,
                          isSelected: selectedJobId == job.id,
                          onTap: () => onJobSelected(
                            selectedJobId == job.id ? null : job.id,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ApplicantsEmptyState extends StatelessWidget {
  const _ApplicantsEmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 56,
            color: AppTheme.textTertiary,
          ),
          SizedBox(height: AppTheme.spacing3),
          Text(
            '지원자가 없습니다',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
