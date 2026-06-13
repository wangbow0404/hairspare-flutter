import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/chat_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_bar_navigation.dart';
import '../../utils/icon_mapper.dart';
import '../../widgets/notification_bell.dart';

/// 스페어 홈 상단 로고·검색·메시지·알림 (primaryBlue 로고).
class SpareHomeAppBarRow extends StatelessWidget {
  const SpareHomeAppBarRow({super.key, required this.scrollController});

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            if (scrollController.hasClients) {
              scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          },
          child: Text(
            'HairSpare',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                ),
          ),
        ),
        const Spacer(),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => AppBarNavigation.pushSearch(context),
            borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
            child: Container(
              padding: const EdgeInsets.all(AppTheme.spacing2),
              child: IconMapper.icon('search', size: 24, color: AppTheme.textSecondary) ??
                  const Icon(Icons.search, size: 24, color: AppTheme.textSecondary),
            ),
          ),
        ),
        const SizedBox(width: AppTheme.spacing3),
        Consumer<ChatProvider>(
          builder: (context, chatProvider, _) {
            final unreadCount = chatProvider.totalUnreadCount;
            return Stack(
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => AppBarNavigation.pushMessages(context),
                    borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                    child: Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      child: IconMapper.icon('messagecircle', size: 24, color: AppTheme.textSecondary) ??
                          const Icon(Icons.message_outlined, size: 24, color: AppTheme.textSecondary),
                    ),
                  ),
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: IgnorePointer(
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: AppTheme.urgentRed, shape: BoxShape.circle),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          unreadCount > 99 ? '99+' : '$unreadCount',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(width: AppTheme.spacing3),
        const SizedBox(
          width: 40,
          height: 40,
          child: Center(
            child: NotificationBell(role: 'spare'),
          ),
        ),
      ],
    );
  }
}
