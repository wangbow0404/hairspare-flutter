import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../utils/icon_mapper.dart';
import '../common/hairspare_brand_assets.dart';

/// 구인 상세 상단 바 (뒤로, 로고, 공유).
class JobDetailHeader extends StatelessWidget {
  const JobDetailHeader({
    super.key,
    required this.onBack,
    this.onShare,
    this.trailing,
  });

  final VoidCallback onBack;
  final Future<void> Function()? onShare;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.borderGray.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      padding: AppTheme.spacingSymmetric(
        horizontal: AppTheme.spacing4,
        vertical: AppTheme.spacing4,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon:
                IconMapper.icon(
                  'chevronleft',
                  size: 24,
                  color: AppTheme.textGray700,
                ) ??
                const Icon(Icons.arrow_back_ios, color: AppTheme.textGray700),
            onPressed: onBack,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const HairSpareBrandLogo(height: 32),
          trailing ??
              IconButton(
                icon:
                    IconMapper.icon(
                      'share2',
                      size: 20,
                      color: AppTheme.textGray700,
                    ) ??
                    const Icon(Icons.share, color: AppTheme.textGray700),
                onPressed: onShare == null ? null : () => onShare!(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
        ],
      ),
    );
  }
}
