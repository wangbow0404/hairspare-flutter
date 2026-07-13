import 'package:flutter/material.dart';

import '../../theme/admin_stitch_theme.dart';
import '../../theme/app_theme.dart';
import '../../utils/business_setting_help.dart';

/// 비즈니스 설정 입력 필드 — 항목별 시각 테마 + 라벨 + (i) 안내 + 숫자/원화 입력.
class AdminBusinessSettingField extends StatelessWidget {
  const AdminBusinessSettingField({
    super.key,
    required this.settingKey,
    required this.label,
    required this.controller,
    this.isMoney = false,
  });

  final String settingKey;
  final String label;
  final TextEditingController controller;
  final bool isMoney;

  @override
  Widget build(BuildContext context) {
    final visual = _BusinessSettingVisual.forKey(settingKey);

    return Container(
      padding: const EdgeInsets.all(AdminStitchTheme.componentPadding),
      decoration: BoxDecoration(
        color: visual.backgroundColor,
        borderRadius: BorderRadius.circular(AdminStitchTheme.radiusXl),
        border: Border.all(color: visual.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabelRow(context, visual),
          const SizedBox(height: AdminStitchTheme.stackTight),
          _buildInput(visual),
        ],
      ),
    );
  }

  Widget _buildLabelRow(BuildContext context, _BusinessSettingVisual visual) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(visual.icon, size: 16, color: visual.iconColor),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: AdminStitchTheme.labelSm.copyWith(
              color: visual.labelColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        IconButton(
          onPressed: () => BusinessSettingHelp.showHelp(
            context,
            label: label,
            key: settingKey,
          ),
          icon: const Icon(Icons.info_outline),
          iconSize: 20,
          color: AdminStitchTheme.textSecondary,
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          tooltip: '설정 안내',
        ),
      ],
    );
  }

  Widget _buildInput(_BusinessSettingVisual visual) {
    return SizedBox(
      height: AdminStitchTheme.buttonHeight,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: AdminStitchTheme.bodyLg,
        decoration: InputDecoration(
          prefixText: isMoney ? '₩ ' : null,
          prefixStyle: AdminStitchTheme.bodyLg.copyWith(
            color: AdminStitchTheme.textSecondary,
          ),
          filled: true,
          fillColor: AdminStitchTheme.surfaceCard,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AdminStitchTheme.radiusXl),
            borderSide: BorderSide(color: visual.borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AdminStitchTheme.radiusXl),
            borderSide: BorderSide(color: visual.borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AdminStitchTheme.radiusXl),
            borderSide: BorderSide(
              color: visual.focusColor,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}

class _BusinessSettingVisual {
  const _BusinessSettingVisual({
    required this.backgroundColor,
    required this.borderColor,
    required this.labelColor,
    required this.iconColor,
    required this.focusColor,
    required this.icon,
  });

  final Color backgroundColor;
  final Color borderColor;
  final Color labelColor;
  final Color iconColor;
  final Color focusColor;
  final IconData icon;

  static _BusinessSettingVisual forKey(String key) {
    return _byKey[key] ?? _defaultTheme;
  }

  static const _defaultTheme = _BusinessSettingVisual(
    backgroundColor: Color(0xFFF8FAFC),
    borderColor: Color(0x4D94A3B8),
    labelColor: Color(0xFF475569),
    iconColor: Color(0xFF64748B),
    focusColor: Color(0xFF64748B),
    icon: Icons.tune,
  );

  static final Map<String, _BusinessSettingVisual> _byKey = {
    // ── 경제·가격 ──────────────────────────────────────────────
    'energyPointCostPerUnit': _BusinessSettingVisual(
      backgroundColor: Color(0xFFFFFBEB),
      borderColor: Color(0x4DF59E0B),
      labelColor: Color(0xFFB45309),
      iconColor: Color(0xFFF59E0B),
      focusColor: Color(0xFFD97706),
      icon: Icons.bolt,
    ),
    'urgentJobListingFee': _BusinessSettingVisual(
      backgroundColor: AppTheme.urgentRedLight,
      borderColor: AppTheme.urgentRed.withValues(alpha: 0.35),
      labelColor: AppTheme.urgentRed,
      iconColor: AppTheme.urgentRed,
      focusColor: AppTheme.urgentRed,
      icon: Icons.rocket_launch,
    ),
    'hipassListingFee': _BusinessSettingVisual(
      backgroundColor: Color(0xFFEFF4FF),
      borderColor: AdminStitchTheme.primary.withValues(alpha: 0.25),
      labelColor: AdminStitchTheme.primary,
      iconColor: AdminStitchTheme.secondary,
      focusColor: AdminStitchTheme.primaryContainer,
      icon: Icons.star,
    ),
    'subscriptionMonthlyFee': _BusinessSettingVisual(
      backgroundColor: Color(0xFFEFF6FF),
      borderColor: Color(0x4D3B82F6),
      labelColor: Color(0xFF1D4ED8),
      iconColor: Color(0xFF3B82F6),
      focusColor: Color(0xFF2563EB),
      icon: Icons.card_membership,
    ),
    'premiumJobFee': _BusinessSettingVisual(
      backgroundColor: Color(0xFFFFF7ED),
      borderColor: Color(0x4DEAB308),
      labelColor: Color(0xFFA16207),
      iconColor: Color(0xFFCA8A04),
      focusColor: Color(0xFFD97706),
      icon: Icons.workspace_premium,
    ),
    'chatAddonFee': _BusinessSettingVisual(
      backgroundColor: Color(0xFFF0FDFA),
      borderColor: Color(0x4D14B8A6),
      labelColor: Color(0xFF0F766E),
      iconColor: Color(0xFF14B8A6),
      focusColor: Color(0xFF0D9488),
      icon: Icons.chat_bubble_outline,
    ),
    'modelDepositAmount': _BusinessSettingVisual(
      backgroundColor: Color(0xFFEEF2FF),
      borderColor: Color(0x4D6366F1),
      labelColor: Color(0xFF4338CA),
      iconColor: Color(0xFF6366F1),
      focusColor: Color(0xFF4F46E5),
      icon: Icons.shield_outlined,
    ),
    'jobEnergyFormulaDivisor': _BusinessSettingVisual(
      backgroundColor: Color(0xFFF1F5F9),
      borderColor: Color(0x4D64748B),
      labelColor: Color(0xFF334155),
      iconColor: Color(0xFF64748B),
      focusColor: Color(0xFF475569),
      icon: Icons.calculate_outlined,
    ),

    // ── 쿼터·한도 ──────────────────────────────────────────────
    'modelDailyMatchLimit': _BusinessSettingVisual(
      backgroundColor: Color(0xFFFDF2F8),
      borderColor: Color(0x4DEC4899),
      labelColor: Color(0xFFBE185D),
      iconColor: Color(0xFFEC4899),
      focusColor: Color(0xFFDB2777),
      icon: Icons.favorite_border,
    ),
    'maxEnergyPurchaseAmount': _BusinessSettingVisual(
      backgroundColor: Color(0xFFFFF7ED),
      borderColor: Color(0x4DF97316),
      labelColor: Color(0xFFC2410C),
      iconColor: AppTheme.orange500,
      focusColor: Color(0xFFEA580C),
      icon: Icons.battery_charging_full,
    ),
    'shopTierBronzeMaxJobs': _BusinessSettingVisual(
      backgroundColor: Color(0xFFFFF7ED),
      borderColor: Color(0x4DA16207),
      labelColor: Color(0xFF92400E),
      iconColor: Color(0xFFB45309),
      focusColor: Color(0xFFA16207),
      icon: Icons.military_tech,
    ),
    'shopTierSilverMaxJobs': _BusinessSettingVisual(
      backgroundColor: Color(0xFFF8FAFC),
      borderColor: Color(0x4D94A3B8),
      labelColor: Color(0xFF475569),
      iconColor: Color(0xFF94A3B8),
      focusColor: Color(0xFF64748B),
      icon: Icons.military_tech,
    ),
    'shopTierGoldMaxJobs': _BusinessSettingVisual(
      backgroundColor: Color(0xFFFFFBEB),
      borderColor: Color(0x4DEAB308),
      labelColor: Color(0xFFA16207),
      iconColor: Color(0xFFCA8A04),
      focusColor: Color(0xFFD97706),
      icon: Icons.military_tech,
    ),
    'shopTierPlatinumMaxJobs': _BusinessSettingVisual(
      backgroundColor: Color(0xFFF5F3FF),
      borderColor: AdminStitchTheme.primary.withValues(alpha: 0.25),
      labelColor: AdminStitchTheme.primary,
      iconColor: AdminStitchTheme.secondary,
      focusColor: AdminStitchTheme.primaryContainer,
      icon: Icons.workspace_premium,
    ),

    // ── 제재정책 ──────────────────────────────────────────────
    'contactMaxAttemptsPerChat': _BusinessSettingVisual(
      backgroundColor: Color(0xFFFFF7ED),
      borderColor: Color(0x4DF97316),
      labelColor: Color(0xFFC2410C),
      iconColor: AppTheme.orange500,
      focusColor: Color(0xFFEA580C),
      icon: Icons.warning_amber_outlined,
    ),
    'shopContactPenaltyDays': _BusinessSettingVisual(
      backgroundColor: AppTheme.urgentRedLight,
      borderColor: AppTheme.urgentRed.withValues(alpha: 0.3),
      labelColor: AppTheme.urgentRed,
      iconColor: AppTheme.urgentRed,
      focusColor: AppTheme.urgentRed,
      icon: Icons.gavel,
    ),
    'maxShopRoomPenaltiesBeforeBan': _BusinessSettingVisual(
      backgroundColor: Color(0xFFFFF1F2),
      borderColor: Color(0x4DB91C1C),
      labelColor: Color(0xFF991B1B),
      iconColor: Color(0xFFB91C1C),
      focusColor: Color(0xFFDC2626),
      icon: Icons.block,
    ),
    'shopUnilateralCancelLimit30d': _BusinessSettingVisual(
      backgroundColor: Color(0xFFFFF7ED),
      borderColor: Color(0x4DF97316),
      labelColor: Color(0xFF9A3412),
      iconColor: Color(0xFFEA580C),
      focusColor: Color(0xFFC2410C),
      icon: Icons.event_busy,
    ),
    'shopJobPostingSuspensionDays': _BusinessSettingVisual(
      backgroundColor: Color(0xFFF1F5F9),
      borderColor: Color(0x4D64748B),
      labelColor: Color(0xFF334155),
      iconColor: Color(0xFF64748B),
      focusColor: Color(0xFF475569),
      icon: Icons.lock_clock,
    ),
    'lateCancelCutoffHours': _BusinessSettingVisual(
      backgroundColor: Color(0xFFEFF6FF),
      borderColor: Color(0x4D3B82F6),
      labelColor: Color(0xFF1E40AF),
      iconColor: Color(0xFF3B82F6),
      focusColor: Color(0xFF2563EB),
      icon: Icons.schedule,
    ),

    // ── 랭킹·노출 ──────────────────────────────────────────────
    'jobPopularityTopN': _BusinessSettingVisual(
      backgroundColor: Color(0xFFF5F3FF),
      borderColor: AdminStitchTheme.primary.withValues(alpha: 0.2),
      labelColor: AdminStitchTheme.primary,
      iconColor: AdminStitchTheme.secondary,
      focusColor: AdminStitchTheme.primaryContainer,
      icon: Icons.trending_up,
    ),
    'newJobBonusWindowHours': _BusinessSettingVisual(
      backgroundColor: Color(0xFFECFDF5),
      borderColor: Color(0x4D10B981),
      labelColor: Color(0xFF047857),
      iconColor: AdminStitchTheme.emerald,
      focusColor: Color(0xFF059669),
      icon: Icons.auto_awesome,
    ),
    'jobPopularityAppWeight': _BusinessSettingVisual(
      backgroundColor: Color(0xFFEFF6FF),
      borderColor: Color(0x4D3B82F6),
      labelColor: Color(0xFF1D4ED8),
      iconColor: Color(0xFF3B82F6),
      focusColor: Color(0xFF2563EB),
      icon: Icons.person_add_alt_1,
    ),
    'jobPopularityViewWeight': _BusinessSettingVisual(
      backgroundColor: Color(0xFFF0F9FF),
      borderColor: Color(0x4D0EA5E9),
      labelColor: Color(0xFF0369A1),
      iconColor: Color(0xFF0EA5E9),
      focusColor: Color(0xFF0284C7),
      icon: Icons.visibility_outlined,
    ),
    'jobPopularityPremiumBonus': _BusinessSettingVisual(
      backgroundColor: Color(0xFFFFF7ED),
      borderColor: Color(0x4DEAB308),
      labelColor: Color(0xFFA16207),
      iconColor: Color(0xFFCA8A04),
      focusColor: Color(0xFFD97706),
      icon: Icons.diamond_outlined,
    ),
    'jobPopularityLowEnergyBonus': _BusinessSettingVisual(
      backgroundColor: Color(0xFFFFFBEB),
      borderColor: Color(0x4DF59E0B),
      labelColor: Color(0xFFB45309),
      iconColor: Color(0xFFF59E0B),
      focusColor: Color(0xFFD97706),
      icon: Icons.bolt_outlined,
    ),

    // ── 공간대여 ──────────────────────────────────────────────
    'spaceMinBookingHours': _BusinessSettingVisual(
      backgroundColor: Color(0xFFECFDF5),
      borderColor: Color(0x4D10B981),
      labelColor: Color(0xFF047857),
      iconColor: AdminStitchTheme.emerald,
      focusColor: Color(0xFF059669),
      icon: Icons.meeting_room_outlined,
    ),
    'spaceBookingWindowDays': _BusinessSettingVisual(
      backgroundColor: Color(0xFFF0FDF4),
      borderColor: Color(0x4D22C55E),
      labelColor: Color(0xFF15803D),
      iconColor: Color(0xFF22C55E),
      focusColor: Color(0xFF16A34A),
      icon: Icons.calendar_month_outlined,
    ),
    'spaceDefaultOpenHour': _BusinessSettingVisual(
      backgroundColor: Color(0xFFFFFBEB),
      borderColor: Color(0x4DF59E0B),
      labelColor: Color(0xFFB45309),
      iconColor: Color(0xFFF59E0B),
      focusColor: Color(0xFFD97706),
      icon: Icons.wb_sunny_outlined,
    ),
    'spaceDefaultCloseHour': _BusinessSettingVisual(
      backgroundColor: Color(0xFFEEF2FF),
      borderColor: Color(0x4D6366F1),
      labelColor: Color(0xFF4338CA),
      iconColor: Color(0xFF6366F1),
      focusColor: Color(0xFF4F46E5),
      icon: Icons.nightlight_outlined,
    ),

    // ── 알림 ──────────────────────────────────────────────
    'scheduleReminderFirstHours': _BusinessSettingVisual(
      backgroundColor: Color(0xFFEFF6FF),
      borderColor: Color(0x4D3B82F6),
      labelColor: Color(0xFF1D4ED8),
      iconColor: Color(0xFF3B82F6),
      focusColor: Color(0xFF2563EB),
      icon: Icons.notifications_active_outlined,
    ),
    'scheduleReminderSecondHours': _BusinessSettingVisual(
      backgroundColor: Color(0xFFF0F9FF),
      borderColor: Color(0x4D0EA5E9),
      labelColor: Color(0xFF0369A1),
      iconColor: Color(0xFF0EA5E9),
      focusColor: Color(0xFF0284C7),
      icon: Icons.notifications_outlined,
    ),
    'checkInReminderFirstHours': _BusinessSettingVisual(
      backgroundColor: Color(0xFFFFF7ED),
      borderColor: Color(0x4DF97316),
      labelColor: Color(0xFFC2410C),
      iconColor: AppTheme.orange500,
      focusColor: Color(0xFFEA580C),
      icon: Icons.how_to_reg_outlined,
    ),
    'checkInReminderSecondHours': _BusinessSettingVisual(
      backgroundColor: Color(0xFFFFFBEB),
      borderColor: Color(0x4DF59E0B),
      labelColor: Color(0xFFB45309),
      iconColor: Color(0xFFF59E0B),
      focusColor: Color(0xFFD97706),
      icon: Icons.access_time,
    ),
    'checkInReminderThirdHours': _BusinessSettingVisual(
      backgroundColor: AppTheme.urgentRedLight,
      borderColor: AppTheme.urgentRed.withValues(alpha: 0.3),
      labelColor: AppTheme.urgentRed,
      iconColor: AppTheme.urgentRed,
      focusColor: AppTheme.urgentRed,
      icon: Icons.alarm_on_outlined,
    ),
  };
}
