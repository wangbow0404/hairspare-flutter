import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/application.dart';
import '../../theme/app_theme.dart';
import '../../utils/application_status_utils.dart';

/// 샵 지원자 카드 — 스페어 [MyApplicationsScreen] 카드 구조 + 샵 액션.
class ShopApplicantCard extends StatelessWidget {
  const ShopApplicantCard({
    super.key,
    required this.application,
    required this.onTapProfile,
    this.onApprove,
    this.onReject,
  });

  final Application application;
  final VoidCallback onTapProfile;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  @override
  Widget build(BuildContext context) {
    final spare = application.spare;
    final job = application.job;
    final status = ApplicationStatusUtils.normalize(application.status);
    final isPending = status == 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing3),
      padding: AppTheme.spacing(AppTheme.spacing4),
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: AppTheme.borderRadius(AppTheme.radiusXl),
        border: Border.all(color: AppTheme.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InitialAvatar(name: spare.name ?? spare.username),
              const SizedBox(width: AppTheme.spacing3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            spare.name ?? spare.username,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacing2),
                        _StatusBadge(status: application.status),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacing1),
                    Text(
                      job.title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing3),
          Row(
            children: [
              Text(
                '${job.date} ${job.time}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textTertiary,
                    ),
              ),
              const SizedBox(width: AppTheme.spacing3),
              Text(
                '${NumberFormat('#,###').format(job.amount)}원',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryPurple,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing2),
          Text(
            '지원일 ${DateFormat('yyyy.M.d HH:mm', 'ko_KR').format(application.createdAt)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textTertiary,
                  fontSize: 12,
                ),
          ),
          const SizedBox(height: AppTheme.spacing3),
          Row(
            children: [
              TextButton(
                onPressed: onTapProfile,
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primaryPurple,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('프로필 보기'),
              ),
              const Spacer(),
              if (isPending && onApprove != null && onReject != null) ...[
                OutlinedButton(
                  onPressed: onReject,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.urgentRed,
                    side: const BorderSide(color: AppTheme.urgentRed),
                    visualDensity: VisualDensity.compact,
                  ),
                  child: const Text('거절'),
                ),
                const SizedBox(width: AppTheme.spacing2),
                FilledButton(
                  onPressed: onApprove,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primaryPurple,
                    visualDensity: VisualDensity.compact,
                  ),
                  child: const Text('승인'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _InitialAvatar extends StatelessWidget {
  const _InitialAvatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0] : '?';
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppTheme.primaryPurple.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryPurple,
            ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = ApplicationStatusUtils.foreground(status);
    return Container(
      padding: AppTheme.spacingSymmetric(
        horizontal: AppTheme.spacing2,
        vertical: AppTheme.spacing1,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: AppTheme.borderRadius(AppTheme.radiusSm),
      ),
      child: Text(
        ApplicationStatusUtils.label(status),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
      ),
    );
  }
}
