import 'package:flutter/material.dart';

/// a안 디자인 시스템 색상 (2026-07-22).
abstract final class HairSpareColors {
  // Brand — 단일 포인트
  static const Color brandPrimary = Color(0xFFB3355C);
  static const Color brandPrimarySoft = Color(0xFFFBEAF0);

  // Surfaces
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF5F5F6);
  static const Color surfaceMutedAlt = Color(0xFFF3F3F4);

  // Borders
  static const Color border = Color(0xFFEFEFEF);
  static const Color borderStrong = Color(0xFFE4E4E6);

  // Text
  static const Color textPrimary = Color(0xFF161616);
  static const Color textSecondary = Color(0xFF8D8D91);
  static const Color textSecondaryAlt = Color(0xFF9A9A9E);
  static const Color textStrong = Color(0xFF3A3A3D);
  static const Color textStrongAlt = Color(0xFF5A5A5D);

  // Structural active (tabs, chips, calendar)
  static const Color activeStructural = Color(0xFF161616);

  // Placeholder images
  static const Color placeholderWarm = Color(0xFFEDEBE7);
  static const Color placeholderWarmAlt = Color(0xFFE9E6E1);

  // Status / category
  static const Color statusSuccess = Color(0xFF1CA672);
  static const Color statusSuccessBg = Color(0xFFE9F7EF);
  static const Color statusUrgent = Color(0xFFFF4757);
  static const Color statusEducation = Color(0xFFC08A2E);
  static const Color statusEducationBg = Color(0xFFFBF2E4);
  static const Color statusMatching = Color(0xFF5C6B94);
  static const Color statusMatchingBg = Color(0xFFECEEF4);
  static const Color star = Color(0xFFFFB800);

  // 홈 퀵메뉴 카테고리 구분용 보조 색상 (교육·모델매칭 등 기존 시맨틱
  // 컬러와 겹치지 않는 항목만 추가).
  static const Color categoryVenue = Color(0xFF3D8BA6);

  // 하이패스(유료 노출) 전용 강조색 — 급구(red)·일반(brand pink)과
  // 시각적으로 구분되는 보라 계열.
  static const Color hipass = Color(0xFF8B5CF6);
  static const Color hipassBg = Color(0xFFF3EEFF);
}
