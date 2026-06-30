import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_theme.dart';

/// Stitch 톤 회원가입 섹션 카드 — HTML mock `rounded-2xl shadow` 대응.
class SpareSignupSectionCard extends StatelessWidget {
  const SpareSignupSectionCard({
    super.key,
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SpareSignupSectionTitle(title: title),
          const SizedBox(height: AppTheme.spacing5),
          child,
        ],
      ),
    );
  }
}

class SpareSignupSectionTitle extends StatelessWidget {
  const SpareSignupSectionTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 24,
          decoration: BoxDecoration(
            color: AppTheme.stitchPrimaryContainer,
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          ),
        ),
        const SizedBox(width: AppTheme.spacing2),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.stitchTextPrimary,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

/// 상단 히어로 — 부제 + 헤드라인.
class SpareSignupHeroHeader extends StatelessWidget {
  const SpareSignupHeroHeader({
    super.key,
    required this.subtitle,
    required this.headline,
  });

  final String subtitle;
  final String headline;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppTheme.stitchPrimaryContainer,
          ),
        ),
        const SizedBox(height: AppTheme.spacing2),
        Text(
          headline,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppTheme.stitchTextPrimary,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

/// 라벨 상단 + 회색 배경 입력 (mock input 스타일).
class SpareSignupLabeledField extends StatelessWidget {
  const SpareSignupLabeledField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.suffix,
    this.textAlign = TextAlign.start,
    this.validator,
    this.inputFormatters,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Widget? suffix;
  final TextAlign textAlign;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppTheme.spacing1),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.stitchTextSecondary,
            ),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          textAlign: textAlign,
          validator: validator,
          inputFormatters: inputFormatters,
          enabled: enabled,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.stitchTextPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 14,
              color: AppTheme.textTertiary,
            ),
            filled: true,
            fillColor: AppTheme.backgroundGray,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacing4,
              vertical: AppTheme.spacing3,
            ),
            suffixIcon: suffix,
            suffixIconConstraints: const BoxConstraints(
              minHeight: 48,
              minWidth: 48,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              borderSide: const BorderSide(color: AppTheme.borderGray),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              borderSide: const BorderSide(color: AppTheme.borderGray),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              borderSide: const BorderSide(
                color: AppTheme.stitchPrimaryContainer,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              borderSide: const BorderSide(color: AppTheme.urgentRed),
            ),
          ),
        ),
      ],
    );
  }
}

/// 경력 슬라이더 — 우측 년수 배지 + 하단 눈금 (슬라이더 tick과 수직 정렬).
class SpareSignupExperienceSlider extends StatelessWidget {
  const SpareSignupExperienceSlider({
    super.key,
    required this.years,
    required this.onChanged,
  });

  final int years;
  final ValueChanged<int> onChanged;

  static const _thumbRadius = 12.0;
  static const _markLabels = <({int year, String label, double width})>[
    (year: 0, label: '신입', width: 28),
    (year: 5, label: '5년', width: 24),
    (year: 10, label: '10년', width: 28),
    (year: 15, label: '15년', width: 32),
    (year: 20, label: '20년+', width: 40),
  ];

  @override
  Widget build(BuildContext context) {
    final display = years == 0 ? '신입' : '$years년';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: AppTheme.spacing1),
              child: Text(
                '경력 사항',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.stitchTextSecondary,
                ),
              ),
            ),
            Text(
              display,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.stitchPrimaryContainer,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacing3),
        LayoutBuilder(
          builder: (context, constraints) {
            final trackWidth = constraints.maxWidth - (_thumbRadius * 2);
            const labelRowHeight = 18.0;

            return Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: _thumbRadius),
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppTheme.stitchPrimaryContainer,
                      inactiveTrackColor: AppTheme.borderGray,
                      trackHeight: 8,
                      thumbColor: AppTheme.stitchPrimaryContainer,
                      overlayColor: AppTheme.stitchPrimaryContainer
                          .withValues(alpha: 0.12),
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: _thumbRadius,
                      ),
                      overlayShape: SliderComponentShape.noOverlay,
                      tickMarkShape: const RoundSliderTickMarkShape(
                        tickMarkRadius: 2,
                      ),
                      activeTickMarkColor: AppTheme.stitchPrimaryContainer,
                      inactiveTickMarkColor: AppTheme.borderGray,
                    ),
                    child: Slider(
                      value: years.toDouble(),
                      min: 0,
                      max: 20,
                      divisions: 20,
                      onChanged: (v) => onChanged(v.round()),
                    ),
                  ),
                ),
                SizedBox(
                  height: labelRowHeight,
                  width: constraints.maxWidth,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      for (final mark in _markLabels)
                        Positioned(
                          left: _thumbRadius +
                              (mark.year / 20) * trackWidth -
                              mark.width / 2,
                          width: mark.width,
                          child: Text(
                            mark.label,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppTheme.stitchTextSecondary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// 휴대폰 SMS 인증 — 번호 입력 + 인증하기/확인.
/// 회원가입 시 휴대폰 본인인증 사용 여부 (중앙 스위치).
///
/// 현재는 앱스토어 1차 출시를 위해 본인인증을 받지 않고 전화번호만 입력받는다.
/// 본인인증을 다시 켜려면 이 값을 `true`로 바꾸면 인증 UI·통과 검사가 모두 되살아난다.
/// (인증 관련 코드는 보존되어 있다.)
const bool kSignupPhoneVerificationEnabled = false;

class SpareSignupPhoneVerificationField extends StatelessWidget {
  const SpareSignupPhoneVerificationField({
    super.key,
    required this.phoneController,
    required this.codeController,
    required this.isVerified,
    required this.codeSent,
    required this.isLoading,
    required this.onSendCode,
    required this.onVerifyCode,
    this.phoneValidator,
    this.verificationEnabled = kSignupPhoneVerificationEnabled,
  });

  final TextEditingController phoneController;
  final TextEditingController codeController;
  final bool isVerified;
  final bool codeSent;
  final bool isLoading;
  final VoidCallback onSendCode;
  final VoidCallback onVerifyCode;
  final String? Function(String?)? phoneValidator;

  /// false면 인증 UI(인증하기 버튼·인증번호 입력·완료 표시)를 숨기고
  /// 전화번호 입력만 노출한다.
  final bool verificationEnabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: AppTheme.spacing1),
          child: Text(
            '휴대폰 번호',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.stitchTextSecondary,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: phoneController,
                enabled: !verificationEnabled || (!isVerified && !codeSent),
                keyboardType: TextInputType.phone,
                validator: phoneValidator,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.stitchTextPrimary,
                ),
                decoration: InputDecoration(
                  hintText: '010-0000-0000',
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textTertiary,
                  ),
                  filled: true,
                  fillColor: isVerified || codeSent
                      ? AppTheme.surfaceContainerLow
                      : AppTheme.backgroundGray,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing4,
                    vertical: AppTheme.spacing3,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    borderSide: const BorderSide(color: AppTheme.borderGray),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    borderSide: const BorderSide(color: AppTheme.borderGray),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    borderSide: const BorderSide(
                      color: AppTheme.stitchPrimaryContainer,
                      width: 1.5,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    borderSide: const BorderSide(color: AppTheme.urgentRed),
                  ),
                ),
              ),
            ),
            if (verificationEnabled && !isVerified) ...[
              const SizedBox(width: AppTheme.spacing2),
              SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: isLoading
                      ? null
                      : (codeSent ? onVerifyCode : onSendCode),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.stitchPrimaryContainer,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppTheme.stitchPrimaryContainer
                        .withValues(alpha: 0.4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing3,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          codeSent ? '확인' : '인증하기',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ],
        ),
        if (verificationEnabled && codeSent && !isVerified) ...[
          const SizedBox(height: AppTheme.spacing2),
          SpareSignupLabeledField(
            controller: codeController,
            label: '인증번호',
            hint: '6자리 입력',
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
          ),
        ],
        if (verificationEnabled && isVerified) ...[
          const SizedBox(height: AppTheme.spacing2),
          const Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                size: 16,
                color: AppTheme.primaryGreen,
              ),
              SizedBox(width: AppTheme.spacing1),
              Text(
                '인증 완료',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// 하단 고정 CTA — backdrop blur (mock footer).
class SpareSignupBlurredSubmitBar extends StatelessWidget {
  const SpareSignupBlurredSubmitBar({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacing4),
          decoration: BoxDecoration(
            color: AppTheme.backgroundWhite.withValues(alpha: 0.85),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: isLoading ? null : onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.stitchPrimaryContainer,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppTheme.stitchPrimaryContainer
                      .withValues(alpha: 0.4),
                  elevation: 0,
                  shadowColor:
                      AppTheme.stitchPrimaryContainer.withValues(alpha: 0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        label,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
