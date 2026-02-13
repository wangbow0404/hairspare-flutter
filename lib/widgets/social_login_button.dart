import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_theme.dart';

enum SocialProvider {
  kakao,
  naver,
  google,
}

class SocialLoginButton extends StatelessWidget {
  final SocialProvider provider;
  final VoidCallback? onPressed;
  final bool isLoading;

  const SocialLoginButton({
    super.key,
    required this.provider,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color? borderColor;
    Color hoverColor;
    Widget icon;

    switch (provider) {
      case SocialProvider.kakao:
        backgroundColor = const Color(0xFFFEE500); // yellow-400
        hoverColor = const Color(0xFFEAB308); // yellow-500
        icon = isLoading
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                ),
              )
            : SvgPicture.asset(
                'assets/images/social/kakao_logo.svg',
                width: 24,
                height: 24,
              );
        break;

      case SocialProvider.naver:
        backgroundColor = const Color(0xFF03C75A); // green-500
        hoverColor = const Color(0xFF059669); // green-600
        icon = isLoading
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'N',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  height: 1.0,
                ),
              );
        break;

      case SocialProvider.google:
        backgroundColor = AppTheme.backgroundWhite;
        borderColor = AppTheme.borderGray300; // border-gray-300
        hoverColor = AppTheme.backgroundGray; // hover:bg-gray-50
        icon = isLoading
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.textSecondary),
                ),
              )
            : SvgPicture.asset(
                'assets/images/social/google_logo.svg',
                width: 24,
                height: 24,
              );
        break;
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: isLoading || onPressed == null ? null : onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 48, // w-12 h-12
          height: 48,
          decoration: BoxDecoration(
            color: backgroundColor,
            border: borderColor != null
                ? Border.all(color: borderColor!, width: 2)
                : null,
            shape: BoxShape.circle,
            boxShadow: AppTheme.shadowSm, // shadow-sm
          ),
          child: Center(child: icon),
        ),
      ),
    );
  }
}
