import 'package:flutter/material.dart';
import 'package:hairspare/theme/app_theme.dart';

/// 공고 등록 플로우 공통 UI (교육 플로우와 동일한 절제된 톤).
class ShopJobNewSectionCard extends StatelessWidget {
  const ShopJobNewSectionCard({
    super.key,
    required this.child,
    this.padding,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(AppTheme.spacing4),
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(color: AppTheme.borderGray),
        boxShadow: AppTheme.shadowSm,
      ),
      child: child,
    );
  }
}

class ShopJobNewFieldLabel extends StatelessWidget {
  const ShopJobNewFieldLabel({
    super.key,
    required this.label,
    this.isRequired = false,
    this.hasError = false,
  });

  final String label;
  final bool isRequired;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final accent = hasError ? AppTheme.urgentRed : AppTheme.primaryBlue;
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: hasError ? AppTheme.urgentRed : AppTheme.textPrimary,
          ),
        ),
        if (isRequired)
          Text(
            ' *',
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}

/// 일정·급여 등 섹션 내부 소제목 (12px).
class ShopJobNewSubFieldLabel extends StatelessWidget {
  const ShopJobNewSubFieldLabel({
    super.key,
    required this.label,
    this.isRequired = false,
    this.hasError = false,
  });

  final String label;
  final bool isRequired;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final accent = hasError ? AppTheme.urgentRed : AppTheme.textSecondary;
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: accent,
          ),
        ),
        if (isRequired)
          Text(
            ' *',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: accent,
            ),
          ),
      ],
    );
  }
}

Color shopJobNewPickerBorderColor({required bool hasError}) =>
    hasError ? AppTheme.urgentRed : AppTheme.blue200;

class ShopJobNewAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ShopJobNewAppBar({
    super.key,
    required this.title,
    this.onBack,
  });

  final String title;
  final VoidCallback? onBack;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.backgroundWhite,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        color: AppTheme.textPrimary,
        onPressed: onBack ?? () => Navigator.maybePop(context),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
        ),
      ),
      centerTitle: true,
    );
  }
}

class ShopJobNewPrimaryButton extends StatelessWidget {
  const ShopJobNewPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor = AppTheme.primaryBlue,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: backgroundColor,
          disabledBackgroundColor: AppTheme.borderGray,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

class ShopJobNewGuideBullet extends StatelessWidget {
  const ShopJobNewGuideBullet({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacing2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 7),
            child: Icon(
              Icons.check_circle,
              size: 16,
              color: AppTheme.primaryBlue,
            ),
          ),
          const SizedBox(width: AppTheme.spacing2),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                height: 1.45,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
