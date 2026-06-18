import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// 약관 동의 체크박스 섹션.
class SpareSignupTermsSection extends StatelessWidget {
  const SpareSignupTermsSection({
    super.key,
    required this.termsAccepted,
    required this.privacyAccepted,
    required this.personalInfoProvisionAccepted,
    required this.ageAccepted,
    required this.onTermsChanged,
    required this.onPrivacyChanged,
    required this.onPersonalInfoProvisionChanged,
    required this.onAgeChanged,
  });

  final bool termsAccepted;
  final bool privacyAccepted;
  final bool personalInfoProvisionAccepted;
  final bool ageAccepted;
  final ValueChanged<bool> onTermsChanged;
  final ValueChanged<bool> onPrivacyChanged;
  final ValueChanged<bool> onPersonalInfoProvisionChanged;
  final ValueChanged<bool> onAgeChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '약관 동의',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.stitchTextPrimary,
          ),
        ),
        const SizedBox(height: AppTheme.spacing2),
        _TermsRow(
          label: '이용약관 동의 (필수)',
          value: termsAccepted,
          onChanged: onTermsChanged,
        ),
        _TermsRow(
          label: '개인정보 처리방침 동의 (필수)',
          value: privacyAccepted,
          onChanged: onPrivacyChanged,
        ),
        _TermsRow(
          label: '개인정보 제공 및 이용 동의 (필수)',
          value: personalInfoProvisionAccepted,
          onChanged: onPersonalInfoProvisionChanged,
        ),
        _TermsRow(
          label: '만 14세 이상입니다 (필수)',
          value: ageAccepted,
          onChanged: onAgeChanged,
        ),
      ],
    );
  }
}

class _TermsRow extends StatelessWidget {
  const _TermsRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: value,
      onChanged: (v) => onChanged(v ?? false),
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: AppTheme.stitchPrimary,
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          color: AppTheme.stitchTextPrimary,
        ),
      ),
    );
  }
}

/// 전체 동의 + 개별 약관 (선택).
class SpareSignupTermsAllRow extends StatelessWidget {
  const SpareSignupTermsAllRow({
    super.key,
    required this.allAccepted,
    required this.onToggleAll,
  });

  final bool allAccepted;
  final VoidCallback onToggleAll;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggleAll,
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing2),
        child: Row(
          children: [
            Checkbox(
              value: allAccepted,
              onChanged: (_) => onToggleAll(),
              activeColor: AppTheme.stitchPrimary,
            ),
            const Expanded(
              child: Text(
                '전체 동의',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.stitchTextPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
