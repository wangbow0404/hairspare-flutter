import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user.dart';
import '../../providers/chat_provider.dart';
import '../../utils/app_bar_navigation.dart';
import '../../utils/icon_mapper.dart';
import '../notification_bell.dart';

/// 몰입형 챌린지 상단용 — 흰색 라인 아이콘 + [AppBarNavigation].
List<Widget> buildChallengeImmersiveHubActions(BuildContext context) {
  const iconColor = Colors.white;
  final role = AppBarNavigation.inferAppSectionRole(context);
  final bellRole = role == UserRole.shop ? 'shop' : 'spare';

  return [
    IconButton(
      tooltip: '검색',
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      icon: IconMapper.icon('search', size: 22, color: iconColor) ??
          const Icon(Icons.search, size: 22, color: iconColor),
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
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              icon: IconMapper.icon('messagecircle', size: 22, color: iconColor) ??
                  const Icon(Icons.chat_bubble_outline, size: 22, color: iconColor),
              onPressed: () => AppBarNavigation.pushMessages(context),
            ),
            if (unreadCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: IgnorePointer(
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black54, width: 1),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    ),
    Padding(
      padding: const EdgeInsets.only(right: 4),
      child: NotificationBell(
        role: bellRole,
        iconColor: iconColor,
      ),
    ),
  ];
}
