import 'package:flutter/material.dart';

import 'package:hairspare/theme/app_theme.dart';
import 'package:hairspare/utils/icon_mapper.dart';

/// 교육 신청·결제 플로우 공통 UI (헤어스페어 브랜드 톤).
class EducationFlowBackground extends StatelessWidget {
  const EducationFlowBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppTheme.backgroundGray,
      child: child,
    );
  }
}

class EducationPremiumCard extends StatelessWidget {
  const EducationPremiumCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding ?? AppTheme.spacing(AppTheme.spacing5),
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: AppTheme.borderRadius(AppTheme.radiusXl),
        border: Border.all(color: AppTheme.borderGray),
        boxShadow: AppTheme.shadowSm,
      ),
      child: child,
    );
  }
}

class EducationFlowStepLabel extends StatelessWidget {
  const EducationFlowStepLabel({
    super.key,
    required this.step,
    required this.title,
    this.subtitle,
  });

  final String step;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
                height: 1.3,
              ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: AppTheme.spacing2),
          Text(
            subtitle!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
          ),
        ],
      ],
    );
  }
}

class EducationEnergyHeroCard extends StatelessWidget {
  const EducationEnergyHeroCard({
    super.key,
    required this.balance,
    this.label = '보유 에너지',
  });

  final int balance;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppTheme.spacing(AppTheme.spacing5),
      decoration: BoxDecoration(
        color: AppTheme.orange50,
        borderRadius: AppTheme.borderRadius(AppTheme.radiusXl),
        border: Border.all(color: AppTheme.orange100),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.backgroundWhite,
              borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
            ),
            child: IconMapper.icon('zap', size: 22, color: AppTheme.orange500) ??
                const Icon(Icons.flash_on, size: 22, color: AppTheme.orange500),
          ),
          const SizedBox(width: AppTheme.spacing3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$balance개',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                        height: 1,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EducationProgramPreviewCard extends StatelessWidget {
  const EducationProgramPreviewCard({
    super.key,
    required this.title,
    required this.energyCost,
    required this.isOnline,
    this.scheduleLabel,
  });

  final String title;
  final int energyCost;
  final bool isOnline;
  final String? scheduleLabel;

  @override
  Widget build(BuildContext context) {
    return EducationPremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryPurpleLight,
                  borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                ),
                child: const Icon(
                  Icons.school_outlined,
                  color: AppTheme.primaryPurple,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppTheme.spacing3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '신청 교육',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                            height: 1.35,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing4),
          Wrap(
            spacing: AppTheme.spacing2,
            runSpacing: AppTheme.spacing2,
            children: [
              EducationTagChip(
                label: isOnline ? '온라인' : '오프라인',
                icon: isOnline ? Icons.videocam_outlined : Icons.location_on_outlined,
                backgroundColor: AppTheme.backgroundGray,
                foregroundColor: AppTheme.textGray700,
              ),
              EducationTagChip(
                label: '에너지 $energyCost개',
                icon: Icons.flash_on_outlined,
                backgroundColor: AppTheme.orange50,
                foregroundColor: AppTheme.orange600,
              ),
              if (scheduleLabel != null)
                EducationTagChip(
                  label: scheduleLabel!,
                  icon: Icons.calendar_month_outlined,
                  backgroundColor: AppTheme.backgroundGray,
                  foregroundColor: AppTheme.textGray700,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class EducationTagChip extends StatelessWidget {
  const EducationTagChip({
    super.key,
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppTheme.spacingSymmetric(
        horizontal: AppTheme.spacing3,
        vertical: AppTheme.spacing2,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: foregroundColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: foregroundColor,
            ),
          ),
        ],
      ),
    );
  }
}

class EducationPaymentBreakdownCard extends StatelessWidget {
  const EducationPaymentBreakdownCard({
    super.key,
    required this.energyCost,
    required this.balance,
  });

  final int energyCost;
  final int balance;

  @override
  Widget build(BuildContext context) {
    final afterBalance = (balance - energyCost).clamp(0, 999999);

    return EducationPremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '결제 내역',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
          ),
          const SizedBox(height: AppTheme.spacing4),
          _BreakdownRow(
            label: '결제 에너지',
            value: '$energyCost개',
            icon: Icons.flash_on_outlined,
            iconColor: AppTheme.orange500,
            iconBackground: AppTheme.orange50,
          ),
          const SizedBox(height: AppTheme.spacing3),
          _BreakdownRow(
            label: '보유 에너지',
            value: '$balance개',
            icon: Icons.account_balance_wallet_outlined,
            iconColor: AppTheme.primaryBlue,
            iconBackground: AppTheme.blue100,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing3),
            child: Divider(
              height: 1,
              color: AppTheme.borderGray,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '결제 후 잔액',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              Text(
                '$afterBalance개',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconBackground,
            borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: AppTheme.spacing3),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
        ),
      ],
    );
  }
}

class EducationInsufficientEnergyBanner extends StatelessWidget {
  const EducationInsufficientEnergyBanner({
    super.key,
    required this.shortfall,
    required this.onChargeTap,
  });

  final int shortfall;
  final VoidCallback onChargeTap;

  @override
  Widget build(BuildContext context) {
    return EducationPremiumCard(
      padding: AppTheme.spacing(AppTheme.spacing4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.orange50,
                  borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: AppTheme.orange600,
                ),
              ),
              const SizedBox(width: AppTheme.spacing3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '에너지가 부족해요',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.orange600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '에너지 ${shortfall}개를 더 충전하면 신청할 수 있어요.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                            height: 1.45,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing4),
          OutlinedButton.icon(
            onPressed: onChargeTap,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.orange600,
              side: const BorderSide(color: AppTheme.orange100, width: 2),
              padding: AppTheme.spacingSymmetric(
                horizontal: AppTheme.spacing4,
                vertical: AppTheme.spacing3,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: AppTheme.borderRadius(AppTheme.radiusXl),
              ),
            ),
            icon: const Icon(Icons.add_circle_outline),
            label: const Text(
              '에너지 충전하기',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class EducationGradientPrimaryButton extends StatelessWidget {
  const EducationGradientPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.gradientColors = const [
      AppTheme.primaryPurple,
      AppTheme.primaryBlue,
    ],
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final List<Color> gradientColors;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: AppTheme.borderRadius(AppTheme.radiusXl),
        child: Ink(
          height: 52,
          decoration: BoxDecoration(
            color: enabled
                ? (gradientColors.length == 1
                    ? gradientColors.first
                    : null)
                : AppTheme.borderGray300,
            gradient: enabled && gradientColors.length > 1
                ? LinearGradient(colors: gradientColors)
                : null,
            borderRadius: AppTheme.borderRadius(AppTheme.radiusXl),
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: Colors.white, size: 18),
                        const SizedBox(width: AppTheme.spacing2),
                      ],
                      Text(
                        label,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
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

class EducationInfoNoticeCard extends StatelessWidget {
  const EducationInfoNoticeCard({
    super.key,
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppTheme.spacing(AppTheme.spacing4),
      decoration: BoxDecoration(
        color: AppTheme.blue100.withValues(alpha: 0.35),
        borderRadius: AppTheme.borderRadius(AppTheme.radiusXl),
        border: Border.all(color: AppTheme.blue100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryBlueDark,
                ),
          ),
          const SizedBox(height: AppTheme.spacing2),
          Text(
            body,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 13,
                  color: AppTheme.primaryBlueDark,
                  height: 1.55,
                ),
          ),
        ],
      ),
    );
  }
}

class EducationEnrollmentSuccessHero extends StatelessWidget {
  const EducationEnrollmentSuccessHero({
    super.key,
    required this.title,
    required this.scheduleText,
    required this.energyPaid,
    required this.isOnline,
  });

  final String title;
  final String scheduleText;
  final int energyPaid;
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppTheme.spacing(AppTheme.spacing5),
      decoration: BoxDecoration(
        color: AppTheme.green50,
        borderRadius: AppTheme.borderRadius(AppTheme.radiusXl),
        border: Border.all(color: AppTheme.green100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.backgroundWhite,
                  borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: AppTheme.primaryGreen,
                  size: 26,
                ),
              ),
              const SizedBox(width: AppTheme.spacing3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '신청이 완료되었어요',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                            height: 1.4,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing4),
          Wrap(
            spacing: AppTheme.spacing2,
            runSpacing: AppTheme.spacing2,
            children: [
              _HeroMetaChip(
                icon: Icons.calendar_month_outlined,
                label: scheduleText,
              ),
              _HeroMetaChip(
                icon: Icons.flash_on_outlined,
                label: '에너지 $energyPaid개',
              ),
              _HeroMetaChip(
                icon: isOnline
                    ? Icons.videocam_outlined
                    : Icons.location_on_outlined,
                label: isOnline ? '온라인' : '오프라인',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroMetaChip extends StatelessWidget {
  const _HeroMetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppTheme.spacingSymmetric(
        horizontal: AppTheme.spacing3,
        vertical: AppTheme.spacing2,
      ),
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
        border: Border.all(color: AppTheme.borderGray),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textGray700,
            ),
          ),
        ],
      ),
    );
  }
}

class EducationDetailInfoTile extends StatelessWidget {
  const EducationDetailInfoTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.tint,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppTheme.spacing(AppTheme.spacing4),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.08),
        borderRadius: AppTheme.borderRadius(AppTheme.radiusXl),
        border: Border.all(color: tint.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.14),
              borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
            ),
            child: Icon(icon, size: 20, color: tint),
          ),
          const SizedBox(width: AppTheme.spacing3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                        height: 1.35,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
