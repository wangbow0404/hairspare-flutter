import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// 관리자 검색 + 필터 탭 바
class AdminSearchFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final String? searchHint;
  final List<String> filterTabs;
  final String? selectedTab;
  final ValueChanged<String>? onTabChanged;
  final ValueChanged<String>? onSearchChanged;
  final Widget? filterDropdown;

  const AdminSearchFilterBar({
    super.key,
    required this.searchController,
    this.searchHint,
    this.filterTabs = const [],
    this.selectedTab,
    this.onTabChanged,
    this.onSearchChanged,
    this.filterDropdown,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacing6),
      decoration: AppTheme.adminCardDecoration,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  onChanged: onSearchChanged,
                  decoration: InputDecoration(
                    hintText: searchHint ?? '이름, 이메일, 전화번호로 검색...',
                    prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary),
                    filled: true,
                    fillColor: Colors.transparent,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radius2xl),
                      borderSide: BorderSide(color: AppTheme.adminPurple100, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radius2xl),
                      borderSide: BorderSide(color: AppTheme.adminPurple100, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radius2xl),
                      borderSide: const BorderSide(
                        color: AppTheme.primaryPurple,
                        width: 2,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing4,
                      vertical: AppTheme.spacing3,
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              if (filterDropdown != null) ...[
                SizedBox(width: AppTheme.spacing4),
                filterDropdown!,
              ],
            ],
          ),
          if (filterTabs.isNotEmpty) ...[
            SizedBox(height: AppTheme.spacing4),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: filterTabs.map((tab) {
                  final isSelected = selectedTab == tab;
                  return Padding(
                    padding: EdgeInsets.only(right: AppTheme.spacing2),
                    child: GestureDetector(
                      onTap: () => onTabChanged?.call(tab),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppTheme.spacing4,
                          vertical: AppTheme.spacing2 + 2,
                        ),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? const LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    AppTheme.primaryPurple500,
                                    AppTheme.primaryPink,
                                  ],
                                )
                              : null,
                          color: isSelected ? null : Colors.white,
                          border: Border.all(
                            color: AppTheme.adminPurple100,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                          boxShadow: isSelected ? AppTheme.shadowLg : null,
                        ),
                        child: Text(
                          tab,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : AppTheme.textGray700,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
