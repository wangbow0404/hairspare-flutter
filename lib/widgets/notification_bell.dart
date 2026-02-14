import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/notification.dart' show AppNotification;
import '../theme/app_theme.dart';
import '../providers/notification_provider.dart';
import '../utils/navigation_helper.dart';

class NotificationBell extends StatefulWidget {
  final String role; // 'spare' | 'shop'
  final Function(AppNotification)? onNotificationTap;

  const NotificationBell({
    super.key,
    required this.role,
    this.onNotificationTap,
  });

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  bool _showNotifications = false;
  final GlobalKey _bellKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _hideOverlay();
    super.dispose();
  }

  void _toggleNotifications() {
    if (_showNotifications) {
      _hideOverlay();
    } else {
      _showOverlay();
    }
    setState(() {
      _showNotifications = !_showNotifications;
    });
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showOverlay() {
    _overlayEntry?.remove();
    final overlay = Overlay.of(context);
    final box = _bellKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;

    final position = box.localToGlobal(Offset.zero);
    final size = box.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // 배경 터치 시 닫기
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                _hideOverlay();
                if (mounted) setState(() => _showNotifications = false);
              },
            ),
          ),
          Positioned(
            top: position.dy + size.height + 4,
            right: MediaQuery.of(context).size.width - position.dx - size.width,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              child: _buildNotificationPanel(context, true),
            ),
          ),
        ],
      ),
    );
    overlay.insert(_overlayEntry!);
  }

  Widget _buildNotificationPanel(BuildContext context, bool inOverlay) {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, _) {
        final notifications = notificationProvider.notifications;
        final unreadCount = notificationProvider.unreadCount;

        return Container(
          width: 300,
          constraints: const BoxConstraints(maxHeight: 400),
          decoration: BoxDecoration(
            color: AppTheme.backgroundWhite,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(color: AppTheme.borderGray),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing3,
                  vertical: AppTheme.spacing2,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppTheme.borderGray),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '알림',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (unreadCount > 0)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppTheme.spacing2,
                          vertical: AppTheme.spacing1,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.urgentRed,
                          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                        ),
                        child: Text(
                          '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Flexible(
                child: notificationProvider.isLoading
                    ? Padding(
                        padding: EdgeInsets.all(AppTheme.spacing8),
                        child: const Center(child: CircularProgressIndicator()),
                      )
                    : notifications.isEmpty
                        ? Padding(
                            padding: EdgeInsets.all(AppTheme.spacing8),
                            child: Text(
                              '알림이 없습니다',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: notifications.length,
                            itemBuilder: (context, index) {
                              final notification = notifications[index];
                              return Dismissible(
                                key: ValueKey(notification.id),
                                direction: DismissDirection.horizontal,
                                onDismissed: (_) {
                                  Provider.of<NotificationProvider>(
                                    context,
                                    listen: false,
                                  ).deleteNotification(notification.id);
                                },
                                background: Container(
                                  color: AppTheme.urgentRed,
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 16),
                                  child: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                child: ListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: AppTheme.spacing3,
                                    vertical: 2,
                                  ),
                                  title: Text(
                                    notification.title,
                                    style: TextStyle(
                                      fontWeight: notification.isRead
                                          ? FontWeight.normal
                                          : FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    notification.message,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
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
                                  onTap: () {
                                    _handleNotificationTap(notification);
                                    if (inOverlay) _hideOverlay();
                                    if (mounted) setState(() => _showNotifications = false);
                                  },
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleNotificationTap(AppNotification notification) {
    // 알림 읽음 처리
    Provider.of<NotificationProvider>(context, listen: false)
        .markAsRead(notification.id);

    // 알림 타입에 따라 화면 이동
    if (widget.onNotificationTap != null) {
      widget.onNotificationTap!(notification);
    } else {
      _navigateFromNotification(notification);
    }

    // 알림 패널 닫기
    setState(() {
      _showNotifications = false;
    });
  }

  void _navigateFromNotification(AppNotification notification) {
    final context = this.context;
    if (!mounted) return;

    switch (notification.type) {
      case 'application_received':
      case 'application_accepted':
      case 'application_rejected':
      case 'job_posted':
      case 'job':
        // 공고 관련 알림 (job: 새 공고 등록)
        if (notification.relatedJobId != null) {
          NavigationHelper.navigateToJobDetail(context, notification.relatedJobId!);
        }
        break;
      case 'schedule_reminder':
      case 'schedule_confirmed':
      case 'schedule_cancelled':
        // 스케줄 관련 알림
        NavigationHelper.navigateToSchedule(context);
        break;
      case 'message_received':
        // 메시지 관련 알림 - 일단 메시지 목록으로 이동
        // TODO: relatedUserId로 채팅방을 찾아서 이동하는 로직 추가 필요
        NavigationHelper.navigateToMessages(context);
        break;
      default:
        // 기본적으로 알림 화면으로 이동하거나 아무 동작 안 함
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, _) {
        final notifications = notificationProvider.notifications;
        final unreadCount = notificationProvider.unreadCount;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Material(
              key: _bellKey,
              color: Colors.transparent,
              child: InkWell(
                onTap: _toggleNotifications,
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                child: Container(
                  padding: EdgeInsets.all(AppTheme.spacing2),
                  child: const Icon(
                    Icons.notifications_outlined,
                    size: 24,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
            if (unreadCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: AppTheme.urgentRed,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
