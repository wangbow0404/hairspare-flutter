import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// 약관 동의 카드 — mock Section C 스타일.
class SpareSignupTermsCard extends StatelessWidget {
  const SpareSignupTermsCard({
    super.key,
    required this.allRequiredAccepted,
    required this.termsAccepted,
    required this.privacyAccepted,
    required this.personalInfoProvisionAccepted,
    required this.ageAccepted,
    required this.marketingAccepted,
    required this.onToggleAllRequired,
    required this.onTermsChanged,
    required this.onPrivacyChanged,
    required this.onPersonalInfoProvisionChanged,
    required this.onAgeChanged,
    required this.onMarketingChanged,
    this.onViewTerms,
  });

  final bool allRequiredAccepted;
  final bool termsAccepted;
  final bool privacyAccepted;
  final bool personalInfoProvisionAccepted;
  final bool ageAccepted;
  final bool marketingAccepted;
  final VoidCallback onToggleAllRequired;
  final ValueChanged<bool> onTermsChanged;
  final ValueChanged<bool> onPrivacyChanged;
  final ValueChanged<bool> onPersonalInfoProvisionChanged;
  final ValueChanged<bool> onAgeChanged;
  final ValueChanged<bool> onMarketingChanged;
  final void Function(String title)? onViewTerms;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacing6),
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(AppTheme.radius2xl),
        boxShadow: AppTheme.stitchSoftShadow,
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggleAllRequired,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.spacing4),
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppTheme.borderGray),
                  ),
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: allRequiredAccepted,
                      onChanged: (_) => onToggleAllRequired(),
                      activeColor: AppTheme.stitchPrimaryContainer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        '약관 전체 동의',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.stitchTextPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _TermsItem(
            label: '[필수] 서비스 이용약관 동의',
            value: termsAccepted,
            onChanged: onTermsChanged,
            onView: () => onViewTerms?.call('서비스 이용약관'),
          ),
          _TermsItem(
            label: '[필수] 개인정보 수집 및 이용 동의',
            value: privacyAccepted,
            onChanged: onPrivacyChanged,
            onView: () => onViewTerms?.call('개인정보 수집 및 이용'),
          ),
          _TermsItem(
            label: '[필수] 개인정보 제공 및 이용 동의',
            value: personalInfoProvisionAccepted,
            onChanged: onPersonalInfoProvisionChanged,
            onView: () => onViewTerms?.call('개인정보 제공 및 이용'),
          ),
          _TermsItem(
            label: '[필수] 만 14세 이상입니다',
            value: ageAccepted,
            onChanged: onAgeChanged,
          ),
          _TermsItem(
            label: '[선택] 마케팅 정보 수신 동의',
            value: marketingAccepted,
            onChanged: onMarketingChanged,
            onView: () => onViewTerms?.call('마케팅 정보 수신'),
          ),
        ],
      ),
    );
  }
}

class _TermsItem extends StatelessWidget {
  const _TermsItem({
    required this.label,
    required this.value,
    required this.onChanged,
    this.onView,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final VoidCallback? onView;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing1),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: (v) => onChanged(v ?? false),
            activeColor: AppTheme.stitchPrimaryContainer,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.stitchTextPrimary,
              ),
            ),
          ),
          if (onView != null)
            TextButton(
              onPressed: onView,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing2,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                '보기',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.stitchTextSecondary,
                  decoration: TextDecoration.underline,
                  decorationColor: AppTheme.borderGray,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
