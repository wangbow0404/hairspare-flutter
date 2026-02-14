import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../widgets/spare_app_bar.dart';
import '../../providers/notification_provider.dart';
import '../../models/notification.dart' show AppNotification;
import '../../utils/navigation_helper.dart';

/// 전체 알림 목록 화면
class NotificationsListScreen extends StatefulWidget {
  const NotificationsListScreen({super.key});

  @override
  State<NotificationsListScreen> createState() => _NotificationsListScreenState();
}

class _NotificationsListScreenState extends State<NotificationsListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationProvider>(context, listen: false).loadNotifications();
    });
  }

  void _handleNotificationTap(AppNotification notification) {
    Provider.of<NotificationProvider>(context, listen: false)
        .markAsRead(notification.id);

    switch (notification.type) {
      case 'application_received':
      case 'application_accepted':
      case 'application_rejected':
      case 'job_posted':
      case 'job':
        if (notification.relatedJobId != null) {
          NavigationHelper.navigateToJobDetail(context, notification.relatedJobId!);
        }
        break;
      case 'schedule_reminder':
      case 'schedule_confirmed':
      case 'schedule_cancelled':
        NavigationHelper.navigateToSchedule(context);
        break;
      case 'message_received':
        NavigationHelper.navigateToMessages(context);
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: const SpareAppBar(showBackButton: true),
      body: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, _) {
          if (notificationProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = notificationProvider.notifications;

          if (notifications.isEmpty) {
            return Center(
              child: Text(
                '알림이 없습니다',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            padding: AppTheme.spacing(AppTheme.spacing4),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return Dismissible(
                key: ValueKey(notification.id),
                direction: DismissDirection.endToStart,
                onDismissed: (_) {
                  Provider.of<NotificationProvider>(context, listen: false)
                      .deleteNotification(notification.id);
                },
                background: Container(
                  color: AppTheme.urgentRed,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                child: Container(
                  margin: EdgeInsets.only(bottom: AppTheme.spacing3),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundWhite,
                    borderRadius: AppTheme.borderRadius(AppTheme.radiusXl),
                    border: Border.all(color: AppTheme.borderGray),
                  ),
                  child: ListTile(
                    contentPadding: AppTheme.spacingSymmetric(
                      horizontal: AppTheme.spacing4,
                      vertical: AppTheme.spacing3,
                    ),
                    title: Text(
                      notification.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: notification.isRead
                                ? FontWeight.normal
                                : FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: AppTheme.spacing2),
                        Text(
                          notification.message,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.textSecondary,
                                height: 1.4,
                              ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: AppTheme.spacing2),
                        Text(
                          DateFormat('yyyy.M.d HH:mm', 'ko_KR')
                              .format(notification.createdAt),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textTertiary,
                                fontSize: 12,
                              ),
                        ),
                      ],
                    ),
                    trailing: notification.isRead
                        ? null
                        : Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryBlue,
                              shape: BoxShape.circle,
                            ),
                          ),
                    onTap: () => _handleNotificationTap(notification),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
