import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/app_theme.dart';
import '../../widgets/common/spare_subpage_app_bar.dart';
import '../../widgets/stitch/stitch_empty_state.dart';
import '../../providers/notification_provider.dart';
import '../../models/notification.dart' show AppNotification;
import '../../models/user.dart';
import '../../utils/app_bar_navigation.dart';
import '../../utils/shop_notification_navigation.dart';
import '../../utils/spare_notification_navigation.dart';
import '../../widgets/notifications/spare_notification_tile.dart';

/// 전체 알림 목록 — 확인 필요(상단) / 확인함(하단) 구분.
class NotificationsListScreen extends StatefulWidget {
  const NotificationsListScreen({super.key});

  @override
  State<NotificationsListScreen> createState() => _NotificationsListScreenState();
}

class _NotificationsListScreenState extends State<NotificationsListScreen> {
  String _audience(BuildContext context) =>
      AppBarNavigation.inferAppSectionRole(context) == UserRole.shop
          ? 'shop'
          : 'spare';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Provider.of<NotificationProvider>(context, listen: false)
          .loadNotifications(audience: _audience(context));
    });
  }

  Future<void> _handleNotificationTap(AppNotification notification) async {
    final provider =
        Provider.of<NotificationProvider>(context, listen: false);
    final audience = _audience(context);
    if (!notification.isRead) {
      await provider.markAsRead(notification.id, audience: audience);
    }
    if (!mounted) return;
    if (audience == 'shop') {
      ShopNotificationNavigation.handle(context, notification);
    } else {
      SpareNotificationNavigation.handle(context, notification);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: SpareSubpageAppBar(
        title: '알림',
        showBackButton: Navigator.canPop(context),
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, _) {
          if (notificationProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final unread = notificationProvider.unreadNotifications;
          final read = notificationProvider.readNotifications;

          if (unread.isEmpty && read.isEmpty) {
            return const StitchEmptyState(
              message: '알림이 없습니다',
              iconName: 'bell',
            );
          }

          return ListView(
            padding: AppTheme.spacing(AppTheme.spacing4),
            children: [
              if (unread.isNotEmpty) ...[
                SpareNotificationSectionHeader(
                  label: '확인 필요',
                  count: unread.length,
                ),
                ...unread.map(
                  (n) => Dismissible(
                    key: ValueKey('unread-${n.id}'),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) => notificationProvider.deleteNotification(
                        n.id,
                        audience: _audience(context),
                      ),
                    background: _deleteBackground(),
                    child: SpareNotificationTile(
                      notification: n,
                      onTap: () => _handleNotificationTap(n),
                    ),
                  ),
                ),
              ],
              if (unread.isNotEmpty && read.isNotEmpty) ...[
                const SizedBox(height: AppTheme.spacing2),
                _SectionDivider(),
                const SizedBox(height: AppTheme.spacing2),
              ],
              if (read.isNotEmpty) ...[
                const SpareNotificationSectionHeader(label: '확인함'),
                ...read.map(
                  (n) => Dismissible(
                    key: ValueKey('read-${n.id}'),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) => notificationProvider.deleteNotification(
                        n.id,
                        audience: _audience(context),
                      ),
                    background: _deleteBackground(),
                    child: SpareNotificationTile(
                      notification: n,
                      onTap: () => _handleNotificationTap(n),
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _deleteBackground() {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing3),
      decoration: BoxDecoration(
        color: AppTheme.urgentRed,
        borderRadius: AppTheme.borderRadius(AppTheme.radiusXl),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      child: const Icon(
        Icons.delete_outline,
        color: Colors.white,
        size: 28,
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: AppTheme.borderGray.withValues(alpha: 0.8))),
        Padding(
          padding: AppTheme.spacingSymmetric(
            horizontal: AppTheme.spacing3,
            vertical: 0,
          ),
          child: Text(
            '이전 알림',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textTertiary,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        Expanded(child: Divider(color: AppTheme.borderGray.withValues(alpha: 0.8))),
      ],
    );
  }
}
