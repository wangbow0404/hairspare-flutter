import 'package:flutter/material.dart';

import 'package:hairspare/models/challenge_profile.dart';
import 'package:hairspare/theme/app_theme.dart';
import 'package:hairspare/widgets/challenge/challenge_url_launcher.dart';

/// SNS·외부 링크 (소개 텍스트는 헤더에만 표시).
class ChallengeProfileLinksSection extends StatelessWidget {
  const ChallengeProfileLinksSection({super.key, required this.profile});

  final ChallengeProfile profile;

  @override
  Widget build(BuildContext context) {
    final links = profile.externalLinks ?? const [];
    if (links.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacing4,
        AppTheme.spacing4,
        AppTheme.spacing4,
        AppTheme.spacing2,
      ),
      child: Container(
        width: double.infinity,
        padding: AppTheme.spacing(AppTheme.spacing4),
        decoration: BoxDecoration(
          color: AppTheme.backgroundWhite,
          borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
          border: Border.all(color: AppTheme.borderGray.withValues(alpha: 0.6)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '링크',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
            ),
            const SizedBox(height: AppTheme.spacing2),
            for (var i = 0; i < links.length; i++) ...[
              if (i > 0) const SizedBox(height: AppTheme.spacing2),
              _ExternalLinkTile(link: links[i]),
            ],
          ],
        ),
      ),
    );
  }
}

class _ExternalLinkTile extends StatelessWidget {
  const _ExternalLinkTile({required this.link});

  final ChallengeProfileExternalLink link;

  @override
  Widget build(BuildContext context) {
    final meta = _linkMeta(link.type);
    final title = link.label?.trim().isNotEmpty == true
        ? link.label!
        : meta.title;

    return Material(
      color: AppTheme.backgroundGray,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => launchChallengeExternalUrl(context, link.url),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacing3,
            vertical: AppTheme.spacing3,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: meta.backgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(meta.icon, color: meta.iconColor, size: 22),
              ),
              const SizedBox(width: AppTheme.spacing3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meta.title,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.open_in_new,
                size: 18,
                color: AppTheme.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LinkMeta {
  const _LinkMeta({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
}

_LinkMeta _linkMeta(String type) {
  switch (type.toLowerCase()) {
    case 'instagram':
      return const _LinkMeta(
        title: 'Instagram',
        icon: Icons.camera_alt_outlined,
        iconColor: Color(0xFFE1306C),
        backgroundColor: Color(0xFFFCE7F3),
      );
    case 'youtube':
      return const _LinkMeta(
        title: 'YouTube',
        icon: Icons.play_circle_outline,
        iconColor: Color(0xFFDC2626),
        backgroundColor: Color(0xFFFEE2E2),
      );
    case 'tiktok':
      return const _LinkMeta(
        title: 'TikTok',
        icon: Icons.music_note_outlined,
        iconColor: AppTheme.textPrimary,
        backgroundColor: Color(0xFFF3F4F6),
      );
    case 'blog':
      return const _LinkMeta(
        title: '블로그',
        icon: Icons.article_outlined,
        iconColor: AppTheme.primaryBlue,
        backgroundColor: AppTheme.backgroundGradientStart,
      );
    default:
      return const _LinkMeta(
        title: '웹사이트',
        icon: Icons.language,
        iconColor: AppTheme.primaryPurple,
        backgroundColor: AppTheme.primaryPurpleLight,
      );
  }
}
