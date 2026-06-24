import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/di/service_locator.dart';
import '../../core/services/global_messenger_service.dart';
import '../../models/job.dart';
import '../../services/application_service.dart';
import '../../services/job_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_handler.dart';
import '../../utils/shell_navigation.dart';
import '../../view_models/job_detail_view_model.dart';
import '../../widgets/job_detail/job_detail_scroll_body.dart';
import '../../widgets/shop_jobs_list/shop_job_detail_bottom_bar.dart';

/// 샵「내 공고」상세 — 스페어 [JobDetailScrollBody]와 동일한 본문 + 샵 관리 액션.
class ShopJobDetailScreen extends StatefulWidget {
  const ShopJobDetailScreen({super.key, required this.jobId});

  final String jobId;

  @override
  State<ShopJobDetailScreen> createState() => _ShopJobDetailScreenState();
}

class _ShopJobDetailScreenState extends State<ShopJobDetailScreen> {
  final JobService _jobService = sl<JobService>();
  final ApplicationService _applicationService = sl<ApplicationService>();
  final GlobalMessengerService _messenger = sl<GlobalMessengerService>();

  bool _actionBusy = false;
  int _applicantCount = 0;

  Future<void> _reloadApplicantCount(String jobId) async {
    try {
      final apps = await _applicationService.getShopApplications();
      if (!mounted) return;
      setState(() {
        _applicantCount = apps.where((a) => a.job.id == jobId).length;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _applicantCount = 0);
    }
  }

  Future<void> _confirmDelete(Job job) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('공고 삭제'),
        content: const Text('정말 이 공고를 삭제하시겠습니까?\n삭제된 공고는 복구할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.urgentRed),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    setState(() => _actionBusy = true);
    try {
      await _jobService.deleteJob(job.id);
      if (!mounted) return;
      _messenger.showSuccess('공고가 삭제되었습니다');
      Navigator.pop(context, true);
    } catch (e) {
      final ex = ErrorHandler.handleException(e);
      _messenger.showError(
        '삭제 실패: ${ErrorHandler.getUserFriendlyMessage(ex)}',
      );
    } finally {
      if (mounted) setState(() => _actionBusy = false);
    }
  }

  Future<void> _confirmHide(Job job) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('공고 숨김'),
        content: const Text('숨김 처리하시겠습니까?\n다른 사람에게는 보이지 않습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('아니오'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('네'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    setState(() => _actionBusy = true);
    try {
      await _jobService.hideJob(job.id);
      if (!mounted) return;
      _messenger.showSuccess('공고가 숨김 처리되었습니다');
      await context.read<JobDetailViewModel>().loadJob();
    } catch (e) {
      final ex = ErrorHandler.handleException(e);
      _messenger.showError(
        '숨김 실패: ${ErrorHandler.getUserFriendlyMessage(ex)}',
      );
    } finally {
      if (mounted) setState(() => _actionBusy = false);
    }
  }

  Future<void> _confirmUnhide(Job job) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('숨김 해제'),
        content: const Text('숨김을 해제하시겠습니까?\n다시 스페어에게 노출됩니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('아니오'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('네'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    setState(() => _actionBusy = true);
    try {
      await _jobService.unhideJob(job.id);
      if (!mounted) return;
      _messenger.showSuccess('공고 숨김이 해제되었습니다');
      await context.read<JobDetailViewModel>().loadJob();
    } catch (e) {
      final ex = ErrorHandler.handleException(e);
      _messenger.showError(
        '숨김 해제 실패: ${ErrorHandler.getUserFriendlyMessage(ex)}',
      );
    } finally {
      if (mounted) setState(() => _actionBusy = false);
    }
  }

  Future<void> _confirmClose(Job job) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('공고 마감'),
        content: const Text('이 공고를 마감하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('마감'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    setState(() => _actionBusy = true);
    try {
      await _jobService.updateJobStatus(job.id, 'closed');
      if (!mounted) return;
      _messenger.showSuccess('공고가 마감되었습니다');
      await context.read<JobDetailViewModel>().loadJob();
    } catch (e) {
      final ex = ErrorHandler.handleException(e);
      _messenger.showError(
        '마감 실패: ${ErrorHandler.getUserFriendlyMessage(ex)}',
      );
    } finally {
      if (mounted) setState(() => _actionBusy = false);
    }
  }

  Future<void> _confirmReopen(Job job) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('공고 재오픈'),
        content: const Text('이 공고를 다시 오픈하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('재오픈'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    setState(() => _actionBusy = true);
    try {
      await _jobService.updateJobStatus(job.id, 'published');
      if (!mounted) return;
      _messenger.showSuccess('공고가 다시 오픈되었습니다');
      await context.read<JobDetailViewModel>().loadJob();
    } catch (e) {
      final ex = ErrorHandler.handleException(e);
      _messenger.showError(
        '재오픈 실패: ${ErrorHandler.getUserFriendlyMessage(ex)}',
      );
    } finally {
      if (mounted) setState(() => _actionBusy = false);
    }
  }

  Future<void> _openEdit(Job job) async {
    final updated = await ShellNavigation.pushShopJobNew(
      context,
      jobToEdit: job,
    );
    if (!mounted || updated != true) return;
    await context.read<JobDetailViewModel>().loadJob();
    await _reloadApplicantCount(job.id);
  }

  Future<void> _openRepost(Job job) async {
    final created = await ShellNavigation.pushShopJobNew(
      context,
      jobToCopy: job,
    );
    if (!mounted || created != true) return;
    Navigator.pop(context, true);
  }

  void _openApplicants(Job job) {
    ShellNavigation.pushShopApplicants(context, jobId: job.id);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => JobDetailViewModel(
        jobId: widget.jobId,
        shopOwnerMode: true,
        jobService: _jobService,
        favoriteService: sl(),
        verificationService: sl(),
        energyService: sl(),
      )..loadInitial(),
      child: _ShopJobDetailBody(
        actionBusy: _actionBusy,
        applicantCount: _applicantCount,
        onReady: _reloadApplicantCount,
        onDelete: _confirmDelete,
        onHide: _confirmHide,
        onUnhide: _confirmUnhide,
        onClose: _confirmClose,
        onReopen: _confirmReopen,
        onEdit: _openEdit,
        onManageApplicants: _openApplicants,
        onRepost: _openRepost,
      ),
    );
  }
}

class _ShopJobDetailBody extends StatefulWidget {
  const _ShopJobDetailBody({
    required this.actionBusy,
    required this.applicantCount,
    required this.onReady,
    required this.onDelete,
    required this.onHide,
    required this.onUnhide,
    required this.onClose,
    required this.onReopen,
    required this.onEdit,
    required this.onManageApplicants,
    required this.onRepost,
  });

  final bool actionBusy;
  final int applicantCount;
  final Future<void> Function(String jobId) onReady;
  final Future<void> Function(Job job) onDelete;
  final Future<void> Function(Job job) onHide;
  final Future<void> Function(Job job) onUnhide;
  final Future<void> Function(Job job) onClose;
  final Future<void> Function(Job job) onReopen;
  final Future<void> Function(Job job) onEdit;
  final void Function(Job job) onManageApplicants;
  final Future<void> Function(Job job) onRepost;

  @override
  State<_ShopJobDetailBody> createState() => _ShopJobDetailBodyState();
}

class _ShopJobDetailBodyState extends State<_ShopJobDetailBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onReady(context.read<JobDetailViewModel>().jobId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<JobDetailViewModel>();

    if (vm.isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.backgroundWhite,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (vm.error != null || vm.job == null) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundGray,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                vm.error ?? '공고를 찾을 수 없습니다',
                style: const TextStyle(color: AppTheme.urgentRed),
              ),
              const SizedBox(height: AppTheme.spacing4),
              ElevatedButton(
                onPressed: () => vm.loadJob(),
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      );
    }

    final job = vm.job!;

    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      body: SafeArea(
        top: true,
        bottom: false,
        child: Stack(
          children: [
            JobDetailScrollBody(
              job: job,
              hasApplied: false,
              forShopOwner: true,
              onEdit: job.status == 'expired'
                  ? null
                  : () => widget.onEdit(job),
              onDelete: () => widget.onDelete(job),
            ),
            ShopJobDetailBottomBar(
              job: job,
              applicantCount: widget.applicantCount,
              isBusy: widget.actionBusy,
              onManageApplicants: () => widget.onManageApplicants(job),
              onEdit: () => widget.onEdit(job),
              onClose: () => widget.onClose(job),
              onReopen: () => widget.onReopen(job),
              onHide: () => widget.onHide(job),
              onUnhide: () => widget.onUnhide(job),
              onRepost: job.status == 'expired'
                  ? () => widget.onRepost(job)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
