import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/notification.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/spare_subpage_app_bar.dart';

/// 관리자 공지 등 긴 알림 본문 전체 표시.
class NotificationDetailScreen extends StatelessWidget {
  const NotificationDetailScreen({
    super.key,
    required this.notification,
  });

  final AppNotification notification;

  @override
  Widget build(BuildContext context) {
    final sentAt = DateFormat('yyyy.M.d HH:mm', 'ko_KR')
        .format(notification.createdAt);

    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: const SpareSubpageAppBar(
        title: '공지',
        showToolbarActions: false,
      ),
      body: SingleChildScrollView(
        padding: AppTheme.spacing(AppTheme.spacing4),
        child: Container(
          width: double.infinity,
          padding: AppTheme.spacing(AppTheme.spacing5),
          decoration: BoxDecoration(
            color: AppTheme.backgroundWhite,
            borderRadius: AppTheme.borderRadius(AppTheme.radiusXl),
            border: Border.all(color: AppTheme.borderGray),
            boxShadow: AppTheme.stitchSoftShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.stitchPrimaryContainer.withValues(alpha: 0.12),
                  borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                ),
                child: const Icon(
                  Icons.campaign_outlined,
                  size: 26,
                  color: AppTheme.stitchPrimaryContainer,
                ),
              ),
              const SizedBox(height: AppTheme.spacing4),
              Text(
                notification.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                      height: 1.35,
                    ),
              ),
              const SizedBox(height: AppTheme.spacing2),
              Text(
                sentAt,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textTertiary,
                    ),
              ),
              const SizedBox(height: AppTheme.spacing5),
              Text(
                notification.message,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondary,
                      height: 1.6,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
