import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

InputDecoration shopJobNewInputDecoration(
  String hint, {
  int maxLines = 1,
  EdgeInsets? padding,
}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: AppTheme.textSecondary),
    filled: true,
    fillColor: AppTheme.backgroundGray,
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
      borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      borderSide: const BorderSide(color: AppTheme.urgentRed),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      borderSide: const BorderSide(color: AppTheme.urgentRed, width: 1.5),
    ),
    errorStyle: const TextStyle(
      color: AppTheme.urgentRed,
      fontSize: 12,
    ),
    contentPadding: padding ??
        const EdgeInsets.symmetric(
          horizontal: AppTheme.spacing4,
          vertical: AppTheme.spacing3,
        ),
    isDense: true,
  );
}
