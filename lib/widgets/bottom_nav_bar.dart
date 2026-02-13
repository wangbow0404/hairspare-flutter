import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/icon_mapper.dart';

/// Next.js와 동일한 하단 네비게이션 바
class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        border: Border(
          top: BorderSide(
            color: AppTheme.borderGray, // border-gray-200
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Container(
          padding: AppTheme.spacingSymmetric(
            horizontal: AppTheme.spacing4, // px-4
            vertical: AppTheme.spacing3, // py-3
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: IconMapper.icon('home') ?? const Icon(Icons.home),
                label: '홈',
                isActive: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: IconMapper.icon('creditcard') ?? const Icon(Icons.credit_card),
                label: '결제',
                isActive: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              _NavItem(
                icon: IconMapper.icon('heart') ?? const Icon(Icons.favorite_border),
                label: '찜',
                isActive: currentIndex == 2,
                onTap: () => onTap(2),
              ),
              _NavItem(
                icon: IconMapper.icon('user') ?? const Icon(Icons.person),
                label: '마이',
                isActive: currentIndex == 3,
                onTap: () => onTap(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final Widget icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: AppTheme.spacing(AppTheme.spacing1), // gap-1
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 아이콘 크기 조정 (w-6 h-6)
                SizedBox(
                  width: 24,
                  height: 24,
                  child: IconTheme(
                    data: IconThemeData(
                      color: isActive
                          ? AppTheme.primaryBlue // text-blue-500
                          : AppTheme.textTertiary, // text-gray-400
                      size: 24,
                    ),
                    child: icon,
                  ),
                ),
                SizedBox(height: AppTheme.spacing1), // gap-1
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize: 12, // text-xs
                    color: isActive
                        ? AppTheme.primaryBlue // text-blue-500
                        : AppTheme.textTertiary, // text-gray-400
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

