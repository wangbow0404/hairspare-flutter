import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../models/job.dart';
import '../../theme/app_theme.dart';
import '../../utils/api_config.dart';
import '../../utils/region_helper.dart';
import '../../utils/work_schedule_utils.dart';

String _proxyImageUrl(String url) {
  if (!kIsWeb) return url;
  if (url.contains('.r2.dev/') && url.startsWith('https://')) {
    return '${ApiConfig.getBaseUrl()}/api/auth/image-proxy?url=${Uri.encodeComponent(url)}';
  }
  return url;
}

String formatShopJobAmount(int amount) {
  return '₩${amount.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      )}';
}

class ShopJobStatusBadge extends StatelessWidget {
  const ShopJobStatusBadge({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case 'published':
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacing2,
            vertical: AppTheme.spacing1,
          ),
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          ),
          child: Text(
            '진행중',
            style: TextStyle(
              color: Colors.green.shade700,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      case 'closed':
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacing2,
            vertical: AppTheme.spacing1,
          ),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          ),
          child: Text(
            '마감',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      case 'draft':
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacing2,
            vertical: AppTheme.spacing1,
          ),
          decoration: BoxDecoration(
            color: Colors.amber.shade100,
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          ),
          child: Text(
            '임시저장',
            style: TextStyle(
              color: Colors.amber.shade700,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      case 'expired':
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacing2,
            vertical: AppTheme.spacing1,
          ),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          ),
          child: Text(
            '지난 공고',
            style: TextStyle(
              color: Colors.blue.shade700,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class ShopJobsListJobCard extends StatelessWidget {
  const ShopJobsListJobCard({
    super.key,
    required this.job,
    required this.applicantCount,
    required this.onTap,
    required this.onHide,
    required this.onUnhide,
    required this.onEdit,
    required this.onClose,
    required this.onReopen,
    required this.onDelete,
    required this.onManageApplicants,
    this.onRepost,
  });

  final Job job;
  final int applicantCount;
  final VoidCallback onTap;
  final VoidCallback onHide;
  final VoidCallback onUnhide;
  final VoidCallback onEdit;
  final VoidCallback onClose;
  final VoidCallback onReopen;
  final VoidCallback onDelete;
  final VoidCallback onManageApplicants;
  final VoidCallback? onRepost;

  bool get _isExpired {
    if (job.status == 'expired') return true;
    if (job.status != 'published') return false;
    try {
      final parts = job.time.split(':');
      if (parts.length < 2) return false;
      final jobStart = DateTime(
        int.parse(job.date.substring(0, 4)),
        int.parse(job.date.substring(5, 7)),
        int.parse(job.date.substring(8, 10)),
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
      return jobStart.isBefore(DateTime.now());
    } catch (_) {
      return false;
    }
  }

  String get _effectiveStatus => _isExpired && job.status == 'published' ? 'expired' : job.status;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (job.images != null && job.images!.isNotEmpty)
            GestureDetector(
              onTap: onTap,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(_proxyImageUrl(job.images!.first)),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  if (job.images!.length > 1)
                    Positioned(
                      top: AppTheme.spacing2,
                      right: AppTheme.spacing2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacing2,
                          vertical: AppTheme.spacing1,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusFull),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.image, size: 12, color: Colors.white),
                            const SizedBox(width: AppTheme.spacing1),
                            Text(
                              '${job.images!.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacing4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: onTap,
                        behavior: HitTestBehavior.opaque,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              job.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: AppTheme.spacing2),
                            Wrap(
                              spacing: AppTheme.spacing1,
                              runSpacing: AppTheme.spacing1,
                              children: [
                                ShopJobStatusBadge(status: _effectiveStatus),
                                if (job.isHidden)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppTheme.spacing2,
                                      vertical: AppTheme.spacing1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.backgroundGray,
                                      borderRadius: BorderRadius.circular(
                                        AppTheme.radiusFull,
                                      ),
                                      border: Border.all(
                                        color: AppTheme.borderGray,
                                      ),
                                    ),
                                    child: const Text(
                                      '숨김',
                                      style: TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                if (job.isUrgent)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppTheme.spacing2,
                                      vertical: AppTheme.spacing1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.urgentRed
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(
                                        AppTheme.radiusFull,
                                      ),
                                    ),
                                    child: const Text(
                                      '급구',
                                      style: TextStyle(
                                        color: AppTheme.urgentRed,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: AppTheme.spacing2),
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                  color: AppTheme.textSecondary,
                                ),
                                const SizedBox(width: AppTheme.spacing1),
                                Expanded(
                                  child: Text(
                                    '${job.date} ${WorkScheduleUtils.formatJobTimeRange(job)}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppTheme.textSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppTheme.spacing1),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  size: 16,
                                  color: AppTheme.textSecondary,
                                ),
                                const SizedBox(width: AppTheme.spacing1),
                                Expanded(
                                  child: Text(
                                    RegionHelper.getRegionName(job.regionId),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppTheme.textSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!_isExpired) ...[
                          if (job.status == 'published' && !job.isHidden)
                            IconButton(
                              icon: const Icon(Icons.visibility_off, size: 20),
                              onPressed: onHide,
                              tooltip: '숨김',
                            ),
                          if (job.isHidden)
                            IconButton(
                              icon: const Icon(Icons.visibility, size: 20),
                              onPressed: onUnhide,
                              tooltip: '숨김 해제',
                            ),
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            onPressed: onEdit,
                            tooltip: '수정',
                          ),
                        ],
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            size: 20,
                            color: AppTheme.urgentRed,
                          ),
                          onPressed: onDelete,
                          tooltip: '삭제',
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacing3),
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacing3),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundGray,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.attach_money,
                                  size: 16,
                                  color: AppTheme.textSecondary,
                                ),
                                SizedBox(width: AppTheme.spacing1),
                                Text(
                                  '금액',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppTheme.spacing1),
                            Text(
                              formatShopJobAmount(job.amount),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: AppTheme.borderGray,
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.people,
                                  size: 16,
                                  color: AppTheme.textSecondary,
                                ),
                                SizedBox(width: AppTheme.spacing1),
                                Text(
                                  '지원자',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppTheme.spacing1),
                            Text(
                              '$applicantCount/${job.requiredCount}명',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.spacing3),
                if (_isExpired) ...[
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onRepost,
                          icon: const Icon(Icons.content_copy, size: 18),
                          label: const Text('복사해서 다시 올리기'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: AppTheme.spacing2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacing2),
                      OutlinedButton(
                        onPressed: onManageApplicants,
                        child: Text('지원자 ($applicantCount)'),
                      ),
                    ],
                  ),
                ] else
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onManageApplicants,
                          icon: const Icon(Icons.people, size: 18),
                          label: Text('지원자 관리 ($applicantCount)'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: AppTheme.spacing2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacing2),
                      if (job.status == 'published')
                        OutlinedButton(
                          onPressed: onClose,
                          child: const Text('마감하기'),
                        ),
                      if (job.status == 'closed')
                        ElevatedButton(
                          onPressed: onReopen,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('재오픈'),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
