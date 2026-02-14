import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../utils/icon_mapper.dart';
import '../utils/navigation_helper.dart';
import '../providers/chat_provider.dart';
import '../widgets/notification_bell.dart';
import '../screens/spare/messages_screen.dart';

/// 스케줄/출근체크 페이지와 동일한 고정 상단 네비게이션바
/// [showBackButton] true면 좌측에 뒤로가기, false면 로고 (홈 이동)
/// 뒤로가기: 상세페이지용 / 로고: 목록·메인 페이지용
class SpareAppBar extends StatefulWidget implements PreferredSizeWidget {
  /// 검색 기능 표시 여부 (기본 true)
  final bool showSearch;
  /// 상세페이지 등에서 좌측에 뒤로가기 버튼 표시 (기본 false)
  final bool showBackButton;
  /// 우측에 표시할 커스텀 액션 위젯 (예: 공유 버튼)
  final List<Widget>? actions;

  const SpareAppBar({
    super.key,
    this.showSearch = true,
    this.showBackButton = false,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<SpareAppBar> createState() => _SpareAppBarState();
}

class _SpareAppBarState extends State<SpareAppBar> {
  bool _isSearchOpen = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.borderGray,
            width: 1,
          ),
        ),
      ),
      padding: AppTheme.spacingSymmetric(
        horizontal: AppTheme.spacing4,
        vertical: AppTheme.spacing3,
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            if (widget.showBackButton)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                  child: Container(
                    padding: EdgeInsets.all(AppTheme.spacing2),
                    child: IconMapper.icon('chevronleft', size: 24, color: AppTheme.textSecondary) ??
                        const Icon(Icons.arrow_back_ios, size: 24, color: AppTheme.textSecondary),
                  ),
                ),
              )
            else
              GestureDetector(
                onTap: () {
                  NavigationHelper.navigateToHomeFromLogo(context);
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
            if (widget.actions != null && widget.actions!.isNotEmpty) ...[
              ...widget.actions!,
              SizedBox(width: AppTheme.spacing2),
            ],
            if (widget.showSearch && _isSearchOpen) ...[
              Expanded(
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: '검색어를 입력하세요',
                    border: OutlineInputBorder(
                      borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                      borderSide: const BorderSide(
                        color: AppTheme.primaryBlue,
                        width: 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                      borderSide: const BorderSide(
                        color: AppTheme.primaryBlue,
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                      borderSide: const BorderSide(
                        color: AppTheme.primaryBlue,
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
              SizedBox(width: AppTheme.spacing2),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _isSearchOpen = false;
                      _searchController.clear();
                    });
                  },
                  borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                  child: Container(
                    padding: EdgeInsets.all(AppTheme.spacing2),
                    child: IconMapper.icon('x', size: 24, color: AppTheme.textSecondary) ??
                        const Icon(Icons.close, size: 24, color: AppTheme.textSecondary),
                  ),
                ),
              ),
            ] else ...[
              if (widget.showSearch)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      setState(() => _isSearchOpen = true);
                    },
                    borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                    child: Container(
                      padding: EdgeInsets.all(AppTheme.spacing2),
                      child: IconMapper.icon('search', size: 24, color: AppTheme.textSecondary) ??
                          const Icon(Icons.search, size: 24, color: AppTheme.textSecondary),
                    ),
                  ),
                ),
              if (widget.showSearch) SizedBox(width: AppTheme.spacing3),
              Consumer<ChatProvider>(
                builder: (context, chatProvider, _) {
                  final unreadCount = chatProvider.totalUnreadCount;
                  return Stack(
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const MessagesScreen()),
                            );
                          },
                          borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                          child: Container(
                            padding: EdgeInsets.all(AppTheme.spacing2),
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
              SizedBox(width: AppTheme.spacing3),
              NotificationBell(role: 'spare'),
            ],
          ],
        ),
      ),
    );
  }
}
