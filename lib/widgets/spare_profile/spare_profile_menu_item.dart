import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../utils/icon_mapper.dart';

/// 프로필 메뉴 타일 (기존 [_MenuItem] 이전).
class SpareProfileMenuItem extends StatefulWidget {
  const SpareProfileMenuItem({
    super.key,
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  final Widget icon;
  final String label;
  final String description;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  @override
  State<SpareProfileMenuItem> createState() => _SpareProfileMenuItemState();
}

class _SpareProfileMenuItemState extends State<SpareProfileMenuItem> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: AppTheme.spacing(AppTheme.spacing4),
          decoration: BoxDecoration(
            color: AppTheme.backgroundWhite,
            borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
            border: Border.all(
              color: AppTheme.borderGray,
              width: 1,
            ),
            boxShadow: _pressed ? AppTheme.shadowMd : AppTheme.shadowSm,
          ),
          child: Row(
            children: [
              AnimatedScale(
                scale: _pressed ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 150),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: widget.bgColor,
                    borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                  ),
                  child: IconTheme(
                    data: IconThemeData(
                      color: widget.color,
                      size: 20,
                    ),
                    child: widget.icon,
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spacing4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.label,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                    ),
                    const SizedBox(height: AppTheme.spacing1 / 2),
                    Text(
                      widget.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              AnimatedOpacity(
                opacity: _pressed ? 0.6 : 1.0,
                duration: const Duration(milliseconds: 150),
                child: IconMapper.icon('chevronright', size: 20, color: AppTheme.textTertiary) ??
                    const Icon(Icons.chevron_right, size: 20, color: AppTheme.textTertiary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
