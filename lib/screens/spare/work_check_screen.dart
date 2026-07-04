import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/di/service_locator.dart';
import '../../core/router/app_navigation.dart';
import '../../theme/app_theme.dart';
import '../../utils/deferred_route_body.dart';
import '../../utils/navigation_helper.dart';
import '../../view_models/work_check_view_model.dart';
import '../../widgets/common/spare_subpage_app_bar.dart';
import '../../widgets/schedule/schedule_work_complete_review_modal.dart';
import '../../widgets/work_check/work_check_app_bar.dart';
import '../../widgets/work_check/work_check_scroll_content.dart';

/// 스페어 스케줄표·근무체크 (캘린더·근무 보상·일정 카드).
class WorkCheckScreen extends StatefulWidget {
  const WorkCheckScreen({
    super.key,
    this.initialDay,
    this.focusJobId,
    this.focusScheduleId,
    this.openProposalDetail = false,
    this.isTabRoot = false,
    this.isModelMode = false,
  });

  final DateTime? initialDay;
  final String? focusJobId;
  final String? focusScheduleId;
  final bool openProposalDetail;
  final bool isTabRoot;
  final bool isModelMode;

  @override
  State<WorkCheckScreen> createState() => _WorkCheckScreenState();
}

class _WorkCheckScreenState extends State<WorkCheckScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WorkCheckViewModel(
        scheduleService: sl(),
        reviewService: sl(),
        initialDay: widget.initialDay,
        focusJobId: widget.focusJobId,
        focusScheduleId: widget.focusScheduleId,
        isModelMode: widget.isModelMode,
      )..loadInitial(),
      child: _WorkCheckDeferredShell(
        searchController: _searchController,
        scrollController: _scrollController,
        openProposalDetail: widget.openProposalDetail,
        focusScheduleId: widget.focusScheduleId,
        focusJobId: widget.focusJobId,
        isTabRoot: widget.isTabRoot,
        isModelMode: widget.isModelMode,
      ),
    );
  }
}

class _WorkCheckDeferredShell extends StatefulWidget {
  const _WorkCheckDeferredShell({
    required this.searchController,
    required this.scrollController,
    required this.openProposalDetail,
    this.focusScheduleId,
    this.focusJobId,
    this.isTabRoot = false,
    this.isModelMode = false,
  });

  final TextEditingController searchController;
  final ScrollController scrollController;
  final bool openProposalDetail;
  final String? focusScheduleId;
  final String? focusJobId;
  final bool isTabRoot;
  final bool isModelMode;

  @override
  State<_WorkCheckDeferredShell> createState() => _WorkCheckDeferredShellState();
}

class _WorkCheckDeferredShellState extends State<_WorkCheckDeferredShell>
    with DeferredRouteBodyMixin {
  @override
  Widget build(BuildContext context) {
    return deferredBody(
      loading: const Scaffold(
        backgroundColor: AppTheme.backgroundGray,
        body: Center(child: CircularProgressIndicator()),
      ),
      builder: (context) => _WorkCheckScaffold(
        searchController: widget.searchController,
        scrollController: widget.scrollController,
        openProposalDetail: widget.openProposalDetail,
        focusScheduleId: widget.focusScheduleId,
        focusJobId: widget.focusJobId,
        isTabRoot: widget.isTabRoot,
        isModelMode: widget.isModelMode,
      ),
    );
  }
}

class _WorkCheckScaffold extends StatefulWidget {
  const _WorkCheckScaffold({
    required this.searchController,
    required this.scrollController,
    required this.openProposalDetail,
    this.focusScheduleId,
    this.focusJobId,
    this.isTabRoot = false,
    this.isModelMode = false,
  });

  final TextEditingController searchController;
  final ScrollController scrollController;
  final bool openProposalDetail;
  final String? focusScheduleId;
  final String? focusJobId;
  final bool isTabRoot;
  final bool isModelMode;

  @override
  State<_WorkCheckScaffold> createState() => _WorkCheckScaffoldState();
}

class _WorkCheckScaffoldState extends State<_WorkCheckScaffold> {
  bool _openedProposalDetail = false;
  bool _scrolledToScheduleCard = false;

  void _handleModelBack(BuildContext context) {
    AppNavigation.backFromModelTab(context);
  }

  void _scrollToScheduleCardIfNeeded(WorkCheckViewModel vm) {
    if (_scrolledToScheduleCard || vm.isLoading) return;
    if (!vm.hasDeepLinkScheduleFocus || vm.selectedScheduleId == null) {
      return;
    }
    _scrolledToScheduleCard = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.scrollController.hasClients) return;
      widget.scrollController.animateTo(
        widget.scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _maybeOpenProposalDetail(WorkCheckViewModel vm) async {
    if (!widget.openProposalDetail || _openedProposalDetail) return;
    _openedProposalDetail = true;

    final schedule = vm.findScheduleForProposal(
      scheduleId: widget.focusScheduleId,
      jobId: widget.focusJobId,
    );
    if (schedule == null || schedule.status != 'proposed') return;
    if (!mounted) return;

    final resolved = await NavigationHelper.navigateToWorkProposalDetail(
      context,
      schedule,
    );
    if (resolved == true && mounted) {
      await context.read<WorkCheckViewModel>().loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WorkCheckViewModel>();

    if (!vm.isLoading) {
      if (widget.openProposalDetail) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _maybeOpenProposalDetail(vm);
        });
      } else {
        _scrollToScheduleCardIfNeeded(vm);
      }
    }

    if (vm.isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundGray,
        appBar: widget.isModelMode
            ? SpareSubpageAppBar(
                title: '스케줄 관리',
                showToolbarActions: !widget.isTabRoot,
                onBackPressed: () => _handleModelBack(context),
              )
            : null,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (widget.isModelMode) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundGray,
        appBar: SpareSubpageAppBar(
          title: '스케줄 관리',
          showToolbarActions: !widget.isTabRoot,
          onBackPressed: () => _handleModelBack(context),
        ),
        body: SafeArea(
          top: false,
          bottom: false,
          child: Stack(
            children: [
              RefreshIndicator(
                onRefresh: vm.loadData,
                child: CustomScrollView(
                  controller: widget.scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: WorkCheckScrollContent(
                        isModelMode: true,
                      ),
                    ),
                  ],
                ),
              ),
              if (vm.showRatingModal && vm.ratedShopName != null)
                ScheduleWorkCompleteReviewModal(
                  shopName: vm.ratedShopName!,
                  jobTitle: vm.ratedJobTitle ?? '공고',
                  onClose: vm.dismissRatingModalUiOnly,
                  onThumbsUp: () => vm.handleThumbsUp(),
                  onCheckInOnly: () => vm.handleCloseRatingModal(),
                  isSubmitting: vm.reviewSubmitting,
                  modalTitle: '시술 완료',
                  prompt: '오늘 시술은 어땠나요?\n디자이너에게 응원을 보내보세요',
                ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      body: SafeArea(
        top: true,
        bottom: false,
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: vm.loadData,
              child: CustomScrollView(
                controller: widget.scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  WorkCheckSliverAppBar(
                    searchController: widget.searchController,
                    showBackButton: !widget.isTabRoot,
                  ),
                  SliverToBoxAdapter(
                    child: WorkCheckScrollContent(
                      isModelMode: widget.isModelMode,
                    ),
                  ),
                ],
              ),
            ),
            if (vm.showRatingModal && vm.ratedShopName != null)
              ScheduleWorkCompleteReviewModal(
                shopName: vm.ratedShopName!,
                jobTitle: vm.ratedJobTitle ?? '공고',
                onClose: vm.dismissRatingModalUiOnly,
                onThumbsUp: () => vm.handleThumbsUp(),
                onCheckInOnly: () => vm.handleCloseRatingModal(),
                isSubmitting: vm.reviewSubmitting,
              ),
          ],
        ),
      ),
    );
  }
}
