import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

InputDecoration shopEducationNewInputDecoration(
  String hint, {
  int maxLines = 1,
  EdgeInsets? padding,
}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: AppTheme.textSecondary),
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppTheme.radiusXl),
      borderSide: const BorderSide(color: AppTheme.primaryPurpleLight, width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppTheme.radiusXl),
      borderSide: const BorderSide(color: AppTheme.primaryPurpleLight, width: 2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppTheme.radiusXl),
      borderSide: const BorderSide(color: AppTheme.primaryPurple, width: 2),
    ),
    contentPadding: padding ??
        const EdgeInsets.symmetric(
          horizontal: AppTheme.spacing5,
          vertical: AppTheme.spacing4,
        ),
    isDense: true,
  );
}
