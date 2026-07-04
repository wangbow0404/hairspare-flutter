import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/job.dart';
import '../../theme/app_theme.dart';
import '../common/shared_app_bar.dart';
import '../../utils/app_exception.dart';
import '../../utils/icon_mapper.dart';
import '../../utils/shell_navigation.dart';
import '../../view_models/shop_jobs_list_view_model.dart';
import 'shop_jobs_list_job_card.dart';

/// 내 공고 목록 본문: 당겨서 새로고침·무한 스크롤 리스트(상단바는 [ShopJobsListHeader]).
class ShopJobsListScrollView extends StatelessWidget {
  const ShopJobsListScrollView({super.key, required this.scrollController});

  final ScrollController scrollController;

  Future<void> _confirmDelete(
    BuildContext context,
    ShopJobsListViewModel vm,
    Job job,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('공고 삭제'),
        content: const Text('정말 이 공고를 삭제하시겠습니까?'),
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
    if (ok != true || !context.mounted) return;

    try {
      await vm.deleteJob(job.id);
    } on ValidationException catch (e) {
      if (e.code != 'REASON_REQUIRED' || !context.mounted) return;
      final reason = await _promptDeleteReason(context);
      if (reason != null && reason.trim().isNotEmpty && context.mounted) {
        await vm.deleteJob(job.id, reason: reason.trim());
      }
    }
  }

  Future<String?> _promptDeleteReason(BuildContext context) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('삭제 사유 입력'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '이미 승인된 지원자가 있는 공고입니다.\n삭제 사유를 입력하면 지원자에게 전달됩니다.',
            ),
            const SizedBox(height: AppTheme.spacing3),
            TextField(
              controller: controller,
              autofocus: true,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: '예: 매장 사정으로 인해 근무가 취소되었습니다',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            style: TextButton.styleFrom(foregroundColor: AppTheme.urgentRed),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  Future<void> _openRepostJob(
    BuildContext context,
    ShopJobsListViewModel vm,
    Job job,
  ) async {
    final created = await ShellNavigation.pushShopJobNew(
      context,
      jobToCopy: job,
    );
    if (!context.mounted) return;
    if (created == true) {
      await vm.setStatusFilter('published');
    }
  }

  Future<void> _openEditJob(
    BuildContext context,
    ShopJobsListViewModel vm,
    Job job,
  ) async {
    final updated = await ShellNavigation.pushShopJobNew(
      context,
      jobToEdit: job,
    );
    if (!context.mounted) return;
    if (updated == true) {
      await vm.refresh();
    }
  }

  void _openApplicants(BuildContext context, Job job) {
    ShellNavigation.pushShopApplicants(context, jobId: job.id);
  }

  Future<void> _confirmHide(
    BuildContext context,
    ShopJobsListViewModel vm,
    Job job,
  ) async {
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
    if (ok == true && context.mounted) {
      await vm.hideJob(job.id);
    }
  }

  Future<void> _confirmUnhide(
    BuildContext context,
    ShopJobsListViewModel vm,
    Job job,
  ) async {
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
    if (ok == true && context.mounted) {
      await vm.unhideJob(job.id);
    }
  }

  Future<void> _confirmClose(
    BuildContext context,
    ShopJobsListViewModel vm,
    Job job,
  ) async {
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
    if (ok == true && context.mounted) {
      await vm.closeJob(job.id);
    }
  }

  Future<void> _confirmReopen(
    BuildContext context,
    ShopJobsListViewModel vm,
    Job job,
  ) async {
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
    if (ok == true && context.mounted) {
      await vm.reopenJob(job.id);
    }
  }

  void _openJob(BuildContext context, Job job) {
    ShellNavigation.pushShopJobDetail(context, job.id);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ShopJobsListViewModel>();

    return RefreshIndicator(
      onRefresh: vm.refresh,
      child: CustomScrollView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(AppTheme.spacing4),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: AppTheme.borderGray),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '표시 중 ${vm.jobs.length}건${vm.hasMore ? " · 더 불러오기 가능" : ""}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textSecondary,
                        ),
                  ),
                  const SizedBox(height: AppTheme.spacing3),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FilterChip(
                          label: '전체',
                          value: 'all',
                          selected: vm.statusFilter,
                          onSelect: vm.setStatusFilter,
                        ),
                        const SizedBox(width: AppTheme.spacing2),
                        _FilterChip(
                          label: '진행중',
                          value: 'published',
                          selected: vm.statusFilter,
                          onSelect: vm.setStatusFilter,
                        ),
                        const SizedBox(width: AppTheme.spacing2),
                        _FilterChip(
                          label: '마감',
                          value: 'closed',
                          selected: vm.statusFilter,
                          onSelect: vm.setStatusFilter,
                        ),
                        const SizedBox(width: AppTheme.spacing2),
                        _FilterChip(
                          label: '지난 공고',
                          value: 'expired',
                          selected: vm.statusFilter,
                          onSelect: vm.setStatusFilter,
                        ),
                        const SizedBox(width: AppTheme.spacing2),
                        _FilterChip(
                          label: '임시저장',
                          value: 'draft',
                          selected: vm.statusFilter,
                          onSelect: vm.setStatusFilter,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (vm.isRefreshing)
            const SliverToBoxAdapter(
              child: LinearProgressIndicator(minHeight: 2),
            ),
          if (vm.isLoading && vm.jobs.isEmpty)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (!vm.isLoading && vm.jobs.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      vm.statusFilter == 'expired'
                          ? Icons.history
                          : Icons.work_outline,
                      size: 64,
                      color: AppTheme.textTertiary,
                    ),
                    const SizedBox(height: AppTheme.spacing4),
                    Text(
                      vm.statusFilter == 'expired'
                          ? '지난 공고가 없습니다'
                          : '등록한 공고가 없습니다',
                      style: const TextStyle(
                        fontSize: 18,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            SliverPadding(
              padding: const EdgeInsets.all(AppTheme.spacing4),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final job = vm.jobs[index];
                    return ShopJobsListJobCard(
                      job: job,
                      applicantCount: vm.applicantCountFor(job.id),
                      onTap: () => _openJob(context, job),
                      onHide: () => _confirmHide(context, vm, job),
                      onUnhide: () => _confirmUnhide(context, vm, job),
                      onEdit: () => _openEditJob(context, vm, job),
                      onClose: () => _confirmClose(context, vm, job),
                      onReopen: () => _confirmReopen(context, vm, job),
                      onDelete: () => _confirmDelete(context, vm, job),
                      onManageApplicants: () => _openApplicants(context, job),
                      onRepost: ShopJobsListViewModel.effectiveStatus(job) == 'expired'
                          ? () => _openRepostJob(context, vm, job)
                          : null,
                    );
                  },
                  childCount: vm.jobs.length,
                ),
              ),
            ),
            if (vm.isLoadingMore)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(AppTheme.spacing4),
                  child: Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: AppTheme.spacing6)),
          ],
          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onSelect,
  });

  final String label;
  final String value;
  final String selected;
  final Future<void> Function(String) onSelect;

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == value;
    return GestureDetector(
      onTap: () => unawaited(onSelect(value)),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacing3,
          vertical: AppTheme.spacing2,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? (value == 'published'
                  ? Colors.green.shade100
                  : value == 'closed'
                      ? Colors.grey.shade100
                      : value == 'expired'
                          ? Colors.blue.shade50
                          : value == 'draft'
                              ? Colors.amber.shade100
                              : AppTheme.primaryPurple.withValues(alpha: 0.1))
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(
            color: isSelected
                ? (value == 'published'
                    ? Colors.green.shade300
                    : value == 'closed'
                        ? Colors.grey.shade300
                        : value == 'expired'
                            ? Colors.blue.shade200
                            : value == 'draft'
                                ? Colors.amber.shade300
                                : AppTheme.primaryPurple)
                : AppTheme.borderGray,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected
                ? (value == 'published'
                    ? Colors.green.shade700
                    : value == 'closed'
                        ? Colors.grey.shade700
                        : value == 'expired'
                            ? Colors.blue.shade700
                            : value == 'draft'
                                ? Colors.amber.shade700
                                : AppTheme.primaryPurple)
                : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// 내 공고 상단바 — [ShopSparesListScreen]과 동일한 44px Row 레이아웃.
class ShopJobsListHeader extends StatefulWidget {
  const ShopJobsListHeader({super.key});

  @override
  State<ShopJobsListHeader> createState() => _ShopJobsListHeaderState();
}

class _ShopJobsListHeaderState extends State<ShopJobsListHeader> {
  bool _isSearchOpen = false;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ShopJobsListViewModel>();

    return Container(
      height: 44,
      decoration: const BoxDecoration(
        color: AppTheme.backgroundWhite,
        border: Border(
          bottom: BorderSide(color: AppTheme.borderGray, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing4,
      ),
      child: SizedBox(
        height: 44,
        child: Row(
          children: [
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              icon: IconMapper.icon(
                    'chevronleft',
                    size: 24,
                    color: AppTheme.textSecondary,
                  ) ??
                  const Icon(
                    Icons.arrow_back_ios,
                    size: 20,
                    color: AppTheme.textSecondary,
                  ),
              onPressed: () => Navigator.pop(context),
            ),
            if (!_isSearchOpen) ...[
              Text(
                '내 공고',
                style: SharedAppBar.titleTextStyle(context),
              ),
              const SizedBox(width: AppTheme.spacing2),
            ],
            if (_isSearchOpen)
              Expanded(
                child: TextField(
                  controller: vm.searchController,
                  autofocus: true,
                  onChanged: vm.onSearchTextChanged,
                  decoration: InputDecoration(
                    hintText: '공고 검색...',
                    border: OutlineInputBorder(
                      borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                      borderSide: const BorderSide(
                        color: AppTheme.primaryPurple,
                        width: 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                      borderSide: const BorderSide(
                        color: AppTheme.primaryPurple,
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                      borderSide: const BorderSide(
                        color: AppTheme.primaryPurple,
                        width: 2,
                      ),
                    ),
                    contentPadding: AppTheme.spacingSymmetric(
                      horizontal: AppTheme.spacing4,
                      vertical: AppTheme.spacing2,
                    ),
                    isDense: true,
                    filled: true,
                    fillColor: AppTheme.backgroundWhite,
                  ),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              )
            else
              const Spacer(),
            if (_isSearchOpen)
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                onPressed: () {
                  setState(() => _isSearchOpen = false);
                  vm.clearSearch();
                },
              )
            else ...[
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                icon: const Icon(Icons.search, color: AppTheme.textSecondary),
                onPressed: () => setState(() => _isSearchOpen = true),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
