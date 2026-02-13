import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// 공고 필터 드롭다운 메뉴 위젯
class JobFilterDropdown extends StatelessWidget {
  final String label;
  final List<String> options;
  final String? selectedValue;
  final Function(String?) onSelected;
  final GlobalKey buttonKey;
  final bool isOpen;
  final VoidCallback onToggle;

  const JobFilterDropdown({
    super.key,
    required this.label,
    required this.options,
    this.selectedValue,
    required this.onSelected,
    required this.buttonKey,
    required this.isOpen,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: buttonKey,
      onTap: () {
        if (isOpen) {
          onToggle();
        } else {
          onToggle();
          _showDropdown(context);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppTheme.spacing3,
          vertical: AppTheme.spacing2,
        ),
        decoration: BoxDecoration(
          color: AppTheme.backgroundWhite,
          border: Border.all(color: AppTheme.borderGray),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selectedValue ?? label,
              style: TextStyle(
                color: selectedValue != null
                    ? AppTheme.textPrimary
                    : AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
            SizedBox(width: AppTheme.spacing2),
            Icon(
              isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              size: 20,
              color: AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  void _showDropdown(BuildContext context) {
    final RenderBox? buttonBox = buttonKey.currentContext?.findRenderObject() as RenderBox?;
    if (buttonBox == null) return;

    final buttonPosition = buttonBox.localToGlobal(Offset.zero);
    final buttonSize = buttonBox.size;
    final screenHeight = MediaQuery.of(context).size.height;
    final availableHeight = screenHeight - buttonPosition.dy - buttonSize.height - 4;
    
    // 최대 높이 설정 (화면의 60% 또는 400px 중 작은 값)
    final maxHeight = availableHeight > 400 ? 400.0 : availableHeight;

    showMenu<String?>(
      context: context,
      position: RelativeRect.fromLTRB(
        buttonPosition.dx,
        buttonPosition.dy + buttonSize.height + 4,
        MediaQuery.of(context).size.width - buttonPosition.dx - buttonSize.width,
        MediaQuery.of(context).size.height - buttonPosition.dy - buttonSize.height - 4,
      ),
      constraints: BoxConstraints(
        maxHeight: maxHeight,
        minWidth: buttonSize.width,
      ),
      items: <PopupMenuEntry<String?>>[
        // 전체 선택 옵션
        PopupMenuItem<String?>(
          height: 48,
          child: Text(
            '전체',
            style: TextStyle(
              color: selectedValue == null
                  ? AppTheme.primaryBlue
                  : AppTheme.textPrimary,
              fontWeight: selectedValue == null ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          onTap: () {
            Future.microtask(() {
              onSelected(null);
              onToggle();
            });
          },
        ),
        const PopupMenuDivider(),
        // 옵션 리스트 (스크롤 가능)
        ...options.map<PopupMenuItem<String?>>((option) {
          final isSelected = selectedValue == option;
          return PopupMenuItem<String?>(
            height: 48,
            value: option,
            child: Text(
              option,
              style: TextStyle(
                color: isSelected
                    ? AppTheme.primaryBlue
                    : AppTheme.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            onTap: () {
              Future.microtask(() {
                onSelected(option);
                onToggle();
              });
            },
          );
        }),
      ],
    ).then((_) {
      if (isOpen) {
        onToggle();
      }
    });
  }
}
