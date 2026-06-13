import 'package:flutter/material.dart';

import '../../models/job.dart';
import '../../theme/app_theme.dart';

/// 샵 공고 상세 — 스페어 [JobDetailBottomBar]와 동일한 하단 고정 패턴.
class ShopJobDetailBottomBar extends StatelessWidget {
  const ShopJobDetailBottomBar({
    super.key,
    required this.job,
    required this.applicantCount,
    required this.isBusy,
    required this.onManageApplicants,
    required this.onEdit,
    required this.onClose,
    required this.onReopen,
    required this.onHide,
    required this.onUnhide,
    this.onRepost,
  });

  final Job job;
  final int applicantCount;
  final bool isBusy;
  final VoidCallback onManageApplicants;
  final VoidCallback onEdit;
  final VoidCallback onClose;
  final VoidCallback onReopen;
  final VoidCallback onHide;
  final VoidCallback onUnhide;
  final VoidCallback? onRepost;

  bool get _isExpired => job.status == 'expired';

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          AppTheme.spacing4,
          AppTheme.spacing3,
          AppTheme.spacing4,
          AppTheme.spacing4 + bottom,
        ),
        decoration: BoxDecoration(
          color: AppTheme.backgroundWhite,
          border: Border(
            top: BorderSide(color: AppTheme.borderGray.withValues(alpha: 0.8)),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isExpired) ...[
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  onPressed: isBusy ? null : onRepost,
                  icon: const Icon(Icons.content_copy, size: 20),
                  label: const Text('복사해서 다시 올리기'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primaryPurple,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacing2),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton(
                  onPressed: isBusy ? null : onManageApplicants,
                  child: Text('지원자 기록 ($applicantCount명)'),
                ),
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  onPressed: isBusy ? null : onManageApplicants,
                  icon: const Icon(Icons.people_outline, size: 20),
                  label: Text('지원자 관리 ($applicantCount명)'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primaryPurple,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacing2),
              Row(
                children: [
                  if (job.status == 'published' && !job.isHidden)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isBusy ? null : onHide,
                        child: const Text('숨김'),
                      ),
                    ),
                  if (job.isHidden) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isBusy ? null : onUnhide,
                        child: const Text('숨김 해제'),
                      ),
                    ),
                  ],
                  if (job.status == 'published') ...[
                    const SizedBox(width: AppTheme.spacing2),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isBusy ? null : onClose,
                        child: const Text('마감하기'),
                      ),
                    ),
                  ],
                  if (job.status == 'closed') ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isBusy ? null : onReopen,
                        child: const Text('재오픈'),
                      ),
                    ),
                  ],
                  const SizedBox(width: AppTheme.spacing2),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isBusy ? null : onEdit,
                      child: const Text('수정'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
