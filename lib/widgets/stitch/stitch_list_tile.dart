import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../utils/icon_mapper.dart';

/// 메시지·알림·프로필 메뉴 공통 리스트 타일.
class StitchListTile extends StatelessWidget {
  const StitchListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.leadingIconName,
    this.leadingWidget,
    this.trailing,
    this.badge,
    this.onTap,
    this.showChevron = true,
  });

  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final String? leadingIconName;
  final Widget? leadingWidget;
  final Widget? trailing;
  final String? badge;
  final VoidCallback? onTap;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.backgroundWhite,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacing4,
            vertical: AppTheme.spacing3,
          ),
          child: Row(
            children: [
              if (leadingWidget != null)
                leadingWidget!
              else
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPurpleLight,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  ),
                  child: Center(
                    child: leadingIconName != null
                        ? IconMapper.icon(
                              leadingIconName!,
                              size: 22,
                              color: AppTheme.stitchPrimary,
                            ) ??
                            Icon(
                              leadingIcon ?? Icons.circle_outlined,
                              size: 22,
                              color: AppTheme.stitchPrimary,
                            )
                        : Icon(
                            leadingIcon ?? Icons.circle_outlined,
                            size: 22,
                            color: AppTheme.stitchPrimary,
                          ),
                  ),
                ),
              const SizedBox(width: AppTheme.spacing3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.stitchTextPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.stitchTextSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (badge != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing2,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.urgentRed,
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacing2),
              ],
              trailing ??
                  (showChevron && onTap != null
                      ? IconMapper.icon(
                            'chevronright',
                            size: 20,
                            color: AppTheme.outline,
                          ) ??
                          const Icon(
                            Icons.chevron_right,
                            size: 20,
                            color: AppTheme.outline,
                          )
                      : const SizedBox.shrink()),
            ],
          ),
        ),
      ),
    );
  }
}
