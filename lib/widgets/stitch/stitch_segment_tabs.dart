import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// 전체/안읽음 등 세그먼트 탭 — Stitch 보라 accent.
class StitchSegmentTabs extends StatelessWidget {
  const StitchSegmentTabs({
    super.key,
    required this.tabs,
    required this.activeIndex,
    required this.onChanged,
  });

  final List<String> tabs;
  final int activeIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.backgroundWhite,
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isActive = index == activeIndex;
          return Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onChanged(index),
                child: Container(
                  padding: AppTheme.spacing(AppTheme.spacing4),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isActive
                            ? AppTheme.stitchPrimaryContainer
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Text(
                    tabs[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive
                          ? AppTheme.stitchPrimary
                          : AppTheme.stitchTextSecondary,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
