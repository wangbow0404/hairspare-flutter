import 'package:flutter/material.dart';

import '../../theme/admin_stitch_theme.dart';
import '../../utils/business_setting_help.dart';

/// 비즈니스 설정 입력 필드 — 라벨 + (i) 안내 + 숫자/원화 입력.
class AdminBusinessSettingField extends StatelessWidget {
  const AdminBusinessSettingField({
    super.key,
    required this.settingKey,
    required this.label,
    required this.controller,
    this.isMoney = false,
    this.highlighted = false,
  });

  final String settingKey;
  final String label;
  final TextEditingController controller;
  final bool isMoney;
  final bool highlighted;

  static const _hipassKey = 'hipassListingFee';
  static const Color _highlightBg = Color(0xFFEFF4FF);

  @override
  Widget build(BuildContext context) {
    final field = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabelRow(context),
        const SizedBox(height: AdminStitchTheme.stackTight),
        _buildInput(),
      ],
    );

    if (highlighted || settingKey == _hipassKey) {
      return Container(
        padding: const EdgeInsets.all(AdminStitchTheme.componentPadding),
        decoration: BoxDecoration(
          color: _highlightBg,
          borderRadius: BorderRadius.circular(AdminStitchTheme.radiusXl),
          border: Border.all(
            color: AdminStitchTheme.primary.withValues(alpha: 0.2),
          ),
        ),
        child: field,
      );
    }
    return field;
  }

  Widget _buildLabelRow(BuildContext context) {
    final isHipass = settingKey == _hipassKey;
    final labelStyle = (highlighted || isHipass)
        ? AdminStitchTheme.labelSm.copyWith(
            color: AdminStitchTheme.primary,
            fontWeight: FontWeight.w700,
          )
        : AdminStitchTheme.labelSm.copyWith(
            color: AdminStitchTheme.onSurface,
            fontWeight: FontWeight.w700,
          );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isHipass) ...[
          Icon(Icons.star, size: 16, color: AdminStitchTheme.secondary),
          const SizedBox(width: 4),
        ],
        Expanded(child: Text(label, style: labelStyle)),
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

  Widget _buildInput() {
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
            borderSide: const BorderSide(color: AdminStitchTheme.borderDefault),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AdminStitchTheme.radiusXl),
            borderSide: const BorderSide(color: AdminStitchTheme.borderDefault),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AdminStitchTheme.radiusXl),
            borderSide: const BorderSide(
              color: AdminStitchTheme.primaryContainer,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
