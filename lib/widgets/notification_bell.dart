import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/notification.dart' show AppNotification;
import '../providers/notification_provider.dart';
import '../theme/app_theme.dart';
import '../utils/navigation_helper.dart';
import '../utils/model_notification_navigation.dart';
import '../utils/shop_notification_navigation.dart';
import '../utils/spare_notification_navigation.dart';

class NotificationBell extends StatefulWidget {
  final String role; // 'spare' | 'shop' | 'model'
  final Function(AppNotification)? onNotificationTap;
  /// null이면 [AppTheme.textSecondary].
  final Color? iconColor;

  const NotificationBell({
    super.key,
    required this.role,
    this.onNotificationTap,
    this.iconColor,
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
    if (!_showNotifications) {
      Provider.of<NotificationProvider>(context, listen: false)
          .loadNotifications(audience: widget.role);
    }
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
        final notifications = notificationProvider.unreadNotifications;
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
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing3,
                  vertical: AppTheme.spacing2,
                ),
                decoration: const BoxDecoration(
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
                        padding: const EdgeInsets.symmetric(
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
                    ? const Padding(
                        padding: EdgeInsets.all(AppTheme.spacing8),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : notifications.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(AppTheme.spacing8),
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
                                  ).deleteNotification(
                                    notification.id,
                                    audience: widget.role,
                                  );
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
                                  contentPadding: const EdgeInsets.symmetric(
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
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (!notification.isRead)
                                        Container(
                                          width: 8,
                                          height: 8,
                                          margin: const EdgeInsets.only(
                                            right: AppTheme.spacing2,
                                          ),
                                          decoration: const BoxDecoration(
                                            color: AppTheme.primaryBlue,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      InkWell(
                                        borderRadius: AppTheme.borderRadius(
                                          AppTheme.radiusFull,
                                        ),
                                        onTap: () {
                                          Provider.of<NotificationProvider>(
                                            context,
                                            listen: false,
                                          ).deleteNotification(
                                            notification.id,
                                            audience: widget.role,
                                          );
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.all(4),
                                          child: Icon(
                                            Icons.close,
                                            size: 16,
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ],
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
              if (inOverlay)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing3,
                    vertical: AppTheme.spacing2,
                  ),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: AppTheme.borderGray),
                    ),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        _hideOverlay();
                        if (mounted) setState(() => _showNotifications = false);
                        NavigationHelper.navigateToNotificationsList(context);
                      },
                      child: const Text(
                        '전체 보기',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ),
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
        .markAsRead(notification.id, audience: widget.role);

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
    if (widget.role == 'shop') {
      ShopNotificationNavigation.handle(context, notification);
    } else if (widget.role == 'model') {
      ModelNotificationNavigation.handle(context, notification);
    } else {
      SpareNotificationNavigation.handle(context, notification);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, _) {
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
                  padding: const EdgeInsets.all(AppTheme.spacing2),
                  child: Icon(
                    Icons.notifications_outlined,
                    size: 24,
                    color: widget.iconColor ?? AppTheme.textSecondary,
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
