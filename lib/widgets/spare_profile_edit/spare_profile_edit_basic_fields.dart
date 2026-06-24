import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/app_theme.dart';
import '../../view_models/profile_edit_view_model.dart';
import '../spare_signup/spare_signup_text_field.dart';
import 'spare_profile_edit_section_card.dart';

/// 프로필 수정 — 기본 정보 필드.
class SpareProfileEditBasicFields extends StatelessWidget {
  const SpareProfileEditBasicFields({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileEditViewModel>();

    return SpareProfileEditSectionCard(
      title: '기본 정보',
      subtitle: '이름·연락처는 매칭·근무 알림에 사용됩니다.',
      child: Column(
        children: [
          if (vm.isIdentityVerified) const _VerifiedBanner(),
          SpareSignupTextField(
            controller: vm.nameController,
            label: '이름',
            prefixIcon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: AppTheme.spacing3),
          SpareSignupTextField(
            controller: vm.emailController,
            label: '이메일',
            prefixIcon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: AppTheme.spacing3),
          SpareSignupTextField(
            controller: vm.phoneController,
            label: '전화번호',
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            suffixIcon: vm.isIdentityVerified
                ? const Icon(
                    Icons.verified_rounded,
                    color: AppTheme.stitchPrimary,
                    size: 20,
                  )
                : null,
          ),
          const SizedBox(height: AppTheme.spacing3),
          SpareSignupTextField(
            controller: vm.birthYearController,
            label: '출생년도',
            prefixIcon: Icons.calendar_today_outlined,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: AppTheme.spacing3),
          DropdownButtonFormField<String>(
            value: vm.gender,
            decoration: InputDecoration(
              labelText: '성별',
              filled: true,
              fillColor: AppTheme.backgroundWhite,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                borderSide: const BorderSide(color: AppTheme.borderGray),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                borderSide: const BorderSide(color: AppTheme.borderGray),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                borderSide: const BorderSide(
                  color: AppTheme.stitchPrimary,
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacing4,
                vertical: AppTheme.spacing3,
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'M', child: Text('남성')),
              DropdownMenuItem(value: 'F', child: Text('여성')),
            ],
            onChanged: vm.setGender,
          ),
        ],
      ),
    );
  }
}

class _VerifiedBanner extends StatelessWidget {
  const _VerifiedBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppTheme.spacing3),
      padding: const EdgeInsets.all(AppTheme.spacing3),
      decoration: BoxDecoration(
        color: AppTheme.stitchPrimaryContainer.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: AppTheme.stitchPrimaryContainer.withValues(alpha: 0.35),
        ),
      ),
      child: const Row(
        children: [
          Icon(Icons.verified_rounded, color: AppTheme.stitchPrimary, size: 18),
          SizedBox(width: AppTheme.spacing2),
          Expanded(
            child: Text(
              '본인인증이 완료된 정보입니다.',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.stitchPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
