import 'package:flutter/material.dart';
import '../models/spare_profile.dart';
import '../theme/app_theme.dart';

class SpareCard extends StatelessWidget {
  final SpareProfile spare;
  final VoidCallback? onTap;
  final bool compact;

  const SpareCard({
    super.key,
    required this.spare,
    this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final padding = compact ? AppTheme.spacing2 : AppTheme.spacing4;
    final avatarSize = compact ? 48.0 : 60.0;
    final avatarFontSize = compact ? 18.0 : 24.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: AppTheme.backgroundWhite,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: AppTheme.borderGray),
          boxShadow: AppTheme.shadowSm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 프로필 이미지
            Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryBlue,
                    AppTheme.primaryPurple,
                  ],
                ),
              ),
              child: spare.profileImage != null
                  ? ClipOval(
                      child: Image.network(
                        spare.profileImage!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Text(
                              spare.name.isNotEmpty ? spare.name[0] : '?',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: avatarFontSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : Center(
                      child: Text(
                        spare.name.isNotEmpty ? spare.name[0] : '?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: avatarFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ),
            SizedBox(width: compact ? AppTheme.spacing2 : AppTheme.spacing4),
            // 정보 영역
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          spare.name,
                          style: (compact
                                  ? Theme.of(context).textTheme.titleSmall
                                  : Theme.of(context).textTheme.titleMedium)
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (spare.isLicenseVerified)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: compact ? AppTheme.spacing1 : AppTheme.spacing2,
                            vertical: AppTheme.spacing1,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.purple100,
                            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                          ),
                          child: Text(
                            '면허인증',
                            style: (Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppTheme.purple700,
                                  fontWeight: FontWeight.w500,
                                  fontSize: compact ? 10 : null,
                                )),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: compact ? AppTheme.spacing1 : AppTheme.spacing2),
                  Text(
                    '경력 ${spare.experience}년 • 완료 ${spare.completedJobs}건',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                          fontSize: compact ? 11 : null,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (spare.specialties.isNotEmpty) ...[
                    SizedBox(height: compact ? AppTheme.spacing1 : AppTheme.spacing2),
                    Wrap(
                      spacing: AppTheme.spacing1,
                      runSpacing: AppTheme.spacing1,
                      children: spare.specialties
                          .take(compact ? 2 : 3)
                          .map((specialty) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: compact ? AppTheme.spacing1 : AppTheme.spacing2,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.purple100,
                            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                          ),
                          child: Text(
                            specialty,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppTheme.purple700,
                                  fontWeight: FontWeight.w500,
                                  fontSize: compact ? 10 : null,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  if (!compact) ...[
                    SizedBox(height: AppTheme.spacing2),
                    Row(
                      children: [
                        const Icon(
                          Icons.thumb_up,
                          size: 14,
                          color: AppTheme.primaryPurple,
                        ),
                        SizedBox(width: AppTheme.spacing1),
                        Text(
                          '따봉 ${spare.thumbsUpCount}개',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.primaryPurple,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        SizedBox(width: AppTheme.spacing2),
                        Text(
                          '•',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                        SizedBox(width: AppTheme.spacing2),
                        Text(
                          '리뷰 ${spare.reviewCount}개',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                        ),
                        if (spare.isVerified) ...[
                          SizedBox(width: AppTheme.spacing2),
                          Text(
                            '•',
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                          SizedBox(width: AppTheme.spacing2),
                          Text(
                            '본인인증',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.primaryBlue,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ] else ...[
                    SizedBox(height: AppTheme.spacing1),
                    Row(
                      children: [
                        Icon(Icons.thumb_up, size: 12, color: AppTheme.primaryPurple),
                        SizedBox(width: 4),
                        Text(
                          '따봉 ${spare.thumbsUpCount}',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppTheme.primaryPurple,
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
