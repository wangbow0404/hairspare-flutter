import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/di/service_locator.dart';
import '../../core/services/global_messenger_service.dart';
import '../../theme/app_theme.dart';
import '../../view_models/job_detail_view_model.dart';
import '../../mocks/mock_spare_data.dart';
import '../../utils/api_config.dart';
import '../../utils/deferred_route_body.dart';
import '../../utils/navigation_helper.dart';
import '../../utils/shell_navigation.dart';
import '../../models/spare_job_engagement.dart';
import '../../widgets/schedule/schedule_conflict_dialog.dart';
import '../../widgets/job_detail/job_detail_bottom_bar.dart';
import '../../widgets/job_detail/job_detail_modals.dart';
import '../../widgets/job_detail/job_detail_scroll_body.dart';
import '../../widgets/spare_app_bar.dart';

class JobDetailScreen extends StatefulWidget {
  const JobDetailScreen({super.key, required this.jobId});

  final String jobId;

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => JobDetailViewModel(
        jobId: widget.jobId,
        jobService: sl(),
        favoriteService: sl(),
        verificationService: sl(),
        energyService: sl(),
      )..loadInitial(),
      child: const _JobDetailScaffold(),
    );
  }
}

class _JobDetailScaffold extends StatelessWidget {
  const _JobDetailScaffold();

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
        appBar: const SpareAppBar(showSearch: false, showBackButton: true),
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
                onPressed: () => context.read<JobDetailViewModel>().loadJob(),
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      );
    }

    final job = vm.job!;

    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundWhite,
        body: SafeArea(
          top: true,
          bottom: false,
          child: Stack(
            children: [
              JobDetailScrollBody(job: job, hasApplied: vm.hasApplied),
              JobDetailBottomBar(
                isLocked: vm.isLocked,
                showProposalActions: vm.isProposalMode,
                isSubmitting: vm.proposalSubmitting,
                onReject: () async {
                  final ok = await vm.rejectProposal();
                  if (ok && context.mounted) {
                    Navigator.pop(context, true);
                  }
                },
                onAccept: () => _acceptProposalWithConflictCheck(context, vm),
                primaryLabel: vm.primaryActionLabel,
                onPrimary: () {
                  if (vm.engagement == SpareJobEngagement.open) {
                    _tryOpenApplyFlow(context, vm);
                    return;
                  }
                  final day = vm.linkedSchedule?.date;
                  NavigationHelper.navigateToWorkCheck(
                    context,
                    initialDay:
                        day != null ? DateTime.tryParse(day) : null,
                    jobId: vm.jobId,
                    scheduleId: vm.linkedSchedule?.id,
                  );
                },
              ),
              if (vm.showVerificationModal)
                JobDetailVerificationModal(
                  onDismiss: vm.dismissVerificationModal,
                  onGoVerify: () {
                    vm.dismissVerificationModal();
                    deferAfterTap(() => ShellNavigation.pushVerification(context));
                  },
                ),
              if (vm.showConfirmModal)
                JobDetailConfirmApplyModal(
                  job: job,
                  onConfirm: () => _confirmApplyWithConflictCheck(context, vm),
                  onCancel: vm.dismissConfirmModal,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _tryOpenApplyFlow(BuildContext context, JobDetailViewModel vm) async {
  if (ApiConfig.useMockData && vm.jobId == MockSpareData.overlapDemoJobId) {
    await vm.refreshJobSnapshot();
  }
  final conflicts = await vm.findApplyConflicts();
  if (!context.mounted) return;
  if (conflicts.isNotEmpty) {
    await ScheduleConflictDialog.show(
      context: context,
      actionLabel: '지원',
      conflicts: conflicts,
      onResolved: () => vm.loadInitial(),
    );
    return;
  }
  vm.requestApply();
}

Future<void> _confirmApplyWithConflictCheck(
  BuildContext context,
  JobDetailViewModel vm,
) async {
  if (ApiConfig.useMockData && vm.jobId == MockSpareData.overlapDemoJobId) {
    await vm.refreshJobSnapshot();
  }
  final conflicts = await vm.findApplyConflicts();
  if (!context.mounted) return;
  if (conflicts.isNotEmpty) {
    vm.dismissConfirmModal();
    await ScheduleConflictDialog.show(
      context: context,
      actionLabel: '지원',
      conflicts: conflicts,
      onResolved: () => vm.loadInitial(),
    );
    return;
  }
  await vm.confirmApply();
}

Future<void> _acceptProposalWithConflictCheck(
  BuildContext context,
  JobDetailViewModel vm,
) async {
  final messenger = sl<GlobalMessengerService>();
  var conflicts = await vm.findAcceptProposalConflicts();
  if (!context.mounted) return;

  final rejected = await vm.autoRejectOverlappingProposals(conflicts);
  if (rejected > 0) {
    messenger.showInfo('겹치는 제안 $rejected건을 거절했습니다.');
    conflicts = await vm.findAcceptProposalConflicts();
    if (!context.mounted) return;
  }

  if (conflicts.isNotEmpty) {
    if (!context.mounted) return;
    final resolved = await ScheduleConflictDialog.show(
      context: context,
      actionLabel: '제안 수락',
      conflicts: conflicts,
      onResolved: () => vm.refreshEngagementOnly(),
    );
    if (!resolved || !context.mounted) {
      messenger.showError('겹치는 근무를 정리해야 수락할 수 있어요.');
      return;
    }
    conflicts = await vm.findAcceptProposalConflicts();
    if (!context.mounted) return;
    if (conflicts.isNotEmpty) {
      messenger.showError(
        '아직 겹치는 근무가 남아 있습니다. 스케줄표에서 확인해 주세요.',
      );
      return;
    }
  }

  final ok = await vm.acceptProposal();
  if (!context.mounted) return;
  if (ok && Navigator.canPop(context)) {
    Navigator.pop(context, true);
  }
}
