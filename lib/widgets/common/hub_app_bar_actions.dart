import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user.dart';
import '../../providers/chat_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_bar_navigation.dart';
import '../../utils/icon_mapper.dart';
import '../notification_bell.dart';

/// 스페어/샵 공통: 검색 · 메시지(뱃지) · 알림(뱃지) 우측 액션.
List<Widget> buildHubAppBarActions(BuildContext context) {
  final role = AppBarNavigation.inferAppSectionRole(context);
  final bellRole = role == UserRole.shop ? 'shop' : 'spare';

  return [
    IconButton(
      tooltip: '검색',
      icon: IconMapper.icon('search', size: 24, color: AppTheme.textSecondary) ??
          const Icon(Icons.search, size: 24, color: AppTheme.textSecondary),
      onPressed: () => AppBarNavigation.pushSearch(context),
    ),
    Consumer<ChatProvider>(
      builder: (context, chatProvider, _) {
        final unreadCount = chatProvider.totalUnreadCount;
        return Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            IconButton(
              tooltip: '메시지',
              icon: IconMapper.icon('messagecircle', size: 24, color: AppTheme.textSecondary) ??
                  const Icon(Icons.message_outlined, size: 24, color: AppTheme.textSecondary),
              onPressed: () => AppBarNavigation.pushMessages(context),
            ),
            if (unreadCount > 0)
              Positioned(
                right: 10,
                top: 10,
                child: IgnorePointer(
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppTheme.urgentRed,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.backgroundWhite, width: 1.5),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    ),
    Padding(
      padding: const EdgeInsets.only(right: AppTheme.spacing2),
      child: NotificationBell(role: bellRole),
    ),
  ];
}
