import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/service_locator.dart';
import '../../core/services/global_messenger_service.dart';
import '../../core/router/app_routes.dart';
import '../../services/model_application_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_handler.dart';
import '../../widgets/common/spare_subpage_app_bar.dart';
import '../../widgets/stitch/stitch_empty_state.dart';

/// 내 모델 신청 현황 — 등록한 신청 글과 날짜별 상태 관리.
class ModelApplicationListScreen extends StatefulWidget {
  const ModelApplicationListScreen({super.key});

  @override
  State<ModelApplicationListScreen> createState() =>
      _ModelApplicationListScreenState();
}

class _ModelApplicationListScreenState
    extends State<ModelApplicationListScreen> {
  final ModelApplicationService _service = sl<ModelApplicationService>();
  List<ModelApplicationPost> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final posts = await _service.getMyPosts();
      if (!mounted) return;
      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      final ex = ErrorHandler.handleException(e);
      sl<GlobalMessengerService>()
          .showError(ErrorHandler.getUserFriendlyMessage(ex));
    }
  }

  Future<void> _cancelDate(String postId, String dateId) async {
    try {
      await _service.cancelDate(postId, dateId);
      await _load();
    } catch (e) {
      final ex = ErrorHandler.handleException(e);
      sl<GlobalMessengerService>()
          .showError(ErrorHandler.getUserFriendlyMessage(ex));
    }
  }

  Future<void> _goToCreate() async {
    final created = await context.push<bool>(
      AppRoutes.modelHomeApplicationPostsNew,
    );
    if (created == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: const SpareSubpageAppBar(title: '내 신청 현황'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _posts.isEmpty
              ? StitchEmptyState(
                  icon: Icons.calendar_month_outlined,
                  message: '등록한 모델 신청이 없습니다',
                  actionLabel: '모델 신청하기',
                  onAction: _goToCreate,
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(AppTheme.spacing4),
                    itemCount: _posts.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppTheme.spacing3),
                    itemBuilder: (context, index) =>
                        _PostCard(
                      post: _posts[index],
                      onCancelDate: (dateId) =>
                          _cancelDate(_posts[index].id, dateId),
                    ),
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToCreate,
        backgroundColor: AppTheme.stitchPrimary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('신청하기', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({required this.post, required this.onCancelDate});

  final ModelApplicationPost post;
  final ValueChanged<String> onCancelDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing4),
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.schedule, size: 16, color: AppTheme.stitchPrimary),
              const SizedBox(width: AppTheme.spacing1),
              Text(
                '${post.startTime} - ${post.endTime}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          if (post.keywords.isNotEmpty) ...[
            const SizedBox(height: AppTheme.spacing2),
            Wrap(
              spacing: AppTheme.spacing1,
              runSpacing: AppTheme.spacing1,
              children: post.keywords
                  .map(
                    (k) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacing2,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.purple100,
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      ),
                      child: Text(
                        k,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.purple700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          if (post.memo != null && post.memo!.isNotEmpty) ...[
            const SizedBox(height: AppTheme.spacing2),
            Text(
              post.memo!,
              style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
          ],
          const SizedBox(height: AppTheme.spacing3),
          const Divider(height: 1, color: AppTheme.borderGray),
          const SizedBox(height: AppTheme.spacing3),
          Column(
            children: post.dates
                .map((d) => _DateRow(date: d, onCancel: () => onCancelDate(d.id)))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _DateRow extends StatelessWidget {
  const _DateRow({required this.date, required this.onCancel});

  final ModelApplicationDate date;
  final VoidCallback onCancel;

  ({String label, Color color}) get _statusStyle {
    switch (date.status) {
      case 'matched':
        return (label: '매칭 완료', color: AppTheme.green600);
      case 'expired':
        return (label: '만료됨', color: AppTheme.textTertiary);
      case 'cancelled':
        return (label: '취소됨', color: AppTheme.textTertiary);
      default:
        return (label: '예정', color: AppTheme.stitchPrimary);
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _statusStyle;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing1),
      child: Row(
        children: [
          Expanded(
            child: Text(
              date.date,
              style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: style.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            ),
            child: Text(
              style.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: style.color,
              ),
            ),
          ),
          if (date.status == 'active') ...[
            const SizedBox(width: AppTheme.spacing2),
            InkWell(
              onTap: onCancel,
              child: const Icon(
                Icons.close,
                size: 18,
                color: AppTheme.textTertiary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
