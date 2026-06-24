import 'package:flutter/material.dart';

import '../../models/spare_profile.dart';
import '../../theme/app_theme.dart';
import '../../theme/home_text_styles.dart';
import 'shop_home_spare_photo.dart';

/// 인기·지역 스페어용 세로 프로필 카드 (원형 사진 + 이름 + 전문 태그).
class ShopHomeSparePortraitCard extends StatelessWidget {
  const ShopHomeSparePortraitCard({
    super.key,
    required this.spare,
    this.onTap,
    this.width = 148,
  });

  final SpareProfile spare;
  final VoidCallback? onTap;
  final double width;

  static const double _avatarSize = 72;

  String get _primarySpecialty {
    if (spare.specialties.isEmpty) {
      return spare.role == 'designer' ? '디자이너' : '스페어';
    }
    return spare.specialties.first;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Material(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusXl),
              border: Border.all(color: AppTheme.borderGray),
              boxShadow: AppTheme.stitchSoftShadow,
            ),
            padding: const EdgeInsets.fromLTRB(
              AppTheme.spacing4,
              AppTheme.spacing5,
              AppTheme.spacing4,
              AppTheme.spacing4,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ShopHomeSparePhoto(
                  spare: spare,
                  width: _avatarSize,
                  height: _avatarSize,
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                const SizedBox(height: AppTheme.spacing3),
                Text(
                  spare.name,
                  style: HomeTextStyles.homeCardTitle.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacing2),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing3,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPurpleLight,
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  ),
                  child: Text(
                    _primarySpecialty,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.stitchTextSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
