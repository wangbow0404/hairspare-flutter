import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../theme/home_text_styles.dart';

/// 미용실 홈 전용 카드 — 스페어「일반 공고」카드와 같은 그라데이션 썸네일·태그·타이포이지만
/// 구인 공고 목록이 아니라 샵 운영 액션(지원자·스케줄 등)용입니다.
class ShopHomeOperationCard extends StatelessWidget {
  const ShopHomeOperationCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.tagPrimary = '미용실',
    this.tagSecondary = '운영',
    this.accentBorder = false,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String tagPrimary;
  final String tagSecondary;

  /// `true`이면 급구 카드처럼 오렌지 강조 테두리·배경 (중요 알림용).
  final bool accentBorder;

  @override
  Widget build(BuildContext context) {
    final borderColor =
        accentBorder ? AppTheme.orange500 : AppTheme.borderGray;
    final bgColor = accentBorder ? AppTheme.orange50 : AppTheme.backgroundWhite;
    final borderWidth = accentBorder ? 2.0 : 1.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacing4),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
            border: Border.all(color: borderColor, width: borderWidth),
            boxShadow: AppTheme.shadowSm,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.green200,
                      AppTheme.blue200,
                    ],
                  ),
                  borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                ),
              ),
              const SizedBox(width: AppTheme.spacing3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: AppTheme.spacing2,
                      runSpacing: AppTheme.spacing1,
                      children: [
                        _Tag(
                          label: tagPrimary,
                          bg: AppTheme.green100,
                          fg: AppTheme.green700,
                        ),
                        _Tag(
                          label: tagSecondary,
                          bg: AppTheme.backgroundGray,
                          fg: AppTheme.textGray700,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacing2),
                    Text(
                      title,
                      style: HomeTextStyles.homeCardTitle,
                    ),
                    const SizedBox(height: AppTheme.spacing1),
                    Text(
                      subtitle,
                      style: HomeTextStyles.homeCardMeta,
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: AppTheme.spacing2),
                child: Icon(
                  Icons.chevron_right,
                  color: AppTheme.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({
    required this.label,
    required this.bg,
    required this.fg,
  });

  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppTheme.spacingSymmetric(
        horizontal: AppTheme.spacing2,
        vertical: AppTheme.spacing1,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppTheme.borderRadius(AppTheme.radiusSm),
      ),
      child: Text(
        label,
        style: HomeTextStyles.homeCardTag.copyWith(color: fg),
      ),
    );
  }
}
