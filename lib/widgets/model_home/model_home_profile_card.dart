import 'package:flutter/material.dart';

import '../../models/model_home_data.dart';
import '../../theme/app_theme.dart';
import '../common/app_network_image.dart';

/// 모델 홈 히어로 — 내 프로필 카드.
class ModelHomeProfileCard extends StatefulWidget {
  const ModelHomeProfileCard({
    super.key,
    required this.profile,
    this.onMatchingVisibilityChanged,
  });

  final ModelHomeProfileSummary profile;
  final ValueChanged<bool>? onMatchingVisibilityChanged;

  @override
  State<ModelHomeProfileCard> createState() => _ModelHomeProfileCardState();
}

class _ModelHomeProfileCardState extends State<ModelHomeProfileCard> {
  late bool _matchingVisible;

  @override
  void initState() {
    super.initState();
    _matchingVisible = widget.profile.matchingVisible;
  }

  @override
  void didUpdateWidget(covariant ModelHomeProfileCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile.matchingVisible != widget.profile.matchingVisible) {
      _matchingVisible = widget.profile.matchingVisible;
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    final percentLabel = '${(profile.completionPercent * 100).round()}%';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing4),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppTheme.backgroundWhite,
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          border: Border.all(
            color: AppTheme.stitchPrimaryContainer.withValues(alpha: 0.1),
          ),
          boxShadow: AppTheme.stitchSoftShadow,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.stitchPrimaryContainer,
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: profile.photoUrl != null
                          ? AppNetworkImage(
                              imageUrl: profile.photoUrl,
                              fit: BoxFit.cover,
                              memCacheWidth: 160,
                              fallbackIcon: Icons.person_outline_rounded,
                            )
                          : const _ProfilePlaceholder(),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacing4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    profile.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.stitchTextPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${profile.regionLabel} • ${profile.hairLength}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppTheme.stitchTextSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  '매칭 노출',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.stitchTextSecondary,
                                  ),
                                ),
                                Switch(
                                  value: _matchingVisible,
                                  onChanged: (v) {
                                    setState(() => _matchingVisible = v);
                                    widget.onMatchingVisibilityChanged?.call(v);
                                  },
                                  activeThumbColor: AppTheme.backgroundWhite,
                                  activeTrackColor:
                                      AppTheme.stitchPrimaryContainer,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.spacing2),
                        Text(
                          profile.intro,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.stitchTextPrimary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacing4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '프로필 완성도',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.stitchTextSecondary,
                    ),
                  ),
                  Text(
                    percentLabel,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.stitchPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacing1),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: profile.completionPercent,
                  minHeight: 8,
                  backgroundColor: AppTheme.surfaceContainerLow,
                  color: AppTheme.stitchPrimaryContainer,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfilePlaceholder extends StatelessWidget {
  const _ProfilePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppTheme.primaryPurpleLight,
      child: Icon(
        Icons.face_retouching_natural_outlined,
        color: AppTheme.stitchPrimary,
        size: 36,
      ),
    );
  }
}
