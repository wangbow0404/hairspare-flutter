import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/chat_provider.dart';
import '../../theme/app_theme.dart';
import '../common/shared_app_bar.dart';
import '../../utils/icon_mapper.dart';
import '../../view_models/work_check_view_model.dart';
import '../notification_bell.dart';
import '../../utils/app_bar_navigation.dart';

/// 스페어 근무체크 상단 Sliver (로고, 검색, 메시지, 알림).
class WorkCheckSliverAppBar extends StatelessWidget {
  const WorkCheckSliverAppBar({super.key, required this.searchController});

  final TextEditingController searchController;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WorkCheckViewModel>();

    return SliverAppBar(
      pinned: true,
      backgroundColor: AppTheme.backgroundWhite,
      elevation: 0,
      leading: null,
      automaticallyImplyLeading: false,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          color: AppTheme.backgroundWhite,
          border: Border(
            bottom: BorderSide(color: AppTheme.borderGray, width: 1),
          ),
        ),
        padding: AppTheme.spacingSymmetric(
          horizontal: AppTheme.spacing4,
          vertical: AppTheme.spacing3,
        ),
        child: Row(
          children: [
            IconButton(
              icon: IconMapper.icon('chevronleft', size: 24, color: AppTheme.textSecondary) ??
                  const Icon(Icons.arrow_back_ios, size: 20, color: AppTheme.textSecondary),
              onPressed: () => Navigator.maybePop(context),
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            ),
            Text(
              '스케줄표',
              style: SharedAppBar.titleTextStyle(context),
            ),
            const Spacer(),
            if (vm.isSearchOpen) ...[
              Expanded(
                child: TextField(
                  controller: searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: '검색어를 입력하세요',
                    border: OutlineInputBorder(
                      borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                      borderSide: const BorderSide(
                        color: AppTheme.stitchPrimaryContainer,
                        width: 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                      borderSide: const BorderSide(
                        color: AppTheme.stitchPrimaryContainer,
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                      borderSide: const BorderSide(
                        color: AppTheme.stitchPrimaryContainer,
                        width: 2,
                      ),
                    ),
                    contentPadding: AppTheme.spacingSymmetric(
                      horizontal: AppTheme.spacing4,
                      vertical: AppTheme.spacing2,
                    ),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spacing2),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    vm.setSearchOpen(false);
                    searchController.clear();
                  },
                  borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                  child: Container(
                    padding: const EdgeInsets.all(AppTheme.spacing2),
                    child: IconMapper.icon('x', size: 24, color: AppTheme.textSecondary) ??
                        const Icon(Icons.close, size: 24, color: AppTheme.textSecondary),
                  ),
                ),
              ),
            ] else ...[
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => vm.setSearchOpen(true),
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
                            padding: const EdgeInsets.all(AppTheme.spacing2),
                            child: IconMapper.icon('messagecircle', size: 24, color: AppTheme.textSecondary) ??
                                const Icon(Icons.message_outlined, size: 24, color: AppTheme.textSecondary),
                          ),
                        ),
                      ),
                      if (unreadCount > 0)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: AppTheme.urgentRed,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(width: AppTheme.spacing3),
              const NotificationBell(role: 'spare'),
            ],
          ],
        ),
      ),
    );
  }
}
