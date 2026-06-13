import 'package:flutter/material.dart';

import 'package:hairspare/models/challenge_profile.dart';
import 'package:hairspare/theme/app_theme.dart';
import 'package:hairspare/utils/icon_mapper.dart';

/// 배너 + 겹침 아바타 + 닉네임·태그·공개 배지.
class ChallengeProfileHeader extends StatelessWidget {
  const ChallengeProfileHeader({
    super.key,
    required this.profile,
    required this.showEditButton,
    required this.onEdit,
  });

  final ChallengeProfile profile;
  final bool showEditButton;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final tags = profile.specialtyTags ?? const <String>[];

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 128,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFE9D5FF),
                    Color(0xFFDBEAFE),
                    Color(0xFFFCE7F3),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: -44,
              child: Center(
                child: _ProfileAvatar(imageUrl: profile.challengeProfileImage),
              ),
            ),
          ],
        ),
        const SizedBox(height: 52),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing4),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      profile.challengeNickname ?? '닉네임 없음',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (!profile.isPublic) ...[
                    const SizedBox(width: 8),
                    const _VisibilityBadge(isPublic: false),
                  ],
                ],
              ),
              if (tags.isNotEmpty) ...[
                const SizedBox(height: AppTheme.spacing2),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  alignment: WrapAlignment.center,
                  children: [
                    for (final tag in tags)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryPurpleLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '#$tag',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryPurple,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: AppTheme.spacing2),
              Text(
                profile.challengeBio ?? '',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      height: 1.45,
                      color: AppTheme.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
              if (showEditButton) ...[
                const SizedBox(height: AppTheme.spacing4),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: onEdit,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryPurple,
                      side: const BorderSide(color: AppTheme.primaryPurple),
                      padding: AppTheme.spacingSymmetric(
                        horizontal: AppTheme.spacing4,
                        vertical: AppTheme.spacing3,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                      ),
                    ),
                    child: const Text(
                      '프로필 편집',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spacing3),
      ],
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: AppTheme.shadowLg,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryPurple, AppTheme.primaryBlue],
        ),
      ),
      child: ClipOval(
        child: imageUrl != null
            ? Image.network(imageUrl!, fit: BoxFit.cover)
            : Center(
                child: IconMapper.icon('user', size: 48, color: Colors.white) ??
                    const Icon(Icons.person, size: 48, color: Colors.white),
              ),
      ),
    );
  }
}

class _VisibilityBadge extends StatelessWidget {
  const _VisibilityBadge({required this.isPublic});

  final bool isPublic;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.backgroundGray,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isPublic ? '공개' : '비공개',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }
}
